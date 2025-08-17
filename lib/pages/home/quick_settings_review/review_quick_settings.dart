import "package:flutter/material.dart";
import "package:hifumi/services/storage_interface.dart";
import "package:hifumi/pages/home/quick_settings_review/endless_section.dart";
import "package:hifumi/pages/home/quick_settings_review/review_explanation_section.dart";
import "package:hifumi/pages/home/quick_settings_review/order_section.dart";
import "package:hifumi/pages/home/quick_settings_review/deck_section.dart";

/// Quick settings section that can be accessed using the arrow button on the home screen.
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
        EndlessModeSection(st: st),
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
