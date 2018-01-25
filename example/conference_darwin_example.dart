import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:darwin/darwin.dart';

main() async {
  const flutter = "flutter",
      energetic = "energetic",
      demo = "demo",
      angulardart = "angulardart",
      platform = "platform",
      deepdive = "deepdive",
      keynote = "keynote",
      day_end = "day_end",
      tooling = "tooling",
      architecture = "architecture",
      third_party = "third_party",
      exciting = "exciting",
      day1 = "day1",
      day2 = "day2",
      flutter_main = "flutter_main",
      angulardart_main = "angulardart_main",
      after_flutter_main = "after_flutter_main",
      after_angulardart_main = "after_angulardart_main",
      flutter_fast = "flutter_fast",
      after_flutter_fast = "after_flutter_fast",
      codeshare = "codeshare",
      after_dart_main = "after_dart_main",
      dart_main = "dart_main",
      apptree = "apptree",
      after_apptree = "after_apptree";

  final sessions = <Session>[
    new Session('Let’s live code in Flutter', 30,
        tags: [flutter, energetic, demo, exciting, flutter_main],
        avoid: [demo],
        seek: []),
    new Session('Flutter / Angular code sharing deep dive', 30, tags: [
      flutter,
      angulardart,
      platform,
      deepdive,
      after_flutter_main,
      after_angulardart_main,
      codeshare,
      after_apptree
    ], avoid: [
      deepdive,
      codeshare
    ], seek: []),
    new Session('How to build good packages and plugins ', 30,
        tags: [platform], avoid: [], seek: []),
    new Session('Keynote ', 45,
        tags: [keynote, platform, energetic, exciting, day1],
        avoid: [deepdive],
        seek: []),
    new Session('Unconference ', 120,
        tags: [day_end, day2], avoid: [], seek: []),
    new Session(
        'Faisal Abid: From Zero to One - Building a real world Flutter Application',
        30,
        tags: [
          flutter,
          architecture,
          third_party,
          after_flutter_main,
          after_angulardart_main
        ],
        avoid: [
          keynote
        ],
        seek: [
          flutter
        ]),
    new Session('Making Dart fast on mobile', 30,
        tags: [platform, flutter, deepdive, flutter_fast, after_dart_main],
        avoid: [deepdive],
        seek: [flutter]),
    new Session('AngularDart: architecting for size and speed ', 30, tags: [
      angulardart,
      architecture,
      deepdive,
      angulardart_main,
      after_dart_main
    ], avoid: [
      architecture,
      deepdive
    ], seek: []),
    new Session(
        'Brian Egan: Keep it Simple, State: Architecture for Flutter Apps', 30,
        tags: [
          flutter,
          architecture,
          third_party,
          deepdive,
          after_flutter_main,
          after_flutter_fast
        ],
        avoid: [
          architecture,
          third_party,
          deepdive
        ],
        seek: [
          flutter
        ]),
    new Session('Dart language — what we’re working on right now ', 30,
        tags: [platform, exciting, day1, dart_main],
        avoid: [],
        seek: [platform]),
    new Session('Effective Dart + IntelliJ ', 30,
        tags: [platform, tooling], avoid: [keynote], seek: []),
    new Session(
        'TrustWave: Power of AngularDart and Trustwave’s Customer Portal', 30,
        tags: [angulardart, third_party, after_angulardart_main],
        avoid: [keynote],
        seek: [angulardart]),
    new Session('Flutter Inspector ', 30,
        tags: [flutter, tooling, exciting, after_flutter_main],
        avoid: [],
        seek: []),
    new Session('Lightning talks ', 90,
        tags: [day_end, day1], avoid: [], seek: []),
    new Session('Eugenio: Save/restore library', 30, tags: [
      flutter,
      architecture,
      deepdive,
      third_party,
      after_flutter_main,
      after_flutter_fast,
      after_dart_main
    ], avoid: [
      architecture,
      third_party,
      keynote
    ], seek: [
      flutter
    ]),
    new Session('AppTree: Flutter & Web - Unite your code and your teams.', 30,
        tags: [
          flutter,
          architecture,
          codeshare,
          third_party,
          after_flutter_main,
          after_dart_main,
          apptree
        ],
        avoid: [
          architecture,
          third_party,
          keynote,
          codeshare
        ],
        seek: [
          flutter,
          platform
        ]),
  ];

  final firstGeneration =
      new Generation<Schedule, int, ScheduleEvaluatorPenalty>()
        ..members.addAll(
            new List.generate(200, (_) => new Schedule.random(sessions)));

  final evaluator = new ScheduleEvaluator(sessions);

  final breeder =
      new GenerationBreeder<Schedule, int, ScheduleEvaluatorPenalty>(
          () => new Schedule(sessions))
        ..fitnessSharingRadius = 0.5
        ..elitismCount = 1;

  final algo = new GeneticAlgorithm<Schedule, int, ScheduleEvaluatorPenalty>(
      firstGeneration, evaluator, breeder,
      printf: (_) {})
    ..MAX_EXPERIMENTS = 1001000
    ..THRESHOLD_RESULT = new ScheduleEvaluatorPenalty();

//  for (int i = 0; i < 30; i++) {
//    print("");
//  }
//
//  int i=1;
//  algo.onGenerationEvaluated.listen((ev) {
//    print("${i++}, ${ev.bestFitness}, ${ev.averageFitness}");
////    final string = (ev.best as Schedule).generateSchedule(sessions);
////    final lines = "\n".allMatches(string).length;
////    print("\tGENERATION #$i BEST SPECIMEN:\n");
////    print(string);
////    final fill = 30 - lines;
////    for (int i = 0; i < fill; i++) {
////      print("");
////    }
////    sleep(new Duration(milliseconds: 500 ~/ i++));
//  });

  algo.onGenerationEvaluated.listen((gen) {
    if (algo.currentGeneration == 0) return;
    if (algo.currentGeneration % 1000 != 0) return;

    final lastGeneration = new List<Schedule>.from(gen.members);
    lastGeneration.sort();
    for (int i = 0; i < lastGeneration.length; i++) {
      final specimen = lastGeneration[i];
      print("======= Winner $i ("
          "pareto rank ${specimen.result.paretoRank} "
          "fitness ${specimen.result.evaluate().toStringAsFixed(2)} "
          "shared ${specimen.resultWithFitnessSharingApplied.toStringAsFixed(2)} "
          ") ====");
      print("${specimen.genesAsString}");
      print(specimen.generateSchedule(sessions));
    }
  });

  await algo.runUntilDone();
}

