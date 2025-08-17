import 'package:flutter/material.dart';
import 'package:hifumi/abstractions/abstractions_barrel.dart';
import 'package:hifumi/services/responsive_breakpoints.dart';

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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
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
      },
    );
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
