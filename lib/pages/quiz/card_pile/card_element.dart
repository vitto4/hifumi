import "package:flutter/material.dart";
import "package:hifumi/abstractions/ui/font_sizes.dart";
import "package:hifumi/abstractions/@symbols.dart";

/// Things one might want to sprinkle on a flashcard.
/// (i.e. {title + text} complex, as in `Kanji` : `新聞` for example)
class CardElement extends StatelessWidget {
  final String title;
  final String text;

  final double fontSize;
  final Color textColor;

  /// Writing system of [text]
  final Symbols symbols;

  const CardElement({
    Key? key,
    required this.title,
    required this.text,
    this.fontSize = 26.0,
    this.textColor = Colors.white,
    this.symbols = Symbols.latin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: FontSizes.nitpick, color: textColor.withValues(alpha: .5)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4.0),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor.withValues(alpha: .8),
            fontFamily: (symbols == Symbols.japanese) ? "NotoSansJP" : null,
            fontWeight: (symbols == Symbols.japanese) ? FontWeight.bold : null,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
