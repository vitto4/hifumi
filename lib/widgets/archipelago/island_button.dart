import "dart:async";
import "package:flutter/material.dart";
import "package:hifumi/services/darken.dart";
import "package:hifumi/widgets/archipelago/island_container.dart";
import "package:hifumi/widgets/seasoning/click_me.dart";

/// State is externally-managed ([backgroundColor] and whatnot), this being stateful only serves the purpose of animating on tap and darkening the background on mouse hover.
class IslandButton extends StatefulWidget {
  final Color backgroundColor;
  final Color borderColor;

  final Function onTap;
  final Function? onLongPress;

  final Widget child;

  final double offset;
  final bool smartExpand;
  final bool reactOnHover;

  /// Artificial lag duration added to the animation to make sure it registers.
  final Duration? tapDuration;

  const IslandButton({
    Key? key,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.offset = 2.05,
    this.smartExpand = false,
    this.reactOnHover = true,
    this.tapDuration,
  }) : super(key: key);

  @override
  State<IslandButton> createState() => _IslandButtonState();
}

class _IslandButtonState extends State<IslandButton> {
  late bool _isHovering;
  late bool _isTapped;
  Timer? _tapTimer;

  @override
  void initState() {
    super.initState();
    _isHovering = false;
    _isTapped = false;
  }

  void _onTapDown() => _isTapped != true ? setState(() => _isTapped = true) : null;

  void _onTapCancel() => _isTapped ? _resetTapState() : null;

  void _onTapUp() {
    widget.onTap.call();
    _isTapped ? _resetTapState() : null;
  }

  /// [_tapTimer] is only there to make sure the [_isTapped] animation registers, even when the tap doesn't last long enough.
  void _resetTapState() {
    _tapTimer?.cancel();
    _tapTimer = Timer(widget.tapDuration ?? const Duration(milliseconds: 50), () {
      setState(() => _isTapped = false);
    });
  }

  /// Callback for the hover effect.
  void _mouseEnter(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }

  /// For some godforsaken reason using `onLongPress` causes an infuriating delay on `onTapDown` in a [GestureDetector].
  /// I found three solutions to remove it :
  /// * Include and implement the three long press types as well (`onLongPressDown` and such), BUT still use `onLongPress` to trigger events,
  ///   otherwise it will be delayed as well. <-- Too convoluted
  /// * Wrap the [GestureDetector] inside a [Listener] that will handle tap events, leaving the detector with long presses.
  ///   Had the idea from the following stackoverflow thread :
  ///   https://stackoverflow.com/questions/53063021/flutter-tap-delay-with-gesturedetector-in-a-tile-of-a-gridview/
  ///   This is not ideal because when scrolling it will still react to pointer events.
  /// * Same as before, but use two different [GestureDetector]s : one for the taps, the other for the long press events. <-- what I ended up doing
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _mouseEnter(true),
      onExit: (event) => _mouseEnter(false),
      child: GestureDetector(
        onTapDown: (_) => _onTapDown.call(),
        onTapUp: (_) => _onTapUp.call(),
        onTapCancel: () => _onTapCancel.call(),
        child: GestureDetector(
          onLongPress: () => widget.onLongPress?.call(),
          child: ClickMePrettyPlease(
            child: IslandContainer(
              backgroundColor: _isHovering && widget.reactOnHover ? widget.backgroundColor.darken(.985) : widget.backgroundColor,
              borderColor: _isHovering && widget.reactOnHover ? widget.borderColor.darken(.965) : widget.borderColor,
              offset: widget.offset,
              smartExpand: widget.smartExpand,
              tapped: _isTapped,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
