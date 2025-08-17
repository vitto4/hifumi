import 'package:flutter/material.dart';
import 'package:hifumi/abstractions/abstractions_barrel.dart';
import 'package:hifumi/widgets/archipelago/archipelago_barrel.dart';
import 'package:hifumi/widgets/archipelago/island_text_checkbox.dart';

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