String printBreakType(BreakType type) {
  switch (type) {
    case BreakType.none:
      return "";
    case BreakType.short:
      return "-- short break --";
    case BreakType.lunch:
      return "== lunch break ==";
    case BreakType.day:
      return "+++++ DAY BREAK +++++";
  }
  throw new StateError("No such type: $type");
}

class BakedDay {
  final List<BakedSession> _list = new List<BakedSession>();

  UnmodifiableListView<BakedSession> _listView;

  BakedDay() {
    _listView = new UnmodifiableListView<BakedSession>(_list);
  }

  Duration get duration {
    final start = _list.first.time;
    return start.difference(end);
  }

  DateTime get end =>
      _list.last.time.add(new Duration(minutes: _list.last.session.length));

  UnmodifiableListView<BakedSession> get list => _listView;

  void _add(BakedSession session) => _list.add(session);
}

/// Schedule with exact times.
class BakedSchedule {
  final List<BakedSession> _list = new List<BakedSession>();

  final Map<int, BakedDay> _days = new Map<int, BakedDay>();

  UnmodifiableListView _listView;

  UnmodifiableMapView<int, BakedDay> _unmodifiableDays;

  final StartTimeGenerator _startTimeGenerator;

  BakedSchedule(List<Session> ordered,
      {DateTime generateStartTime(int dayNumber)})
      : _startTimeGenerator = generateStartTime ?? _defaultGenerateStartTime {
    _fillList(ordered);
    _listView = new UnmodifiableListView(_list);
    _unmodifiableDays = new UnmodifiableMapView<int, BakedDay>(_days);
  }

  /// Can be seen as 1-based list of days (first day is `days[1]`).
  UnmodifiableMapView<int, BakedDay> get days => _unmodifiableDays;

  UnmodifiableListView<BakedSession> get list => _listView;

  void _fillList(List<Session> ordered) {
    var dayNumber = 1;
    var time = _startTimeGenerator(dayNumber);
    for (final session in ordered) {
      final baked = new BakedSession(time, session);
      _list.add(baked);
      _days.putIfAbsent(dayNumber, () => new BakedDay())._add(baked);
      time = time.add(new Duration(minutes: session.length));
      if (session.isDayBreak) {
        dayNumber += 1;
        time = _startTimeGenerator(dayNumber);
      }
    }
  }

