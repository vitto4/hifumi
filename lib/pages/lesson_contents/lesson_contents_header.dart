import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/widgets/overlays/sticky_header.dart";

/// This one is a little underwhelming.
class LessonContentsHeader extends StatelessWidget {
  final LessonNumber lesson;
  final Widget child;

  const LessonContentsHeader({
    Key? key,
    required this.lesson,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      color: LightTheme.blueishGrey,
      radius: 20.0,
      topPadding: .0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: FontSizes.huge,
            color: LightTheme.darkAccent,
          ),
        ),
      ),
      title: Text(
        "Lesson ${this.lesson}",
        style: const TextStyle(
          fontSize: FontSizes.big,
          fontWeight: FontWeight.bold,
          color: LightTheme.darkAccent,
        ),
      ),
      child: this.child,
    );
  }
}
