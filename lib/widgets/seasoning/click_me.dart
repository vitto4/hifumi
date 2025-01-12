import "package:flutter/material.dart";

/// Wrapper widget that changes the mouse cursor to a pointer on hover.
class ClickMePrettyPlease extends StatelessWidget {
  final Widget child;

  const ClickMePrettyPlease({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: this.child,
    );
  }
}
