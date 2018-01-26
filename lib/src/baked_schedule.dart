/// Schedule with exact times.
import 'dart:collection';

import 'package:conference_darwin/src/session.dart';

typedef StartTimeGenerator = DateTime Function(int dayNumber);

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
