import 'package:hive/hive.dart';

part 'lecture.g.dart';

@HiveType(typeId: 1)
class Lecture {
  @HiveField(0)
  int number;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  int comprehensionScore;

  Lecture({
    required this.number,
    this.isCompleted = false,
    this.comprehensionScore = 0,
  });
}
