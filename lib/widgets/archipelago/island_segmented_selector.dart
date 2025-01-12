import "package:flutter/material.dart";
import "package:hifumi/widgets/archipelago/island_button.dart";

/// Two buttons but only one shall be enabled at a time.
class IslandSegmentedSelector extends StatelessWidget {
  final Color leftBackgroundColor;
  final Color leftBorderColor;
  final Color rightBackgroundColor;
  final Color rightBorderColor;

  final Function onLeftTapped;
  final Function onRightTapped;

  /// Whether to use compact layout.
  final bool compact;

  final Widget leftChild;
  final Widget rightChild;

  const IslandSegmentedSelector({
    Key? key,
    required this.leftBackgroundColor,
    required this.leftBorderColor,
    required this.rightBackgroundColor,
    required this.rightBorderColor,
    required this.onLeftTapped,
    required this.onRightTapped,
    required this.compact,
    required this.leftChild,
    required this.rightChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AdaptativeScaffold(
      compact: compact,
      left: IslandButton(
        smartExpand: true,
        onTap: () => onLeftTapped.call(),
        backgroundColor: leftBackgroundColor,
        borderColor: leftBorderColor,
        child: leftChild,
      ),
      right: IslandButton(
        smartExpand: true,
        onTap: () => onRightTapped.call(),
        backgroundColor: rightBackgroundColor,
        borderColor: rightBorderColor,
        child: rightChild,
      ),
    );
  }
}

/// This is only used with the [IslandSegmentedSelector] (hence private).
/// Will allow the two buttons to stack when the screen is a little narrow.
class _AdaptativeScaffold extends StatelessWidget {
  final bool compact;
  final Widget left;
  final Widget right;

  const _AdaptativeScaffold({
    Key? key,
    required this.compact,
    required this.left,
    required this.right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.compact
        ? Column(
            children: <Widget>[
              this.left,
              const SizedBox(
                height: 8.0,
              ),
              this.right,
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              this.left,
              this.right,
            ],
          );
  }
}