  static DateTime _defaultGenerateStartTime(int dayNumber) {
    return new DateTime.utc(2018, 1, 20 + dayNumber, 10);
  }
}

class BakedSession {
  final DateTime time;
  final Session session;

  BakedSession(this.time, this.session);
}

/// A value that distinguishes between major increments and minor ones.
class BoundValue {
  static const maxProblemsPerLevel = 99;

  static const double levelMultiplier = 10.0;

  final Map<int, int> _problems = {};

  double get value {
    double result = 0.0;
    for (final level in _problems.keys) {
      final problems = min(_problems[level], maxProblemsPerLevel);
      if (problems == 0) continue;
      final levelSpan = _getLevelSpan(level);
      final addition = (problems / maxProblemsPerLevel) * levelSpan;
      result += addition;
    }
    return result;
  }

  operator +(num next) {
    if (next == 0) return this;
    final level = _getLevelOfValue(next);
    final magnitude = _getProblemMagnitude(next, level);
    _problems[level] = _problems.putIfAbsent(level, () => 0) + magnitude;
    return this;
  }

  operator -(num next) {
    if (next == 0) return this;
    final level = _getLevelOfValue(next);
    final magnitude = _getProblemMagnitude(next, level);
    _problems[level] = _problems.putIfAbsent(level, () => 0) - magnitude;
    return this;
  }

  int _getLevelOfValue(num val) {
    var level = 0;
    while (val >= pow(levelMultiplier, level)) {
      level += 1;
    }
    return level;
  }

  double _getLevelSpan(int level) {
    final levelLow = pow(levelMultiplier, level - 1);
    final levelHigh = pow(levelMultiplier, level);
    return levelHigh - levelLow;
  }

  int _getProblemMagnitude(num next, int level) {
    final levelLow = pow(levelMultiplier, level - 1);
    final levelSpan = _getLevelSpan(level);
    assert(next >= levelLow, "number was $next, level $level");
    assert(next <= levelLow + levelSpan);
    final nextSpan = next - levelLow;
    final magnitude = nextSpan / levelSpan * maxProblemsPerLevel;

    // We add 1 because even 10.0 should add a problem.
    return magnitude.round() + 1;
  }
}

enum BreakType { none, short, lunch, day }

typedef StartTimeGenerator = DateTime Function(int dayNumber);

class Schedule extends Phenotype<int, ScheduleEvaluatorPenalty> {
  static const int defaultSessionsPerDay = 10;

  static const int defaultSessionsBetweenBreaks = 3;

  final int sessionCount;

  final int maxShortBreaksCount;

  final int maxLunchBreaksCount;

  final int maxExtendedLunchBreaksCount;

  final int maxDayBreaksCount;

  final int orderRange;

  /// Order above this value will not appear in the program.
  final int orderRangeCutOff;

  int _geneCount;

  final _random = new Random();

  Schedule(List<Session> sessions)
      : sessionCount = sessions.length,
        maxDayBreaksCount =
            (sessions.length / defaultSessionsPerDay).ceil() - 1,
        maxLunchBreaksCount = (sessions.length / defaultSessionsPerDay).ceil(),
        maxExtendedLunchBreaksCount = 0,
        maxShortBreaksCount =
            (sessions.length / defaultSessionsBetweenBreaks).ceil(),
        orderRange = sessions.length * 6,
        orderRangeCutOff = sessions.length * 5 {
    _geneCount = sessionCount +
        maxDayBreaksCount +
        maxLunchBreaksCount +
        maxExtendedLunchBreaksCount +
        maxShortBreaksCount;
  }

  factory Schedule.random(List<Session> sessions) {
    final schedule = new Schedule(sessions);
    schedule.genes = new List<int>(schedule._geneCount);
    for (int i = 0; i < schedule._geneCount; i++) {
      schedule.genes[i] = schedule._random.nextInt(schedule.orderRange);
    }
    return schedule;
  }

