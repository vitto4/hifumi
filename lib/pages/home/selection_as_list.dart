import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hifumi/abstractions/abstractions_barrel.dart';

/// Feedback on what's selected. Nothing more than a list of the [LessonNumber] of all selected lessons.
class SelectionAsList extends StatelessWidget {
  const SelectionAsList({
    Key? key,
    required this.selection,
  }) : super(key: key);

  final List<LessonNumber> selection;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 500,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: LightTheme.baseAccent,
        borderRadius: BorderRadius.circular(5.0),
      ),
      height: 22.0,
      padding: const EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 3.0),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: LightTheme.textColorDim,
              fontFamily: "Varela Round",
              fontSize: FontSizes.base,
            ),
            child: Row(
              children: <Widget>[
                if (selection.isEmpty)
                  const Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: "無し",
                          style: TextStyle(fontSize: FontSizes.small),
                        ),
                        TextSpan(text: "  ( "),
                        TextSpan(
                          text: "｡",
                          style: TextStyle(fontSize: FontSizes.small),
                        ),
                        TextSpan(text: "- -"),
                        TextSpan(
                          text: "｡",
                          style: TextStyle(fontSize: FontSizes.small),
                        ),
                        TextSpan(text: ")zzZZ"),
                      ],
                    ),
                    style: TextStyle(textBaseline: TextBaseline.alphabetic),
                  )
                else
                  for (var i in selection..sort())
                    if (i == selection.reduce(max))
                      Text(" ${(i.toString().length == 2) ? i : "0$i"}")
                    else
                      Text(
                        " ${(i.toString().length == 2) ? i : "0$i"},",
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
