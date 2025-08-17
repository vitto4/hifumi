import 'package:flutter/material.dart';
import 'package:hifumi/abstractions/abstractions_barrel.dart';
import 'package:hifumi/widgets/archipelago/archipelago_barrel.dart';
import 'package:hifumi/widgets/archipelago/island_text_checkbox.dart';

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
