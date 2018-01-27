import 'package:conference_darwin/src/break_type.dart';

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
