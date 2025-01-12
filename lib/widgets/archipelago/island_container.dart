import "package:flutter/material.dart";

const double _ISLAND_CONTAINER_BORDER_THICKNESS = 2.0;
const double _ISLAND_CONTAINER_BORDER_RADIUS = 12.0;

const double _FLAT_ISLAND_CONTAINER_BORDER_THICKNESS = 2.0;
const double _FLAT_ISLAND_CONTAINER_BORDER_RADIUS = 12.0;

/// Island-style container widget.
/// Yup I didn't know what it was either, TL;DR Duolingo-style buttons except it's a container.
///
/// This is the base for most widgets in the app.
class IslandContainer extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;

  /// Used to manage the state. When set to [true], the button will appear as tapped.
  final bool tapped;

  final Widget child;

  /// This can be understood as the height (z-axis) of the container.
  final double offset;

  /// Use this instead of wrapping the widget in an [Expanded].
  final bool smartExpand;

  /// I ended up never using this, but it's there if needed !
  final Duration? animationDuration;

  const IslandContainer({
    Key? key,
    required this.backgroundColor,
    required this.borderColor,
    required this.tapped,
    required this.child,
    this.offset = 2.05,
    this.smartExpand = false,
    this.animationDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Yeah this [LayoutBuilder] construct is a little hacky, but it makes up for my lack of understanding of flutter layout and constraints.
    // I couldn't get [IslandContainer]s to properly expand when placed in [Expanded] widgets so I just built my own version.
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      double? maxHeight = constraints.maxHeight == double.infinity ? null : constraints.maxHeight;
      double? maxWidth = constraints.maxWidth == double.infinity ? null : constraints.maxWidth;
      return Padding(
        /// Padding : Trick to maintain coherent layout constraints despite `Transform` acting after the layout has been painted.
        /// In concrete terms, include the thick border that mimics z-axis height in the reported (y-axis) height of the widget.
        /// (otherwise an [IslandContainer] may visually exceed the height of its parent)
        padding: EdgeInsets.fromLTRB(
          .0,
          .0,
          .0,
          this.offset,
        ),
        child: Stack(
          children: <Widget>[
            Transform.translate(
              offset: Offset(.0, this.offset),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: _ISLAND_CONTAINER_BORDER_THICKNESS),
                  borderRadius: BorderRadius.circular(_ISLAND_CONTAINER_BORDER_RADIUS),
                  color: borderColor,
                ),
                height: smartExpand ? maxHeight : null,
                width: smartExpand ? maxWidth : null,
                clipBehavior: Clip.hardEdge,
                // FIXME This is to make sure this container doesn't expand beyond what's needed, but there must be a better way of doing it.
                child: Opacity(opacity: .0, child: child),
              ),
            ),
            Transform.translate(
              offset: Offset(
                .0,
                (tapped) ? this.offset : .0,
              ),
              child: AnimatedContainer(
                duration: this.animationDuration ?? Duration.zero,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: _ISLAND_CONTAINER_BORDER_THICKNESS),
                  borderRadius: BorderRadius.circular(_ISLAND_CONTAINER_BORDER_RADIUS),
                  color: backgroundColor,
                ),
                height: smartExpand ? maxHeight : null,
                width: smartExpand ? maxWidth : null,
                clipBehavior: Clip.hardEdge,
                child: child,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Same thing as an [IslandContainer] except it's flat, so it's actually not island-style, but anyway -
///
/// All in all this is just a container with rounded corners, but it's consistent in style with other island widgets.
class FlatIslandContainer extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;

  const FlatIslandContainer({
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: _FLAT_ISLAND_CONTAINER_BORDER_THICKNESS),
        borderRadius: BorderRadius.circular(_FLAT_ISLAND_CONTAINER_BORDER_RADIUS),
        color: backgroundColor,
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}
