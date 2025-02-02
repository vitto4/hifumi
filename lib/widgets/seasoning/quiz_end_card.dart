import "package:flutter/material.dart";
import "package:hifumi/entities/light_theme.dart";
import "package:hifumi/entities/font_sizes.dart";
import "package:hifumi/widgets/archipelago/island_container.dart";

enum SecondButtonType { restart, clearDeck }

/// A tiny reward for whosoever can make it to the end of a quiz.
class QuizEndCard extends StatelessWidget {
  final bool displaySecondButton;
  final SecondButtonType? secondButtonType;
  final Function? onSecondButton;

  const QuizEndCard({
    Key? key,
    required this.displaySecondButton,
    this.secondButtonType,
    this.onSecondButton,
  }) : super(key: key);

  static const double _width = 200.0;
  static const double _height = 290.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: _width,
      child: IslandContainer(
        backgroundColor: LightTheme.base,
        borderColor: LightTheme.baseAccent,
        tapped: false,
        offset: 4.0,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: const Alignment(.0, .75),
              child: Transform.scale(
                scale: 1.65,
                child: Text(
                  // Aww
                  "(„• ᴗ •„)",
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.transparent.withValues(alpha: .04),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Roboto",
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment(
                .0,
                -.9,
              ),
              child: Text(
                "お疲れ様です～",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: LightTheme.textColorDimmer,
                  fontSize: 21.0,
                  fontFamily: "NotoSansJP",
                  letterSpacing: 3.0,
                ),
              ),
            ),
            (displaySecondButton)
                ? Align(
                    alignment: const Alignment(.0, -.3),
                    child: TextButton.icon(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0)),
                      ),
                      icon: Icon(
                        (secondButtonType == SecondButtonType.restart) ? Icons.restart_alt : Icons.delete,
                        color: LightTheme.textColorDimmer,
                      ),
                      label: Text(
                        (secondButtonType == SecondButtonType.restart) ? "RESTART" : "CLEAR DECK",
                        style: TextStyle(
                          color: LightTheme.textColorDimmer,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizes.small,
                          letterSpacing: .5,
                        ),
                      ),
                      onPressed: () {
                        onSecondButton?.call();
                      },
                    ),
                  )
                : Container(),
            Align(
              alignment: (displaySecondButton) ? const Alignment(.0, .2) : Alignment.center,
              child: TextButton.icon(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0)),
                ),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: LightTheme.textColorDimmer,
                ),
                label: const Text(
                  "MAIN MENU",
                  style: TextStyle(
                    color: LightTheme.textColorDimmer,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.small,
                    letterSpacing: .5,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
