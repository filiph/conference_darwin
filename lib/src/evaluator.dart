import 'dart:async';
import 'dart:math';
import 'package:conference_darwin/src/baked_schedule.dart';
import 'package:conference_darwin/src/schedule_phenotype.dart';
import 'package:conference_darwin/src/session.dart';
import 'package:darwin/darwin.dart';

class ScheduleEvaluator
    extends PhenotypeEvaluator<Schedule, int, ScheduleEvaluatorPenalty> {
  static const _lunchHourMin = 12;

  static const _lunchHourMax = 13;

  final List<Session> sessions;

  final int targetDays = 2;

  final List<CustomEvaluator> _customEvaluators;

  /// Minimal amount of time between breaks.
  final int minBlockLength = 90;

  final int maxMinutesWithoutBreak = 90;

  final int maxMinutesWithoutLargeMeal = 5 * 60;

  final int maxMinutesInDay = 8 * 60;

  final int targetLunchesPerDay = 1;

  ScheduleEvaluator(this.sessions, this._customEvaluators);

  @override
  Future<ScheduleEvaluatorPenalty> evaluate(Schedule phenotype) {
    return new Future.value(internalEvaluate(phenotype));
  }

  ScheduleEvaluatorPenalty internalEvaluate(Schedule phenotype) {
    final penalty = new ScheduleEvaluatorPenalty();

    final ordered = phenotype.getOrdered(sessions);

    for (final session in sessions) {
      if (!ordered.contains(session)) {
        // A session was left out of the program entirely.
        penalty.constraints += 50.0;
      }
    }

    if (ordered.any((s) => s.isKeynote)) {
      // There should be a keynote early on day 1.
      final firstKeynote = ordered.firstWhere((s) => s.isKeynote);
      penalty.constraints += ordered.indexOf(firstKeynote).toDouble();
    }

    for (int i = 0; i < ordered.length; i++) {
      for (int j = i + 1; j < ordered.length; j++) {
        final first = ordered[i];
        final second = ordered[j];
        if (first.shouldComeAfter(second)) {
          penalty.constraints += 10.0 + (j - i) / 20;
        }
      }
    }

    final days = phenotype.getDays(ordered, sessions).toList(growable: false);
    penalty.constraints += (targetDays - days.length).abs() * 10.0;

    int dayNumber = 0;
    for (final day in days) {
      dayNumber += 1;
      if (day.isEmpty) {
        penalty.cultural += 1.0;
        continue;
      }
      for (final keynoteSession in day.where((s) => s.isKeynote)) {
        // Keynotes should start days.
        penalty.cultural += day.indexOf(keynoteSession) * 2.0;
      }
      for (final excitingSession in day.where((s) => s.isExciting)) {
        penalty.awareness += day.indexOf(excitingSession) / 2;
      }
      for (final dayEndSession in day.where((s) => s.isDayEnd)) {
        // end_day sessions should end the day.
        penalty.constraints +=
            (day.length - day.indexOf(dayEndSession) - 1) * 2.0;
      }
      for (final otherDayPreferredSession in day.where(
          (s) => s.preferredDay != null && s.preferredDay != dayNumber)) {
        // Sessions should be scheduled for days they were tagged with (`day2`).
        penalty.constraints += 10.0;
      }
      // Only this many lunches per day. (Normally 1.)
      penalty.cultural +=
          (targetLunchesPerDay - day.where((s) => s.isLunch).length).abs() *
              10.0;
      // Keep the days not too long.
      penalty.awareness +=
          max(0, phenotype.getLength(day) - maxMinutesInDay) / 30;
    }

    for (final noFoodBlock
        in phenotype.getBlocksBetweenLargeMeal(ordered, sessions)) {
      if (noFoodBlock.isEmpty) continue;
      for (final energeticSession in noFoodBlock.where((s) => s.isEnergetic)) {
        // Energetic sessions should be just after food.
        penalty.awareness += noFoodBlock.indexOf(energeticSession) / 2;
      }
      penalty.hunger += max(0,
              phenotype.getLength(noFoodBlock) - maxMinutesWithoutLargeMeal) /
          20;
    }

    void penalizeSeekAvoid(Session a, Session b) {
      const denominator = 2;
      // Avoid according to tags.
      penalty.repetitiveness +=
          a.tags.where((tag) => b.avoid.contains(tag)).length / denominator;
      penalty.repetitiveness +=
          b.tags.where((tag) => a.avoid.contains(tag)).length / denominator;
      // Seek according to tags.
      penalty.harmony -=
          a.tags.where((tag) => b.seek.contains(tag)).length / denominator;
      penalty.harmony -=
          b.tags.where((tag) => a.seek.contains(tag)).length / denominator;
    }

    for (final block in phenotype.getBlocks(ordered, sessions)) {
      final blockLength = phenotype.getLength(block);
      // Avoid blocks that are too long.
      if (blockLength > maxMinutesWithoutBreak * 1.5) {
        // Block is way too long.
        penalty.awareness += blockLength - maxMinutesWithoutBreak;
      }
      penalty.awareness += max(0, blockLength - maxMinutesWithoutBreak) / 10;
      // Avoid blocks that are too short.
      penalty.cultural += max(0, minBlockLength - blockLength) / 10;
      for (final a in block) {
        for (final b in block) {
          if (a == b) continue;
          penalizeSeekAvoid(a, b);
        }
      }
    }

    for (final tuple in phenotype.getTuples(ordered, sessions)) {
      final a = tuple[0];
      final b = tuple[1];

      penalizeSeekAvoid(a, b);
    }

    // For two similar schedules, the one that needs less slots should win.
    penalty.awareness += phenotype.getLength(ordered) / 100;

    final baked = new BakedSchedule(ordered);
    // Penalize when last day is longer than previous days.
    final lastDay = baked.days[baked.days.length];
    for (int i = 1; i < baked.days.length; i++) {
      final diff = (baked.days[i].duration - lastDay.duration).inMinutes;
      if (diff > 0) {
        penalty.cultural += diff / 10;
      }
    }

    // Lunch hour should start at a culturally appropriate time.
    for (final bakedDay in baked.days.values) {
      for (final baked in bakedDay.list) {
        if (!baked.session.isLunch) continue;
        final distance = _getDistanceFromLunchHour(baked.time);
        penalty.cultural += distance.inMinutes.abs() / 20;
      }
    }

    // Penalize "hairy" session times (13:45 instead of 14:00).
    for (final day in baked.days.values) {
      for (final session in day.list) {
        if (session.time.minute % 30 != 0) {
          penalty.cultural += 0.01;
        }
      }
    }

    final usedOrderIndexes = new Set<int>();
    for (final order in phenotype.genes) {
      if (usedOrderIndexes.contains(order)) {
        // One index used multiple times.
        penalty.dna += 0.1;
      }
      usedOrderIndexes.add(order);
    }

    for (final evaluator in _customEvaluators) {
      evaluator(baked, penalty);
    }

    return penalty;
  }

  static Duration _getDistanceFromLunchHour(DateTime time) {
    final lunchTimeMin =
        new DateTime.utc(time.year, time.month, time.day, _lunchHourMin);
    final lunchTimeMax =
        new DateTime.utc(time.year, time.month, time.day, _lunchHourMax);
    if (time.isAfter(lunchTimeMin) && time.isBefore(lunchTimeMax) ||
        time == lunchTimeMin ||
        time == lunchTimeMax) {
      // Inside range.
      return const Duration();
    }
    if (time.isBefore(lunchTimeMin)) {
      return lunchTimeMin.difference(time);
    }
    if (time.isAfter(lunchTimeMax)) {
      return lunchTimeMax.difference(time);
    }
    throw new StateError("time has undefined relationship to lunchTimeMin"
        " and lunchTimeMax");
  }
}

