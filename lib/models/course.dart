import 'package:hive/hive.dart';
import 'lecture.dart';

part 'course.g.dart';

@HiveType(typeId: 0)
class Course extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int totalLectures;

  @HiveField(3)
  List<Lecture> lectures;

  @HiveField(4)
  DateTime? targetDate;

  Course({
    required this.id,
    required this.name,
    required this.totalLectures,
    List<Lecture>? lectures,
    this.targetDate,
  }) : lectures = lectures ??
            List.generate(
              totalLectures,
              (i) => Lecture(number: i + 1),
            );

  int get completedCount => lectures.where((l) => l.isCompleted).length;

  double get completionPercent =>
      totalLectures == 0 ? 0.0 : (completedCount / totalLectures) * 100.0;

  double get averageComprehension {
    final completed = lectures.where((l) => l.isCompleted).toList();
    if (completed.isEmpty) return 0.0;
    final sum = completed.fold<int>(0, (s, l) => s + l.comprehensionScore);
    return sum / completed.length;
  }

  String get averageComprehensionText {
    final avg = averageComprehension;
    if (avg == avg.toInt().toDouble()) {
      return avg.toInt().toString();
    }
    return avg.toStringAsFixed(1);
  }

  String? get dDayText {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(targetDate!.year, targetDate!.month, targetDate!.day);
    final diff = target.difference(today).inDays;
    if (diff > 0) return 'D-$diff';
    if (diff == 0) return 'D-Day';
    return 'D+${diff.abs()}';
  }
}
