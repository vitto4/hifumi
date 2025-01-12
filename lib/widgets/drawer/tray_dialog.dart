import "package:hifumi/services/responsive_layout_niceties.dart";
import "package:flutter/material.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";

/// So initially I built one myself because I couldn't find any package doing properly what I wanted.
/// It worked but it wasn't great, and in the end I found `modal_bottom_sheet`, which works like a charm !
///
/// https://github.com/jamesblasco/modal_bottom_sheet/issues/63
Future<T> showTrayDialog<T>({
  required BuildContext context,
  required Widget child,
  required Color pillColor,
  required Color backgroundColor,
  Duration transitionDuration = const Duration(milliseconds: 200),
  double heightPercentage = 5 / 7,
}) async {
  return await showCustomModalBottomSheet(
    context: context,
    duration: transitionDuration,
    containerWidget: (context, _, child) {
      Size dimensions = getScreenDimensions(context);
      double paddingLR = (dimensions.width - getTrayDialogWidth(context)) / 2;
      double maxHeight = dimensions.height * heightPercentage;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingLR),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Material(
              color: backgroundColor,
              clipBehavior: Clip.antiAlias,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
              child: child,
            ),
          ),
        ),
      );
    },
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 10.0),
        Container(
          height: 5.0,
          width: 25.0,
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
        const SizedBox(height: 20.0),
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20.0, .0, 20.0, .0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  child,
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
