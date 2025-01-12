import "package:flutter/material.dart";
import "package:hifumi/services/storage_interface.dart";
import "package:hifumi/widgets/drawer/auto_remove_section.dart";
import "package:hifumi/widgets/drawer/review_explanation_section.dart";
import "package:hifumi/widgets/drawer/word_filter_section.dart";
import "package:hifumi/widgets/drawer/word_count_section.dart";
import "package:hifumi/widgets/drawer/order_section.dart";
import "package:hifumi/widgets/drawer/deck_section.dart";

/// Quick settings sections that can be accessed using the arrow buttons on the home screen.
/// Contains two variants : [QuizQuickSettings] and [ReviewQuickSettings].

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

class ReviewQuickSettings extends StatelessWidget {
  final StorageInterface st;

  const ReviewQuickSettings({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const ReviewWhatIsThis(),
        const SizedBox(
          height: 20.0,
        ),
        DeckSection(
          st: st,
        ),
        const SizedBox(
          height: 20.0,
        ),
        AutoRemoveSection(st: st),
        const SizedBox(
          height: 20.0,
        ),
        DeckOrderSection(
          st: st,
        ),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}
