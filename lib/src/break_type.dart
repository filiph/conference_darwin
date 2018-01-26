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

enum BreakType { none, short, lunch, day }
