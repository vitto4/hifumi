import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/services/responsive_breakpoints.dart";
import "package:chiclet/chiclet.dart";

enum ComboButtonConfig {
  standard,
  onlyLeft, // i.e. only Jisho
  standardWOnlyRemove,
}

/// If this breaks, blame the other devs !
/// (
///   just kidding, there's only me, and also you reading this.
///   except I wrote this some time ago, so in fact it's just you.
///   you're on your own [:
/// )
///
/// A pair of buttons positioned side by side.
/// See [ComboButtonConfig] for available configurations.
class ComboButtonScaffold extends StatelessWidget {
  final Widget leftButton;
  final Widget rightButton;
  final ComboButtonConfig config;

  const ComboButtonScaffold({
    Key? key,
    required this.leftButton,
    required this.rightButton,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int buttonsFlex = getComboButtonScaffoldFlex(context) ? 10 : 3;

    return switch (config) {
      ComboButtonConfig.standard || ComboButtonConfig.standardWOnlyRemove => Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: buttonsFlex,
            child: this.leftButton,
          ),
          Expanded(
            flex: getMainMenuComboButtonCompactMode(context) ? 2 : 1,
            child: Container(),
          ),
          Expanded(
            flex: buttonsFlex,
            child: this.rightButton,
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
      ComboButtonConfig.onlyLeft => Row(
        children: <Widget>[
          const Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 3,
            child: this.leftButton,
          ),
          const Spacer(
            flex: 1,
          ),
        ],
      ),
    };
  }
}

/// The combo button shown during a quiz (under the card pile).
class QuizComboButton extends StatelessWidget {
  final Function onPrimaryLeft;
  final Function onPrimaryRight;
  final Function onSecondaryRight;
  final Deck selectedDeck;
  final bool rightEnabled;
  final ComboButtonConfig config;

  const QuizComboButton({
    Key? key,
    required this.onPrimaryLeft,
    required this.onPrimaryRight,
    required this.onSecondaryRight,
    required this.selectedDeck,
    required this.rightEnabled,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool compact = getComboButtonCompactMode(context);

    const String textLeft = "Jisho";
    final textRight = (compact)
        ? "Deck"
        : (rightEnabled)
        ? "Add to deck"
        : "Remove from deck";

    return FractionallySizedBox(
      widthFactor: .91,
      child: ComboButtonScaffold(
        config: config,
        // Row + expanded to have the button span the column's whole width. A little hacky, can't use `Expanded` because of unbounded constraints
        leftButton: Row(
          children: <Widget>[
            Expanded(
              child: ChicletAnimatedButton(
                buttonHeight: 4.0,
                buttonType: ChicletButtonTypes.roundedRectangle,
                backgroundColor: LightTheme.forestGreenLight,
                foregroundColor: LightTheme.base,
                buttonColor: LightTheme.forestGreen,
                onPressed: () => this.onPrimaryLeft.call(),
                child: const Text(
                  textLeft,
                  style: TextStyle(
                    fontSize: FontSizes.huge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        rightButton: (config == ComboButtonConfig.standardWOnlyRemove)
            ? ChicletAnimatedButton(
                buttonHeight: 4.0,
                buttonType: ChicletButtonTypes.roundedRectangle,
                backgroundColor: (rightEnabled) ? LightTheme.orange : LightTheme.redLight,
                foregroundColor: (rightEnabled) ? LightTheme.orangeTextAccent : LightTheme.base,
                buttonColor: (rightEnabled) ? LightTheme.orangeBorder : LightTheme.red,
                onPressed: () => this.onPrimaryRight.call(),
                child: Text(
                  textRight,
                  style: const TextStyle(
                    fontSize: FontSizes.huge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ChicletSegmentedButton(
                buttonHeight: 4.0,
                backgroundColor: (rightEnabled) ? LightTheme.orange : LightTheme.redLight,
                foregroundColor: (rightEnabled) ? LightTheme.orangeTextAccent : LightTheme.base,
                buttonColor: (rightEnabled) ? LightTheme.orangeBorder : LightTheme.red,
                children: [
                  Expanded(
                    child: ChicletButtonSegment(
                      onPressed: () => this.onPrimaryRight.call(),
                      child: Text(
                        textRight,
                        style: const TextStyle(
                          fontSize: FontSizes.huge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ChicletButtonSegment(
                    onPressed: () => this.onSecondaryRight.call(),
                    padding: EdgeInsets.zero,
                    child: Text(
                      this.selectedDeck.display,
                      style: const TextStyle(
                        fontSize: FontSizes.huge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// And the one shown in the main menu.
class MainMenuComboButton extends StatelessWidget {
  final Function onPrimaryLeft;
  final Function onPrimaryRight;
  final Function onSecondaryLeft;
  final Function onSecondaryRight;

  const MainMenuComboButton({
    Key? key,
    required this.onPrimaryLeft,
    required this.onPrimaryRight,
    required this.onSecondaryLeft,
    required this.onSecondaryRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String textLeft = "Quiz";
    const String textRight = "Review";

    return ComboButtonScaffold(
      config: ComboButtonConfig.standard,
      leftButton: ChicletSegmentedButton(
        height: getMainMenuComboButtonCompactMode(context) ? 40.0 : 50.0,
        buttonHeight: 4.0,
        backgroundColor: LightTheme.blue,
        buttonColor: LightTheme.blueBorder,
        children: [
          Expanded(
            child: ChicletButtonSegment(
              onPressed: () => this.onPrimaryLeft.call(),
              child: const Text(
                textLeft,
                style: TextStyle(
                  fontSize: FontSizes.huge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ChicletButtonSegment(
            onPressed: () => this.onSecondaryLeft.call(),
            padding: EdgeInsets.zero,
            child: const Icon(
              Icons.arrow_circle_up,
              size: 24.0,
            ),
          ),
        ],
      ),
      rightButton: ChicletSegmentedButton(
        height: getMainMenuComboButtonCompactMode(context) ? 40.0 : 50.0,
        buttonHeight: 4.0,
        backgroundColor: LightTheme.orange,
        foregroundColor: LightTheme.orangeTextAccent,
        buttonColor: LightTheme.orangeBorder,
        children: [
          Expanded(
            child: ChicletButtonSegment(
              onPressed: () => this.onPrimaryRight.call(),
              child: const Text(
                textRight,
                style: TextStyle(
                  fontSize: FontSizes.huge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ChicletButtonSegment(
            onPressed: () => this.onSecondaryRight.call(),
            padding: EdgeInsets.zero,
            child: const Icon(
              Icons.arrow_circle_up,
              size: 24.0,
              color: LightTheme.orangeTextAccent,
            ),
          ),
        ],
      ),
    );
  }
}