  bool operator ==(other) {
    if (other is! Schedule) return false;
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode {
    return genes.hashCode;
  }

  @override
  num computeHammingDistance(Schedule other) {
    int aLast = -1;
    int bLast = -1;
    int differences = 0;
    bool aFound;
    bool bFound;
    do {
      aFound = false;
      bFound = false;
      int aBestCandidateValue = orderRange * 1000;
      int bBestCandidateValue = orderRange * 1000;
      int aBestCandidateIndex;
      int bBestCandidateIndex;
      // go through all genes and find the current lowest one
      for (int i = 0; i < _geneCount; i++) {
        final aCurrent = genes[i];
        if (aLast < aCurrent && aCurrent < aBestCandidateValue) {
          aBestCandidateValue = aCurrent;
          aBestCandidateIndex = i;
          aFound = true;
        }
        final bCurrent = other.genes[i];
        if (bLast < bCurrent && bCurrent < bBestCandidateValue) {
          bBestCandidateValue = bCurrent;
          bBestCandidateIndex = i;
          bFound = true;
        }
      }
      if (aFound || bFound) {
        if (aBestCandidateIndex != bBestCandidateIndex) {
          // Add a difference when the value was on a different index.
          differences += 1;
        }
        if (aFound) {
          aLast = aBestCandidateValue;
        }
        if (bFound) {
          bLast = bBestCandidateValue;
        }
      }
    } while (aFound || bFound);

    assert(differences <= _geneCount);

    return differences / _geneCount;
  }

  String generateSchedule(List<Session> sessions) {
    final ordered = getOrdered(sessions);
    final baked = new BakedSchedule(ordered);
    final buf = new StringBuffer();

    for (final slot in baked.list) {
      // final index = sessions.indexOf(session);
      // int scheduleOrder = null;
      // if (index != -1) {
      //   scheduleOrder = genes[index];
      // }

      buf.write("\t");
      final hour = slot.time.hour;
      final minute = slot.time.minute.toString().padLeft(2, '0');
      buf.write("$hour:$minute");
      buf.write("\t");
      buf.write(slot.session.name);
      buf.write("\t");
      buf.write(slot.session.length);
      buf.writeln();
    }
    return buf.toString();
  }

  Iterable<List<Session>> getBlocks(
      List<Session> ordered, List<Session> sessions) sync* {
    var block = <Session>[];
    for (final session in ordered) {
      if (session.isBreak) {
        yield block;
        block = <Session>[];
        continue;
      }
      block.add(session);
    }
    yield block;
  }

  Iterable<List<Session>> getBlocksBetweenLargeMeal(
      List<Session> ordered, List<Session> sessions) sync* {
    var block = <Session>[];
    for (final session in ordered) {
      if (session.isLunch || session.isDayBreak) {
        yield block;
        block = <Session>[];
        continue;
      }
      block.add(session);
    }
    yield block;
  }

  Iterable<List<Session>> getDays(
      List<Session> ordered, List<Session> sessions) sync* {
    var day = <Session>[];
    for (final session in ordered) {
      if (session.isDayBreak) {
        yield day;
        day = <Session>[];
        continue;
      }
      day.add(session);
    }
    yield day;
  }

  int getLength(Iterable<Session> sessions) {
    int length = 0;
    for (final session in sessions) {
      length += session.length;
    }
    return length;
  }

  List<Session> getOrdered(List<Session> original) {
    int geneIndex = 0;
    // Maps sessions to their order.
    final allSessions = new Map<Session, int>();
    for (int i = 0; i < original.length; i++) {
      allSessions[original[i]] = genes[geneIndex];
      geneIndex += 1;
    }
    for (int i = 0; i < maxShortBreaksCount; i++) {
      final shortBreak = new Session.defaultShortBreak();
      allSessions[shortBreak] = genes[geneIndex];
      geneIndex += 1;
    }
    for (int i = 0; i < maxLunchBreaksCount; i++) {
      final lunch = new Session.defaultLunch();
      allSessions[lunch] = genes[geneIndex];
      geneIndex += 1;
    }
    for (int i = 0; i < maxExtendedLunchBreaksCount; i++) {
      final lunch = new Session.defaultExtendedLunch();
      allSessions[lunch] = genes[geneIndex];
      geneIndex += 1;
    }
    for (int i = 0; i < maxDayBreaksCount; i++) {
      final dayBreak = new Session.defaultDayBreak();
      allSessions[dayBreak] = genes[geneIndex];
      geneIndex += 1;
    }
    final ordered = new List<Session>.from(
        allSessions.keys.where((key) => allSessions[key] < orderRangeCutOff));
    ordered.sort((a, b) => allSessions[a].compareTo(allSessions[b]));
    return ordered;
  }

  /// Returns an iterable of doubles - sessions that are next to each
  /// other with no break between.
  Iterable<List<Session>> getTuples(
      List<Session> ordered, List<Session> sessions) sync* {
    for (int i = 1; i < ordered.length; i++) {
      final a = ordered[i - 1];
      final b = ordered[i];
      yield [a, b];
    }
  }

  @override
  int mutateGene(int gene, num strength) {
    int maxDiff = (orderRange * strength).round();
    int diff = _random.nextInt(maxDiff) - (orderRange ~/ 2);
    return (gene + diff) % orderRange;
  }
}

class ScheduleEvaluator
    extends PhenotypeEvaluator<Schedule, int, ScheduleEvaluatorPenalty> {
  static const _lunchHourMin = 12;

  static const _lunchHourMax = 13;

  final List<Session> sessions;

  final int targetDays = 2;

  /// Minimal amount of time between breaks.
  final int minBlockLength = 90;

  final int maxMinutesWithoutBreak = 90;

  final int maxMinutesWithoutLargeMeal = 5 * 60;

  final int maxMinutesInDay = 8 * 60;

  final int targetLunchesPerDay = 1;

  ScheduleEvaluator(this.sessions);

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

    // TODO: move these to "special evaluating functions" - too specific
    //       to DartConf.
    final firstDay = baked.days[1];
    if (firstDay != null) {
      // Penalize for not ending first day at 6pm.
      final firstDayTargetEnd = new DateTime.utc(
          firstDay.end.year, firstDay.end.month, firstDay.end.day, 18);
      penalty.constraints +=
          firstDay.end.difference(firstDayTargetEnd).inMinutes.abs() / 10;

      // Penalize for too much Flutter in the first block.
      final firstBlock = firstDay.list.takeWhile((s) => !s.session.isBreak);
      if (firstBlock.every((s) => s.session.tags.contains("flutter"))) {
        penalty.repetitiveness += 0.5;
      }
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

  /// Used for debugging only.
  double _cachedEvaluate;

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

class Session {
  static final RegExp _dayPreferencePattern = new RegExp(r"^day(\d+)$");
  final String name;
  final Set<String> tags;
  final Set<String> avoid;
  final Set<String> seek;

  final int length;

  Session(this.name, this.length,
      {Iterable<String> tags: const [],
      Iterable<String> avoid: const [],
      Iterable<String> seek: const []})
      : tags = new Set.from(tags),
        avoid = new Set.from(avoid),
        seek = new Set.from(seek);

  Session.defaultDayBreak()
      : this(printBreakType(BreakType.day), 0,
            tags: ["day_break", "break"], avoid: ["break"]);

  Session.defaultExtendedLunch()
      : this(printBreakType(BreakType.lunch), 60 + 15,
            tags: ["lunch", "break"], avoid: ["break"]);

  Session.defaultLunch()
      : this(printBreakType(BreakType.lunch), 60,
            tags: ["lunch", "break"], avoid: ["break"]);

  Session.defaultShortBreak()
      : this(printBreakType(BreakType.short), 30,
            tags: ["break"], avoid: ["break"]);

  bool get isBreak => tags.contains("break");

  bool get isDayBreak => tags.contains("day_break");

  /// Algorithm will try hard to put `day_end` talks at end of day. Use
  /// for things like lightning talks / unconferences / wrap-ups.
  bool get isDayEnd => tags.contains("day_end");

//  /// Algorithm will try to not schedule deep dives after breaks or lunches.
//  bool get isDeepDive => tags.contains("deepdive");

  /// Algorithm will try to schedule exciting talks after food (or at start
  /// of day) to get people going.
  bool get isEnergetic => tags.contains("energetic");

  /// Algorithm will try to schedule exciting talks at start of day so they're
  /// not wasted in the middle of unimpressive talks.
  ///
  /// Or at least starts of blocks. (TODO)
  bool get isExciting => tags.contains("exciting");

  /// Algorithm will try hard to put keynote at start of day 1 or at least
  /// at start of a day.
  bool get isKeynote => tags.contains("keynote");

  bool get isLunch => tags.contains("lunch");

  /// Returns the preferred day as specified by a [tag] (like `day1` or `day2`).
  /// Returns `null` when no day is preferred.
  int get preferredDay {
    for (final tag in tags) {
      final match = _dayPreferencePattern.firstMatch(tag);
      if (match == null) continue;
      return int.parse(match.group(1));
    }
    return null;
  }

  bool shouldComeAfter(Session other) {
    for (final tag in tags) {
      for (final otherTag in other.tags) {
        if (tag == "after_$otherTag") return true;
      }
    }
    return false;
  }

  @override
  String toString() => "$name ($length m)";
}
