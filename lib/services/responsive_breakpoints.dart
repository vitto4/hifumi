import "package:flutter/material.dart";
import "package:hifumi/abstractions/ui/@screen_orientation.dart";

/// * I didn't really write comments for most of the functions here, but you can figure what they do using their names.
/// * Edit : turns out the names I used aren't really good...
///
/// TODO? Maybe switch to https://pub.dev/packages/responsive_framework

/// Get the orientation of the screen based on its dimensions.
ScreenOrientation getOrientation(BuildContext context) {
  final Size dimensions = getScreenDimensions(context);
  return (dimensions.height > dimensions.width) ? ScreenOrientation.portrait : ScreenOrientation.landscape;
}

/// Get the screen's dimensions.
Size getScreenDimensions(BuildContext context) {
  return MediaQuery.of(context).size;
}

double getAspectRatio(BuildContext context) {
  Size dimensions = getScreenDimensions(context);
  return dimensions.width / dimensions.height;
}

/// A negative value is returned when compact tiles are desired.
int getLessonTilesCrossCount(BuildContext context) {
  Size dimensions = getScreenDimensions(context);
  switch (dimensions.width) {
    case <= 550.0:
      return -2;
    case > 550.0 && <= 700.0:
      return -3;
    case > 700.0 && <= 1000.0:
      return 2;
    default:
      return 3;
  }
}

int getWordTilesCrossCount(BuildContext context) {
  Size dimensions = getScreenDimensions(context);
  switch (dimensions.width) {
    case < 700.0:
      return 1;
    default:
      return 2;
  }
}

/// Should the `"Quiz"` and `"Review"` buttons be compact ?
bool getMainMenuComboButtonCompactMode(BuildContext context) {
  return (getScreenDimensions(context).width <= 600) ? true : false;
}

/// (??)
bool getComboButtonScaffoldFlex(BuildContext context) {
  return getScreenDimensions(context).width <= 690; // Removed redundant ternary
}

/// Should the `"Jisho"` and `"Add to deck"` buttons be compact ?
bool getComboButtonCompactMode(BuildContext context) {
  return getScreenDimensions(context).width <= 830; // Removed redundant ternary
}

double getTrayDialogWidth(BuildContext context) {
  return (getScreenDimensions(context).width > 900) ? 900.0 : getScreenDimensions(context).width;
}

bool getWordCountSliderCompactMode(BuildContext context) {
  return (getScreenDimensions(context).width < 450) ? true : false;
}

bool getQuizSegmentedSelectorCompactMode(BuildContext context) {
  return (getScreenDimensions(context).width < 540) ? true : false;
}

bool getDeckModeSegmentedSelectorCompactMode(BuildContext context) {
  return (getScreenDimensions(context).width < 560) ? true : false;
}

bool getEndlessSelectorCompactMode(BuildContext context) {
  return (getScreenDimensions(context).width < 570) ? true : false;
}

double getScrollDelayHeight(BuildContext context) {
  final double height = getScreenDimensions(context).height;
  final double percentage = getOrientation(context) == ScreenOrientation.landscape ? .165 : .1;

  return height * percentage;
}

bool getCurrentSelectionSingleLine(BuildContext context) {
  return (getScreenDimensions(context).width < 470) ? false : true;
}

bool getSettingsButtonAligned(BuildContext context) {
  return (getScreenDimensions(context).width < 700) ? false : true;
}

bool getTextAlignLeft(BuildContext context) {
  return (getScreenDimensions(context).width <= 365) ? true : false;
}

bool getPickersShrink(BuildContext context) {
  return (getScreenDimensions(context).height <= 500) ? true : false;
}

bool getLoadingShrink(BuildContext context) {
  return (getScreenDimensions(context).height <= 400) ? true : false;
}
