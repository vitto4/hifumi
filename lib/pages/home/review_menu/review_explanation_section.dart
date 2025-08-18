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
  bool clicked = false;

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
                  backgroundColor: clicked ? LightTheme.blueLighter : LightTheme.base,
                  borderColor: clicked ? LightTheme.blueLight : LightTheme.baseAccent,
                  offset: 1.3,
                  onTap: () => setState(() {
                    clicked = !clicked;
                  }),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.0,
                      vertical: 2.0,
                    ),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: clicked ? LightTheme.blue : LightTheme.darkAccent,
                    ),
                  ),
                ),
              ],
            ),
            if (clicked) ...[
              const SizedBox(
                height: 10.0,
              ),
              const Text.rich(
                TextSpan(
                  style: TextStyle(color: LightTheme.textColor),
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Reviews",
                      style: TextStyle(fontWeight: FontWeight.bold, color: LightTheme.blue),
                    ),
                    TextSpan(
                      text: " function like regular quizzes, but use words from decks (namely ",
                    ),
                    TextSpan(
                      text: "一 ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ", ",
                    ),
                    TextSpan(
                      text: "二",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: " and ",
                    ),
                    TextSpan(
                      text: "三",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          " ) instead of lessons. You can add words to these during a quiz, or select some individually in each lesson's detail page.",
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
