# conference_darwin

A library for building conference schedules using a genetic algorithm.
Read more about the motivations and goals of this project in
_[Using a Genetic Algorithm to Optimize Developer Conference Schedules][article]_.

![An animated gif of an evolving schedule](https://cdn-images-1.medium.com/max/1600/1*QCT2lcFpb9ddS1LJxqKUEg.gif)

[article]: https://medium.com/@filiph/using-a-genetic-algorithm-to-optimize-developer-conference-schedules-27f13d97fa9a

## Usage

The project contains an example (the exact code that scheduled DartConf 2018).
Clone this repository, `cd` to the directory, and run the algorithm like this:

```bash
dart example/example.dart
```

This will run for ~30 minutes (but will print out each 1000 generation). You can
modify `example/example.dart` to run less generations and/or print out results
more often.

When ready, copy-paste or create your own executable (by convention 
in `bin/something.dart`). You mainly want to change the list of available 
sessions, and the list of custom evaluators.

```dart
final evaluator = new ScheduleEvaluator(yourSessions, [yourEvaluators]);
```

You might not need to touch the rest of the code.

Sessions are provided in a list, with each session looking something like this:

```dart
new Session('Making Dart fast on mobile', 30,
    tags: ["flutter", "deepdive", "day1" "after_dart_main"],
    avoid: ["deepdive", "keynote"],
    seek: ["flutter"]),
```

The session above takes 30 minutes. The tags are all optional and tell 
the algorithm what the topics are (Flutter in this case), 
what's the style (deepdive), which day to schedule for (first) and which
talks are required to come before it (everything tagged with `"dart_main"`).
Look at `lib/src/session.dart` for a complete documentation of tags which 
have special meaning (e.g. `"energetic"`, `"exciting"`, `"day_end"`, 
`"keynote"`). 

When organizing the conference, you will probably want to keep your talks
in a spreadsheet like this:

| DartConf 2018 program                    | Time needed | Tags                                     | Avoid neighbors        | Seek neighbors |
| ---------------------------------------- | ----------- | ---------------------------------------- | ---------------------- | -------------- |
| Let’s live code in Flutter               | 30          | flutter, energetic, demo, exciting, flutter_main | demo                   |                |
| Flutter / Angular code sharing deep dive | 30          | flutter, angulardart, platform, deepdive, after_flutter_main, after_angulardart_main, codeshare, after_apptree | deepdive, codeshare    |                |
| How to build good packages and plugins   | 30          | platform                                 |                        |                |
| Keynote                                  | 45          | keynote, platform, energetic, exciting, day1 | deepdive               |                |
| Unconference                             | 120         | day_end, day2                            |                        |                |
| Making Dart fast on mobile               | 30          | platform, flutter, deepdive, flutter_fast, after_dart_main | deepdive               | flutter        |
| What's new with AngularDart              | 30          | angulardart, architecture, deepdive, angulardart_main, after_dart_main | architecture, deepdive |                |
| Dart language — what we’re working on    | 30          | platform, exciting, day1, dart_main      |                        | platform       |
| Effective Dart + IntelliJ                | 30          | platform, tooling                        | keynote                |                |

It is then easy to generate the `new Schedule(...)` code ahead via a simple
spreadsheet formula. Here's the one I used:

```
="new Session('"&A2&"', "&D2&", tags: ["&K2&"], avoid: ["&L2&"], seek: ["&M2&"]),"
```

When you're ready to run the scheduling algorithm again, just copy paste
the row containing the formula into your Dart file, between the session 
brackets.

```dart
final sessions = <Session>[
  // copy-paste here
];
```

Of course it's perfectly possible to modify your script to do this 
automatically (e.g. through [`package:googleapis`][googleapis] if you're using
Google Spreadsheets or through a database connector if you track your 
WIP program in a database). You can even plug this into your 
continuous integration and have your schedule auto-regenerated any time the 
inputs change. 

[googleapis]: https://pub.dartlang.org/packages/googleapis
