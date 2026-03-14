import 'package:hive_flutter/hive_flutter.dart';
import '../models/course.dart';
import '../models/lecture.dart';

class StorageService {
  static const String _courseBoxName = 'courses';
  late Box<Course> _courseBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CourseAdapter());
    Hive.registerAdapter(LectureAdapter());
    _courseBox = await Hive.openBox<Course>(_courseBoxName);
  }

  List<Course> getAllCourses() {
    return _courseBox.values.toList();
  }

  Future<Course> addCourse(String name, int totalLectures,
      {DateTime? targetDate}) async {
    final course = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      totalLectures: totalLectures,
      targetDate: targetDate,
    );
    await _courseBox.put(course.id, course);
    return course;
  }

  Future<void> deleteCourse(String courseId) async {
    await _courseBox.delete(courseId);
  }

  Course? getCourse(String courseId) {
    return _courseBox.get(courseId);
  }

  Future<void> toggleLecture(
    String courseId,
    int lectureIndex,
    bool completed,
    int comprehensionScore,
  ) async {
    final course = _courseBox.get(courseId);
    if (course == null) return;

    course.lectures[lectureIndex].isCompleted = completed;
    course.lectures[lectureIndex].comprehensionScore =
        completed ? comprehensionScore : 0;
    await course.save();
  }
}