class ScheduleEvaluatorPenalty extends FitnessResult {
  /// Penalty for breaking expectations, like lunch at 12pm.
  double cultural = 0.0;

  /// Penalty for breaking constraints, like "end first day at 6pm".
  double constraints = 0.0;

  double hunger = 0.0;

  double repetitiveness = 0.0;

  /// Mostly bonus (negative values) for things like session of the same
  /// theme appearing after each other.
  double harmony = 0.0;

  /// Penalty for straining audience focus, like "not starting with exciting
  /// session after lunch".
  double awareness = 0.0;

  /// Penalty for ambivalence or other problems in the chromosome.
  double dna = 0.0;

  /// Used for debugging only.
  // ignore: unused_field
  double _cachedEvaluate;

  @override
  bool dominates(ScheduleEvaluatorPenalty other) {
    return cultural < other.cultural &&
        constraints < other.constraints &&
        hunger < other.hunger &&
        repetitiveness < other.repetitiveness &&
        harmony < other.harmony &&
        awareness < other.awareness &&
        dna < other.dna;
  }

  double evaluate() {
    double result = 0.0;
    result += cultural;
    result += constraints;
    result += hunger;
    result += repetitiveness;
    result += harmony;
    result += awareness;
    result += dna;
    _cachedEvaluate = result;
    return result;
  }
}

/// A function that takes a [schedule] and modifies the [penalty].
///
/// These are used for specific rules pertaining to only one conference but
/// not generally applicable, such as that a particular conference's first day
/// must end as close to 6pm as possible.
typedef void CustomEvaluator(
    BakedSchedule schedule, ScheduleEvaluatorPenalty penalty);
