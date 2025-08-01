import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter/physics.dart";

enum Side {
  left,
  right,
}

/// Adds the [Swipeable] trait to a widget.
/// Wraps its child in an [Transform] widget which controls the position.
///
/// Thus, to set the default position of a [Swipeable] widget there are two options :
///   - Use the property [defaultAlignment]
///   - Wrap it in another widget, and position the latter.
///
/// * Used : https://docs.flutter.dev/cookbook/animation/physics-simulation
class Swipeable extends StatefulWidget {
  /// I think I was pretty successful at making these self-explanatory.
  final Function? onLeftSwipeRelease;
  final Function? onRightSwipeRelease;
  final Function? onLeftSwipeKeyboard;
  final Function? onRightSwipeKeyboard;

  /// The « thresholds » are the (vertical, i.e. y = constant) boundaries of the imaginary box the confines the widget.
  /// When crossed, if released in this area, the widget will be animated away.
  /// Otherwise, it'll be animated back to its [defaultAlignment].
  final Function? onLeftThresholdCrossed;
  final Function? onRightThresholdCrossed;
  final Function? onThresholdBackInside;

  /// ! Warning : Not completely implemented.
  final Alignment defaultAlignment;

  final Widget child;

  const Swipeable({
    Key? key,
    this.onLeftSwipeRelease,
    this.onRightSwipeRelease,
    this.onLeftSwipeKeyboard,
    this.onRightSwipeKeyboard,
    this.onLeftThresholdCrossed,
    this.onRightThresholdCrossed,
    this.onThresholdBackInside,
    this.defaultAlignment = Alignment.center,
    required this.child,
  }) : super(key: key);

  @override
  State<Swipeable> createState() => SwipeableState();
}

class SwipeableState extends State<Swipeable> with SingleTickerProviderStateMixin {
  /// Giving the [AnimationController] a run for its money, we'll use it for all and every animation.
  late final AnimationController _controller;

  /// Controls the position.
  late Animation<Offset> _animation;

  /// Is always [Offset.zero]. Could need to be reworked for [widget.defaultAlignment].
  late final Offset _defaultOffset;

  /// This is what will constantly change based on [_animation], allowing the widget to move 'round like there is no tomorrow.
  late Offset _dragOffset;

  /// Safety check to prevent a [Swipeable] from being discarded multiple times.
  bool isDiscarded = false;

  /// Threshold detection.
  bool hasCrossedThreshold = false;

  /// The damned keyboard focus. >:(
  late final FocusNode _node;

