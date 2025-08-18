import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:hifumi/abstractions/abstractions_barrel.dart';
import 'package:hifumi/services/responsive_breakpoints.dart';

/// And the one shown in the main menu.
class HomeComboButton extends StatelessWidget {
  final Function onPrimaryLeft;
  final Function onPrimaryRight;
  final Function onSecondaryLeft;
  final Function onSecondaryRight;

  const HomeComboButton({
    Key? key,
    required this.onPrimaryLeft,
    required this.onPrimaryRight,
    required this.onSecondaryLeft,
    required this.onSecondaryRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String textLeft = "Quiz";
    const String textRight = "Review";

    return _Scaffold(
      leftButton: ChicletSegmentedButton(
        height: getHomeComboButtonCompactMode(context) ? 40.0 : 50.0,
        buttonHeight: 4.0,
        backgroundColor: LightTheme.blue,
        buttonColor: LightTheme.blueBorder,
        children: [
          Expanded(
            child: ChicletButtonSegment(
              onPressed: () => this.onPrimaryLeft.call(),
              child: const Text(
                textLeft,
                style: TextStyle(
                  fontSize: FontSizes.huge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ChicletButtonSegment(
            onPressed: () => this.onSecondaryLeft.call(),
            padding: EdgeInsets.zero,
            child: const Icon(
              Icons.arrow_circle_up,
              size: 24.0,
            ),
          ),
        ],
      ),
      rightButton: ChicletSegmentedButton(
        height: getHomeComboButtonCompactMode(context) ? 40.0 : 50.0,
        buttonHeight: 4.0,
        backgroundColor: LightTheme.orange,
        foregroundColor: LightTheme.orangeTextAccent,
        buttonColor: LightTheme.orangeBorder,
        children: [
          Expanded(
            child: ChicletButtonSegment(
              onPressed: () => this.onPrimaryRight.call(),
              child: const Text(
                textRight,
                style: TextStyle(
                  fontSize: FontSizes.huge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ChicletButtonSegment(
            onPressed: () => this.onSecondaryRight.call(),
            padding: EdgeInsets.zero,
            child: const Icon(
              Icons.arrow_circle_up,
              size: 24.0,
              color: LightTheme.orangeTextAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final Widget leftButton;
  final Widget rightButton;

  const _Scaffold({
    Key? key,
    required this.leftButton,
    required this.rightButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int buttonsFlex = getComboButtonScaffoldFlex(context) ? 10 : 3;

    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: buttonsFlex,
          child: this.leftButton,
        ),
        Expanded(
          flex: getHomeComboButtonCompactMode(context) ? 2 : 1,
          child: Container(),
        ),
        Expanded(
          flex: buttonsFlex,
          child: this.rightButton,
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}
