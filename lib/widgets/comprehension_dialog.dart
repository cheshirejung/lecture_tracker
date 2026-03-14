import 'package:flutter/material.dart';

class ComprehensionDialog extends StatefulWidget {
  final int lectureNumber;

  const ComprehensionDialog({super.key, required this.lectureNumber});

  @override
  State<ComprehensionDialog> createState() => _ComprehensionDialogState();
}

class _ComprehensionDialogState extends State<ComprehensionDialog> {
  int _selectedScore = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text('${widget.lectureNumber}강 완료'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('이해도를 선택해주세요'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final score = index + 1;
              return IconButton(
                icon: Icon(
                  score <= _selectedScore ? Icons.star : Icons.star_border,
                  color: score <= _selectedScore ? Colors.amber : Colors.grey,
                  size: 36,
                ),
                onPressed: () => setState(() => _selectedScore = score),
              );
            }),
          ),
          Text(
            '$_selectedScore / 5',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedScore),
          child: const Text('완료'),
        ),
      ],
    );
  }
}
