import "package:flutter/material.dart";
import "package:hifumi/abstractions/ui/themes.dart";
import "package:hifumi/widgets/seasoning/click_me.dart";

/// Remember to be lazy, why scroll when you can have a button for this ?
class _ScrollToTopButton extends StatelessWidget {
  final Function onTap;

  const _ScrollToTopButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => onTap.call(),
          child: ClickMePrettyPlease(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10.0, 8.0, 16.0, 8.0),
              decoration: BoxDecoration(
                color: LightTheme.base,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  width: 2.0,
                  color: LightTheme.baseAccent,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: LightTheme.blue,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Top',
                    style: TextStyle(
                      color: LightTheme.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The dev is also lazy, this is so that I don't have to manually implement the [_ScrollToTopButton] each time.
/// Will show the button when the user scrolls past offset `500.0` (pixels).
class ScrollToTopView extends StatefulWidget {
  final Widget child;

  const ScrollToTopView({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ScrollToTopView> createState() => _ScrollToTopViewState();
}

class _ScrollToTopViewState extends State<ScrollToTopView> {
  late ScrollController _scrollController;
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 500.0 && !_showFloatingButton) {
      setState(() {
        _showFloatingButton = true;
      });
    } else if (_scrollController.offset < 500.0 && _showFloatingButton) {
      setState(() {
        _showFloatingButton = false;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          child: widget.child,
        ),
        IgnorePointer(
          ignoring: !_showFloatingButton,
          child: AnimatedOpacity(
            opacity: _showFloatingButton ? 1.0 : .0,
            duration: const Duration(milliseconds: 150),
            child: Align(
              alignment: Alignment.bottomRight,
              child: _ScrollToTopButton(
                onTap: _scrollToTop,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
