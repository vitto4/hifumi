import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";

/// ̶̶I̶ ̶m̶a̶d̶e̶ ̶t̶h̶i̶s̶ ̶a̶w̶e̶s̶o̶m̶e̶ ̶s̶e̶p̶a̶r̶a̶t̶o̶r̶ ̶d̶e̶s̶i̶g̶n̶.
/// The folks over at Duolingo came up with this awesome separator design.
class TextSeparator extends StatelessWidget {
  final String text;

  const TextSeparator({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          flex: 1,
          child: Divider(color: LightTheme.baseAccent, thickness: 2.5),
        ),
        const SizedBox(
          width: 17.0,
        ),
        Text(
          this.text,
          style: const TextStyle(
            color: LightTheme.textColorDimmer,
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.separator,
          ),
        ),
        const SizedBox(
          width: 17.0,
        ),
        const Expanded(
          flex: 1,
          child: Divider(
            color: LightTheme.baseAccent,
            thickness: 2.5,
          ),
        ),
      ],
    );
  }
}
