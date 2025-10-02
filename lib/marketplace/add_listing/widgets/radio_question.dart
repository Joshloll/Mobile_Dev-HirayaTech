import 'package:flutter/material.dart';

class RadioQuestion extends StatelessWidget {
  final String question;
  final bool? groupValue;
  final ValueChanged<bool?> onChanged;

  const RadioQuestion({
    super.key,
    required this.question,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Yes'),
                value: true,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: const Color(0xFF3A86FF),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('No'),
                value: false,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: const Color(0xFF3A86FF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}