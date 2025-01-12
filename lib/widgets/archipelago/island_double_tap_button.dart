import "dart:async";
import "package:flutter/material.dart";
import "package:hifumi/services/darken.dart";
import "package:hifumi/widgets/archipelago/island_button.dart";

/// Button full of surprises, requires two taps to activate.
/// - First tap changes its child.
/// - Second tap within [timerDuration] triggers callback [onSecondTap].
/// - State resets if second tap doesn't occur within [timerDuration].
class IslandDoubleTapButton extends StatefulWidget {
  final Duration timerDuration;

  final Color firstBackgroundColor;
  final Color firstBorderColor;
  final Color secondBackgroundColor;
  final Color secondBorderColor;

  final Function onSecondTap;

  final Widget firstChild;
  final Widget secondChild;

  final Duration animationDuration;
  final double offset;

  const IslandDoubleTapButton({
    Key? key,
    required this.timerDuration,
    required this.firstBackgroundColor,
    required this.firstBorderColor,
    required this.secondBackgroundColor,
    required this.secondBorderColor,
    required this.onSecondTap,
    required this.firstChild,
    required this.secondChild,
    this.animationDuration = const Duration(milliseconds: 150),
    this.offset = 2.05,
  }) : super(key: key);

  @override
  State<IslandDoubleTapButton> createState() => _IslandDoubleTapButtonState();
}

class _IslandDoubleTapButtonState extends State<IslandDoubleTapButton> {
  late int tappedHowManyTimes;
  late bool _isHovering;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    tappedHowManyTimes = 0;
    _isHovering = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Callback for the hover effect.
  void _mouseEnter(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }

  void tapHandler() {
    if (tappedHowManyTimes == 0) {
      setState(() {
        tappedHowManyTimes = 1;
      });

      // State will eventually reset if nothing happens
      _timer = Timer(
        widget.timerDuration,
        () {
          setState(() {
            tappedHowManyTimes = 0;
          });
        },
      );
    } else if (tappedHowManyTimes == 1) {
      // If the second tap occurs in time, run the callback function
      widget.onSecondTap.call();

      // And also reset the state
      setState(() {
        tappedHowManyTimes = 0;
      });
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _mouseEnter(true),
      onExit: (event) => _mouseEnter(false),
      child: IslandButton(
        backgroundColor: (tappedHowManyTimes == 0)
            ? _isHovering
                ? widget.firstBackgroundColor.darken(.985)
                : widget.firstBackgroundColor
            : _isHovering
                ? widget.secondBackgroundColor.darken(.985)
                : widget.secondBackgroundColor,
        borderColor: (tappedHowManyTimes == 0) ? widget.firstBorderColor : widget.secondBorderColor,
        onTap: tapHandler,
        offset: widget.offset,
        reactOnHover: false, // We don't want to double react, we're already implementing our own version in this file
        animationDuration: widget.animationDuration,
        child: (tappedHowManyTimes == 0) ? widget.firstChild : widget.secondChild,
      ),
    );
  }
}
