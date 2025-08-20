import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";

/// I'm not sure it is obvious what reviews are supposed to be.
/// This sections should clear things up. To be displayed in the review quick settings.
class ReviewWhatIsThis extends StatefulWidget {
  const ReviewWhatIsThis({
    Key? key,
  }) : super(key: key);

  @override
  State<ReviewWhatIsThis> createState() => _ReviewWhatIsThisState();
}

class _ReviewWhatIsThisState extends State<ReviewWhatIsThis> {
  bool _clicked = false;

  @override
  Widget build(BuildContext context) {
    return FlatIslandContainer(
      backgroundColor: LightTheme.base,
      borderColor: LightTheme.baseAccent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 13.0, 15.0, 13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "What is this ?",
                  style: TextStyle(
                    color: LightTheme.textColor,
                    fontSize: FontSizes.medium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IslandButton(
                  backgroundColor: _clicked ? LightTheme.blueLighter : LightTheme.base,
                  borderColor: _clicked ? LightTheme.blueLight : LightTheme.baseAccent,
                  offset: 1.3,
                  onTap: () => setState(() {
                    _clicked = !_clicked;
                  }),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.0,
                      vertical: 2.0,
                    ),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: _clicked ? LightTheme.blue : LightTheme.darkAccent,
                    ),
                  ),
                ),
              ],
            ),
            if (_clicked) ...[
              const SizedBox(
                height: 10.0,
              ),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: LightTheme.textColor,
                    fontFamily: "NotoEmoji",
                    fontFamilyFallback: ["Varela Round"],
                  ),
                  children: <InlineSpan>[
                    const TextSpan(
                      text: "Reviews",
                      style: TextStyle(fontWeight: FontWeight.bold, color: LightTheme.blue),
                    ),
                    const TextSpan(
                      text: " function like regular quizzes, but use words from decks (namely ",
                    ),
                    TextSpan(
                      text: Deck.one.display,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: LightTheme.textColorDim,
                      ),
                    ),
                    const TextSpan(
                      text: ", ",
                    ),
                    TextSpan(
                      text: Deck.two.display,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: LightTheme.textColorDim,
                      ),
                    ),
                    const TextSpan(
                      text: " and ",
                    ),
                    TextSpan(
                      text: Deck.three.display,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: LightTheme.textColorDim,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ") instead of lessons. You can add words to these during a quiz, or select some individually in each lesson's contents page.",
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
