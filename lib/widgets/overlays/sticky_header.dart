import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Sticky header, reacts to scroll.
/// Has inverted rounded corners, except on web, it doesn't integrate well with web browser UIs.
class StickyHeader extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final Widget title;
  final Color color;
  final double topPadding;
  final double radius;

  const StickyHeader({
    Key? key,
    required this.color,
    required this.radius,
    required this.topPadding,
    required this.leading,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capture the original app theme
    final ThemeData appTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: this.color,
      body: SafeArea(
        child: NestedScrollView(
          // Needed to make `floating: true` work after having scrolled down for a while
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
            SliverAppBar(
              title: this.title,
              centerTitle: true,
              leading: this.leading,
              automaticallyImplyLeading: false,
              backgroundColor: this.color,
              floating: true,
              pinned: false,
              elevation: .0,
              toolbarHeight: 40.0,
            ),
          ],
          body: Padding(
            padding: kIsWeb ? EdgeInsetsGeometry.zero : EdgeInsetsGeometry.only(top: this.topPadding),
            child: ClipRRect(
              borderRadius: kIsWeb
                  ? BorderRadius.zero
                  : BorderRadius.only(
                      topLeft: Radius.circular(this.radius),
                      topRight: Radius.circular(this.radius),
                    ),
              child: SingleChildScrollView(
                // Needed to make `floating: true` work after having scrolled down for a while
                primary: true,
                scrollDirection: Axis.vertical,
                // Restore the app-wide theme
                child: Theme(
                  data: appTheme,
                  // Material needed here for some reason, otherwise the restored theme doesn't work
                  child: Material(child: this.child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
