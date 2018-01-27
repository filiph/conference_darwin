/// Schedule with exact times.
import 'dart:collection';

import 'package:conference_darwin/src/session.dart';

typedef StartTimeGenerator = DateTime Function(int dayNumber);

/// An unmodifiable instance of a scheduled day.
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

/// An unmodifiable instance of schedule. This is used by evaluators instead
/// of the Schedule phenotype for convenience.
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

  /// Start at 10am by default. Use DartConf's date (we don't care about the
  /// date so it doesn't really matter yet).
  static DateTime _defaultGenerateStartTime(int dayNumber) {
    return new DateTime.utc(2018, 1, 20 + dayNumber, 10);
  }
}

/// An unmodifiable instance of a scheduled session. Includes the [Session]
/// itself as well as the [time] for which it is scheduled.
class BakedSession {
  final DateTime time;
  final Session session;

  BakedSession(this.time, this.session);
}
