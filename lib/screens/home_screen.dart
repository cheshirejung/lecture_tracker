import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/storage_service.dart';
import 'course_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;

  const HomeScreen({super.key, required this.storageService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    setState(() {
      _courses = widget.storageService.getAllCourses();
    });
  }

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final countController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('강의 추가'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '강의명',
                    hintText: '예: 운영체제',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '강의명을 입력해주세요' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: countController,
                  decoration: InputDecoration(
                    labelText: '총 강의 수',
                    hintText: '예: 24',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '강의 수를 입력해주세요';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return '1 이상의 숫자를 입력해주세요';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null) {
                      dialogSetState(() => selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedDate != null
                                ? '${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')}'
                                : '목표 날짜 (선택사항)',
                            style: TextStyle(
                              color: selectedDate != null
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                  : Theme.of(context).colorScheme.outline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (selectedDate != null)
                          GestureDetector(
                            onTap: () {
                              dialogSetState(() => selectedDate = null);
                            },
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await widget.storageService.addCourse(
                    nameController.text.trim(),
                    int.parse(countController.text.trim()),
                    targetDate: selectedDate,
                  );
                  if (context.mounted) Navigator.pop(context);
                  _loadCourses();
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Course course) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CourseDetailScreen(
          storageService: widget.storageService,
          courseId: course.id,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
      ),
    ).then((_) => _loadCourses());
  }

  Color _getDDayChipColor(String dDayText) {
    if (dDayText == 'D-Day') return Colors.orange.shade50;
    if (dDayText.startsWith('D+')) return Colors.red.shade50;
    return Colors.indigo.shade50;
  }

  Color _getDDayTextColor(String dDayText) {
    if (dDayText == 'D-Day') return Colors.orange.shade700;
    if (dDayText.startsWith('D+')) return Colors.red.shade600;
    return Colors.indigo.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('강의 진도표'),
        centerTitle: true,
      ),
      body: _courses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 72,
                    color: colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '등록된 강의가 없습니다',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _showAddCourseDialog,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('강의 추가하기'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToDetail(course),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              if (course.dDayText != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        _getDDayChipColor(course.dDayText!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    course.dDayText!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _getDDayTextColor(
                                              course.dDayText!),
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: course.completionPercent / 100,
                              minHeight: 10,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${course.completedCount}/${course.totalLectures}강 완료',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                '${course.completionPercent.toStringAsFixed(0)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
