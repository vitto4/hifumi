import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";

class QuizWhatIsThis extends StatefulWidget {
  final SPInterface st;

  const QuizWhatIsThis({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  State<QuizWhatIsThis> createState() => _QuizWhatIsThisState();
}

class _QuizWhatIsThisState extends State<QuizWhatIsThis> {
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
                    fontFamily: "Varela Round",
                  ),
                  children: <InlineSpan>[
                    const TextSpan(
                      text: "Your standard flashcards quiz",
                    ),
                    const TextSpan(
                      text: ". Swipe ",
                    ),
                    TextSpan(
                      text: widget.st.readCorrectSide().display.toLowerCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: LightTheme.textColor,
                      ),
                    ),
                    const TextSpan(
                      text: " when you know the word, ",
                    ),
                    TextSpan(
                      text: ((widget.st.readCorrectSide() == CorrectSide.l) ? CorrectSide.r : CorrectSide.l).display.toLowerCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: LightTheme.textColor,
                      ),
                    ),
                    const TextSpan(
                      text: " when you don't. Change this behaviour in the settings and edit what appears on each side of the card.",
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
