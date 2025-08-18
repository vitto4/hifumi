import "package:flutter/material.dart";
import "package:flip_card/flip_card.dart";

/// For some reason animating widget that contains a [FlipCard] is really resource-intensive, and causes raster jank.
///
/// A [Polyjuice] is only a [FlipCard] when flipping, and is the actual widget facing up the rest of the time.
/// Dramatically improves frame time ! Hooray !
class Polyjuice extends StatefulWidget {
  final Widget front;
  final Widget back;

  const Polyjuice({
    Key? key,
    required this.front,
    required this.back,
  }) : super(key: key);

  @override
  State<Polyjuice> createState() => PolyjuiceState();
}

class PolyjuiceState extends State<Polyjuice> {
  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();

  CardSide _currentSide = CardSide.FRONT;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
  }

  /// Toggle the [FlipCard].
  void flip() {
    /// Drink the potion, start morphing into a [FlipCard].
    setState(() {
      _animating = true;
    });

    /// We don't want to start animating before the widget has turned into a [FlipCard] (achieved in the above setState).
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        // To keep track of the animation state
        bool hasStarted = false;

        // We catch events when the animation starts, then catch those meaning it's done
        _flipCardKey.currentState?.controller?.addStatusListener(
          (status) {
            if (!hasStarted && (status == AnimationStatus.forward || status == AnimationStatus.reverse)) {
              hasStarted = true;
            }

            if (hasStarted && (status == AnimationStatus.completed || status == AnimationStatus.dismissed)) {
              hasStarted = false;

              // At that point the widget is flipped, we can safely turn it back into its original form, and remove the [FlipCard]
              setState(() {
                _currentSide = _currentSide == CardSide.FRONT ? CardSide.BACK : CardSide.FRONT;
                _animating = false;
              });
            }
          },
        );

        // Trigger the animation
        _flipCardKey.currentState?.toggleCard();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: (_animating)
          ? FlipCard(
              key: _flipCardKey,
              front: widget.front,
              back: widget.back,
              side: _currentSide,
              flipOnTouch: false,
            )
          : _currentSide == CardSide.FRONT
          ? widget.front
          : widget.back,
    );
  }
}
