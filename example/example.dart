import 'package:conference_darwin/conference_darwin.dart';
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

  final evaluator = new ScheduleEvaluator(sessions, [dartConfEvaluators]);

  final breeder =
      new GenerationBreeder<Schedule, int, ScheduleEvaluatorPenalty>(
          () => new Schedule(sessions))
        ..fitnessSharingRadius = 0.5
        ..elitismCount = 1;

  final algo = new GeneticAlgorithm<Schedule, int, ScheduleEvaluatorPenalty>(
      firstGeneration, evaluator, breeder,
      printf: (_) {})
    ..MAX_EXPERIMENTS = 100000
    ..THRESHOLD_RESULT = new ScheduleEvaluatorPenalty();

  algo.onGenerationEvaluated.listen((gen) {
    if (algo.currentGeneration == 0) return;
    if (algo.currentGeneration % 100 != 0) return;

    printResults(gen, sessions);
  });

  await algo.runUntilDone();
  printResults(algo.generations.last, sessions);
}

void dartConfEvaluators(
    BakedSchedule schedule, ScheduleEvaluatorPenalty penalty) {
  final firstDay = schedule.days[1];
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
}

void printResults(Generation<Schedule, int, ScheduleEvaluatorPenalty> gen,
    List<Session> sessions) {
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
}
