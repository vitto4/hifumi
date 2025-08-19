import "package:flutter/material.dart";

const double _BADGE_BORDER_RADIUS = 16.0;
const EdgeInsets _BADGE_PADDING = EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 1.0);
const double _BADGE_FRONTIER_PADDING = 6.0;

/// All your badge are belong to us.
///
/// (badge widget that displays two pieces of content with different background colors)
class ColorfulBadge extends StatelessWidget {
  final Widget childLeft;
  final Widget childRight;
  final Color backgroundColorLeft;
  final Color backgroundColorRight;

  /// This is unused, but working.
  final Function? onTap;

  const ColorfulBadge({
    Key? key,
    required this.childLeft,
    required this.childRight,
    required this.backgroundColorLeft,
    required this.backgroundColorRight,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget badge = IntrinsicWidth(
      child: Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_BADGE_BORDER_RADIUS),
                bottomLeft: Radius.circular(_BADGE_BORDER_RADIUS),
              ),
              color: backgroundColorLeft,
            ),
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding: _BADGE_PADDING.copyWith(right: _BADGE_FRONTIER_PADDING),
              child: childLeft,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(_BADGE_BORDER_RADIUS),
                bottomRight: Radius.circular(_BADGE_BORDER_RADIUS),
              ),
              color: backgroundColorRight,
            ),
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding: _BADGE_PADDING.copyWith(left: _BADGE_FRONTIER_PADDING),
              child: childRight,
            ),
          ),
        ],
      ),
    );

    return (onTap is Function) ? GestureDetector(onTap: () => onTap?.call(), child: badge) : badge;
  }
}
