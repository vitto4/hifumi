import "package:flutter/material.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";
import "package:hifumi/entities/entities_barrel.dart";

/// If you were foreseeing an overengineered solution to a simple problem as you caught sight of the word [mixin], you would be very correct.
/// Thankfully, I care to explain so you (I) don't get lost.
///
/// These are the properties that an enum and its variants should possess to be compatible with an [IslandTextCheckbox].
mixin IslandTextCheckboxState {
  /// Text to display when that state is enabled.
  String get text;

  /// Concordant background color.
  Color get backgroundColor;

  /// Don't forget about the borders.
  Color get borderColor;

  /// Oh and the text can have a color too !
  Color get textColor;
}

/// Used in the main menu [Home] to select or unselect all [LessonTile].
enum TristateLessonSelectionState with IslandTextCheckboxState {
  all("All"),
  none("None"),
  neutral("Misc.");

  const TristateLessonSelectionState(this.text);

  @override
  final String text;

  @override
  Color get backgroundColor {
    switch (this) {
      case TristateLessonSelectionState.all:
      case TristateLessonSelectionState.none:
        return LightTheme.blueLighter;
      default:
        return LightTheme.base;
    }
  }

  @override
  Color get borderColor {
    switch (this) {
      case TristateLessonSelectionState.all:
      case TristateLessonSelectionState.none:
        return LightTheme.blueLight;
      default:
        return LightTheme.baseAccent;
    }
  }

  @override
  Color get textColor {
    switch (this) {
      case TristateLessonSelectionState.all:
      case TristateLessonSelectionState.none:
        return LightTheme.blue;
      default:
        return LightTheme.textColorDimmer;
    }
  }
}

/// This one only has two states.
/// I'm a little lazy so don't hesitate to Shift+F12 to see what it's used for.
/// (If you're a vscode user, that is. If not, you probably know better than me what shortcut you should use.)
enum WholeSelectionButtonState with IslandTextCheckboxState {
  yes("Whole selection"),
  no("Whole selection");

  const WholeSelectionButtonState(this.text);

  @override
  final String text;

  @override
  Color get backgroundColor {
    switch (this) {
      case WholeSelectionButtonState.yes:
        return LightTheme.blueLighter;
      default:
        return LightTheme.base;
    }
  }

  @override
  Color get borderColor {
    switch (this) {
      case WholeSelectionButtonState.yes:
        return LightTheme.blueLight;
      default:
        return LightTheme.baseAccent;
    }
  }

  @override
  Color get textColor {
    switch (this) {
      case WholeSelectionButtonState.yes:
        return LightTheme.blue;
      default:
        return LightTheme.textColorDim;
    }
  }

  WholeSelectionButtonState get opposite => this == WholeSelectionButtonState.yes ? WholeSelectionButtonState.no : WholeSelectionButtonState.yes;

  bool get asBool => this == WholeSelectionButtonState.yes ? true : false;
}

/// Nice generic types !
class IslandTextCheckbox<T extends IslandTextCheckboxState> extends StatelessWidget {
  /// Current state of the checkbox.
  final T checkState;

  /// This is required because we don't want an [IslandTextCheckbox] to be constantly changing size as it's changing state.
  final T variantWithLongestText;

  /// Who wants to handle things on their own anyway ? Just leave it to someone else 👍
  final Function tapHandler;

  /// See what I wrote in [IslandContainer.build].
  final bool smartExpand;

  /// TODO
  /// Edit : todo what (・・ ) ?
  ///
  /// Turns the island-style checkbox into a regular, flat and more compact one.
  final bool compact;

  const IslandTextCheckbox({
    Key? key,
    required this.checkState,
    required this.variantWithLongestText,
    required this.tapHandler,
    this.smartExpand = false,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IslandButton(
      backgroundColor: checkState.backgroundColor,
      borderColor: checkState.borderColor,
      smartExpand: smartExpand,
      offset: compact ? .0 : 2.05,
      onTap: () => tapHandler.call(),
      child: Padding(
        padding: compact ? const EdgeInsets.fromLTRB(6.0, 1.0, 6.0, 1.0) : const EdgeInsets.fromLTRB(12.0, 3.0, 12.0, 3.0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              checkState.text,
              style: TextStyle(
                fontSize: compact ? FontSizes.base : FontSizes.big,
                fontWeight: FontWeight.bold,
                color: checkState.textColor,
              ),
            ),
            Opacity(
              opacity: .0,
              child: Text(
                variantWithLongestText.text,
                style: TextStyle(
                  fontSize: compact ? FontSizes.base : FontSizes.big,
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
