import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/widgets/archipelago/island_container.dart";

/// This one is a little underwhelming.
class WordListTopBar extends StatelessWidget {
  final LessonNumber lesson;
  final Widget child;

  const WordListTopBar({
    Key? key,
    required this.lesson,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: LightTheme.darkAccent,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatIslandContainer(
                      backgroundColor: LightTheme.baseAccent,
                      borderColor: LightTheme.lightAccent,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 3.0, 12.0, 3.0),
                        child: Text(
                          "Lesson ${this.lesson}",
                          style: const TextStyle(
                            fontSize: FontSizes.big,
                            fontWeight: FontWeight.bold,
                            color: LightTheme.darkAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
        this.child,
      ],
    );
  }
}
