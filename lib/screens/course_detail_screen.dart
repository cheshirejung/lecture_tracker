import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/storage_service.dart';
import '../widgets/comprehension_dialog.dart';

class CourseDetailScreen extends StatefulWidget {
  final StorageService storageService;
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.storageService,
    required this.courseId,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Course? _course;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  void _loadCourse() {
    setState(() {
      _course = widget.storageService.getCourse(widget.courseId);
    });
  }

  Color _comprehensionColor(int score) {
    switch (score) {
      case 1:
        return const Color(0xFFFFCDD2); // 연한 빨강
      case 2:
        return const Color(0xFFFFE0B2); // 연한 주황
      case 3:
        return const Color(0xFFFFF9C4); // 연한 노랑
      case 4:
        return const Color(0xFFB2DFDB); // 연한 청록
      case 5:
        return const Color(0xFFBBDEFB); // 연한 파랑
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Color _comprehensionBorderColor(int score) {
    switch (score) {
      case 1:
        return const Color(0xFFEF9A9A);
      case 2:
        return const Color(0xFFFFCC80);
      case 3:
        return const Color(0xFFFFF176);
      case 4:
        return const Color(0xFF80CBC4);
      case 5:
        return const Color(0xFF90CAF9);
      default:
        return Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);
    }
  }

  Future<void> _onLectureTap(int index) async {
    final lecture = _course!.lectures[index];

    if (lecture.isCompleted) {
      await widget.storageService.toggleLecture(
        widget.courseId,
        index,
        false,
        0,
      );
      _loadCourse();
      return;
    }

    final score = await showDialog<int>(
      context: context,
      builder: (_) => ComprehensionDialog(lectureNumber: index + 1),
    );

    if (score != null) {
      await widget.storageService.toggleLecture(
        widget.courseId,
        index,
        true,
        score,
      );
      _loadCourse();
    }
  }

  void _deleteCourse(Course course) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('강의 삭제'),
        content: Text("'${course.name}'을(를) 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () async {
              await widget.storageService.deleteCourse(course.id);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_course == null) {
      return const Scaffold(
        body: Center(child: Text('강의를 찾을 수 없습니다')),
      );
    }

    final course = _course!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '강의 삭제',
            onPressed: () => _deleteCourse(course),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: course.completionPercent / 100,
                      minHeight: 10,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${course.completedCount}/${course.totalLectures} (${course.completionPercent.toStringAsFixed(0)}%)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (course.completedCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insights, color: Colors.indigo, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '평균 이해도: ${course.averageComprehensionText} / 5',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          // 색상 범례
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++) ...[
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _comprehensionColor(i),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _comprehensionBorderColor(i),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$i',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (i < 5) const SizedBox(width: 12),
                ],
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: course.totalLectures,
              itemBuilder: (context, index) {
                final lecture = course.lectures[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onLectureTap(index),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: lecture.isCompleted
                            ? _comprehensionColor(lecture.comprehensionScore)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: lecture.isCompleted
                              ? _comprehensionBorderColor(
                                  lecture.comprehensionScore)
                              : colorScheme.outline.withValues(alpha: 0.2),
                          width: lecture.isCompleted ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${lecture.number}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: lecture.isCompleted
                                  ? Colors.black87
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                          if (lecture.isCompleted) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${lecture.comprehensionScore}점',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