  @override
  void initState() {
    super.initState();
    _node = FocusNode(debugLabel: "SwipeLeftRightNode");

    /// Initial values, [_defaultOffset] will remain the same, but not [_dragOffset].
    _defaultOffset = Offset.zero;
    _dragOffset = Offset.zero;

    _controller = AnimationController(vsync: this);

    /// Keep the widget in sync with the animation at any given moment.
    _controller.addListener(() {
      setState(() {
        _dragOffset = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /* -------------------------------------------------------------------------- */
  /*                                    UTILS                                   */
  /* -------------------------------------------------------------------------- */

  /// Assume that [Offset] is a vector space homeomorphic to $\R^2$.
  /// Let's verify that [_distance] defines a metric on our vector space.
  /// 1. Non-negativity
  ///    For any $x = \left(x_1, x_2\right) \in \R^2$,
  ///
  ///
  /// No jk, this just computes the distance between two points [p1] and [p2].
  double _distance(Offset p1, Offset p2) {
    return (p1 - p2).distance;
  }

  /// Snaps the widget back in the middle of the screen.
  ///
  /// Computes and runs a [SpringSimulation].
  /// Used when the user lets go of the widget, but it's not been dragged far enough to trigger [_runLeavingAnimation].
  void _runSpringAnimation(Offset pixelsPerSecond, Size screenSize) {
    // Define the path to take
    _animation = _controller.drive(
      Tween<Offset>(
        begin: _dragOffset,
        end: _defaultOffset,
      ),
    );

    // Calculate the velocity relative to the unit interval [0;1] used by the animation controller.
    final double unitsPerSecondX = pixelsPerSecond.dx / screenSize.width;
    final double unitsPerSecondY = pixelsPerSecond.dy / screenSize.height;
    final Offset unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final double unitVelocity = unitsPerSecond.distance;

    // Breaking changes in Flutter 3.32, previous values were m = 30.0 ; (c,k) = 1.0.
    // See : https://docs.flutter.dev/release/breaking-changes/spring-description-underdamped
    const SpringDescription spring = SpringDescription(mass: 1.0, stiffness: 225.0, damping: 30.0);

    final simulation = SpringSimulation(
      spring,
      .0,
      1.0,
      // I cannot remember why I made the velocity negative here
      // It doesn't seem to make any difference, but y'know « if it ain't broke, don't fix it ».
      -unitVelocity,
    );

    // Now that everything's ready, run the simulation
    _controller.animateWith(simulation);
  }

  /// Animates the widget leaving the screen.
  ///
  /// When done, the widget isn't destroyed, it stays where the animation ended.
  /// This is by design. (also because I don't know if it's possible to destroy a widget)
  void _runLeavingAnimation(Side side, Size screenSize) {
    // Find the largest dimension. This will be our target, to be sure the widget remains off screen if the orientation changes
    final double largest = screenSize.width > screenSize.height ? screenSize.width : screenSize.height;

    // Destination of the widget
    final Offset destination = (side == Side.left) ? Offset(-1.1 * largest, .0) : Offset(1.1 * largest, .0);

    // Distance between the current position and the destination
    final double distance = (_dragOffset.dx - destination.dx).abs();

    // Velocity of the widget, in pixels per second (?)
    const int velocity = 2300;

    _animation = Tween<Offset>(
      begin: _dragOffset,
      end: destination,
    ).animate(_controller);

    // Clear any ongoing animation
    _controller.reset();

    // Compute the animation duration in light of `velocity`
    _controller.duration = Duration(milliseconds: ((distance / velocity).abs() * 1000).round());

    // Now that everything's ready, run the simulations
    _controller.forward();
  }

  /// Routine to be run when the child widget is swiped away.
  /// Handles the animation, the event function call, and reflects the state change in [isDiscarded].
  void discard(Size screenSize, Side side, bool keyboard) {
    // Change this before running the animations since it is (also) used to discard pointer events while animating.
    // (We don't want a mischievous user to interfere with our animation, do we ?)
    isDiscarded = true;

    switch (side) {
      case Side.left:
        _runLeavingAnimation(Side.left, screenSize);
        (keyboard) ? widget.onLeftSwipeKeyboard?.call() : widget.onLeftSwipeRelease?.call();
      case Side.right:
        _runLeavingAnimation(Side.right, screenSize);
        (keyboard) ? widget.onRightSwipeKeyboard?.call() : widget.onRightSwipeRelease?.call();
    }
  }

  /* ------------------------------------ . ----------------------------------- */

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;

    // Screen orientation
    final bool portrait = (height > width) ? true : false;

    // To trigger the leaving animation
    final double discardThreshold = (portrait) ? .3 * width : .15 * width;
    // FIXME with default alignment.
    // As of now, a default alignment in the threshold region could break things, I imagine.

    // `Ctrl` + click for an explanation
    final double dragSpeedCoefficient = (portrait) ? 2.0 : 1.5;

    // Absorb taps if widget is animating, but don't if it is close to its resting position.
    // If we don't take this precaution, we may absorb taps even if the widget looks still to the user.
    final bool absorbTap = (_distance(_defaultOffset, _dragOffset) > 5.0) ? _controller.isAnimating : false;

    // Detecting when the widget crosses the threshold
    if (!isDiscarded) {
      if ((_dragOffset.dx <= _defaultOffset.dx - discardThreshold)) {
        if (!hasCrossedThreshold) {
          hasCrossedThreshold = true;
          widget.onLeftThresholdCrossed?.call();
        }
      } else if ((_dragOffset.dx >= _defaultOffset.dx + discardThreshold)) {
        if (!hasCrossedThreshold) {
          hasCrossedThreshold = true;
          widget.onRightThresholdCrossed?.call();
        }
      } else if (hasCrossedThreshold) {
        hasCrossedThreshold = false;
        widget.onThresholdBackInside?.call();
      }
    }

    /// Some time ago I wrote this :
    ///
    /// > TODO Add detection for child focus
    /// > If detected, do not request focus
    /// > else, do.
    ///
    /// And well, I never did it, but it would still be a nice thing to do if someone else is ever going to use this widget.

    return Focus(
      focusNode: _node,
      onKeyEvent: (node, event) {
        // If the key press is valid and not repeated, match it with the arrow keys, else ignore.
        if (!isDiscarded && event is KeyDownEvent && event is! KeyRepeatEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowLeft:
              discard(screenSize, Side.left, true);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
              discard(screenSize, Side.right, true);
              return KeyEventResult.handled;
            case _:
              return KeyEventResult.ignored;
          }
        } else {
          return KeyEventResult.ignored;
        }
      },
      child: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.distance != .0) {
            // These coefficients scale the movement so the user can achieve maximum widget displacement with minimum finger displacement
            setState(() {
              _dragOffset += Offset(details.delta.dx * dragSpeedCoefficient, details.delta.dy * .88);
            });
          }
        },
        // Stop animating back to center when the user swipes but don't stop if the child was, in fact, leaving.
        onPanDown: (details) {
          if (!isDiscarded) {
            _controller.stop();
          }
        },
        // Logic to detect where the user has released the widget
        // If it is far enough on either side, the leaving animation will trigger, else the widget is animated back to the center of the screen
        onPanEnd: (details) {
          if (_dragOffset.dx >= _defaultOffset.dx + discardThreshold && !isDiscarded) {
            discard(screenSize, Side.right, false);
          } else if (_dragOffset.dx <= _defaultOffset.dx - discardThreshold && !isDiscarded) {
            discard(screenSize, Side.left, false);
          } else if (!isDiscarded) {
            _runSpringAnimation(details.velocity.pixelsPerSecond, screenSize);
          }
        },
        // If an animation is running, do not allow interaction (it may stop the the animation for some reason).
        // If animating back to center, absorb to let user pick the swiping back up even when the animation is running.
        // Also, if the leaving animation is running, ignore to let user interact with whatever other widget there may be.
        child: (isDiscarded)
            ? IgnorePointer(
                ignoring: absorbTap,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: widget.defaultAlignment,
                      child: Transform.translate(
                        offset: _dragOffset,
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              )
            : AbsorbPointer(
                absorbing: absorbTap,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: widget.defaultAlignment,
                      child: Transform.translate(
                        offset: _dragOffset,
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
