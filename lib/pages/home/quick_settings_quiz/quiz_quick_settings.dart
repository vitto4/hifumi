import 'package:flutter/material.dart';
import 'package:hifumi/services/storage_interface.dart';
import 'package:hifumi/pages/home/quick_settings_quiz/word_count_section.dart';
import 'package:hifumi/pages/home/quick_settings_quiz/word_filter_section.dart';

/// Quick settings section that can be accessed using the arrow button on the home screen.
class QuizQuickSettings extends StatelessWidget {
  final StorageInterface st;

  const QuizQuickSettings({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 10.0,
        ),
        WordCountSection(
          st: st,
        ),
        const SizedBox(
          height: 20.0,
        ),
        WordFilterSection(
          st: st,
        ),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}
