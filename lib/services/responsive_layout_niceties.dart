import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";

/// * I didn't really write comments for most of the functions here, but you can figure what they do using their names.
/// * Edit : turns out the names I used aren't really good...

enum ScreenOrientation { portrait, landscape }

/// Adds automatic scaling to its child.
/// Is used in the app for anything related to flashcards.
/// (hence the use of [D.CARD_RENDER_HEIGHT] and [D.CARD_RENDER_WIDTH])
///
/// This widget checks the available vertical and horizontal space, and finds, based on the desired aspect ratio for the cards, which dimension will be the *limiting reagent* in a *scale reaction*.
/// (yeah ik weird analogy)
/// It then scales its child accordingly.
class PleaseScaleMe extends StatelessWidget {
  final Widget child;

  const PleaseScaleMe({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final double scaleFactor = pleaseScaleMeExceptItsAFunctionAndReturnsACoefficient(context, constraints);

      /// I used to use a [Transform.scale] but it's wasn't a good idea.
      /// As the docs state for [Transform] : `A widget that applies a transformation before painting its child.`.
      /// i.e. it's all visual fluff and doesn't affect the layout at all.
      ///
      /// This is oh so much better ! (it even reports its scaled size to its parents !)
      /// Took me a whole day to figure out, but it feels straight out of heaven, it's so simple I don't know how I didn't think of doing this earlier.
      return SizedBox(
        height: D.CARD_RENDER_HEIGHT * scaleFactor,
        width: D.CARD_RENDER_WIDTH * scaleFactor,
        child: FittedBox(
          fit: BoxFit.contain,
          child: child,
        ),
      );
    });
  }
}

/// Returns the scale factor for the child to be used in [PleaseScaleMe].
double pleaseScaleMeExceptItsAFunctionAndReturnsACoefficient(BuildContext context, BoxConstraints constraints) {
  final Size screenSize = getScreenDimensions(context);
  final double horizontalPadding = .15 * screenSize.width;
  final double verticalPadding = .2 * screenSize.height;
  const double aspectRatio = D.CARD_RENDER_WIDTH / D.CARD_RENDER_HEIGHT;

  late final double scaleFactor;

  final double maxWidth = constraints.maxWidth;
  final double maxHeight = constraints.maxHeight;

  if ((maxHeight - 2 * verticalPadding) * aspectRatio < (maxWidth - 2 * horizontalPadding)) {
    final double height = maxHeight - 2 * verticalPadding;
    scaleFactor = height / D.CARD_RENDER_HEIGHT;
  } else {
    final double width = maxWidth - 2 * horizontalPadding;
    scaleFactor = width / D.CARD_RENDER_WIDTH;
  }

  return scaleFactor.abs();
}

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
