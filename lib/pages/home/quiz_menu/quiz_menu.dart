import 'package:flutter/material.dart';
import 'package:hifumi/pages/home/quiz_menu/quiz_explanation_section.dart';
import 'package:hifumi/services/sp_interface.dart';
import 'package:hifumi/pages/home/quiz_menu/word_count_section.dart';
import 'package:hifumi/pages/home/quiz_menu/word_filter_section.dart';

/// Quick settings menu that can be accessed using the arrow button on the home screen.
class QuizMenu extends StatelessWidget {
  final SPInterface st;

  const QuizMenu({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        QuizWhatIsThis(
          st: st,
        ),
        const SizedBox(
          height: 20.0,
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
