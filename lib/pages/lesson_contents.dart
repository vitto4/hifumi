import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/pages/lesson_contents/word_grid.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/island_double_tap_button.dart";
import "package:hifumi/widgets/seasoning/text_separator.dart";
import "package:hifumi/widgets/seasoning/snack_toast.dart";
import "package:hifumi/pages/lesson_contents/lesson_contents_header.dart";
import "package:hifumi/pages/lesson_contents/word_tile.dart";

/// Gotta know what you'll be quizzed on ; also it's great to be able to access the vocab on the go.
/// (or you could just ̶u̶s̶e̶ ̶P̶e̶t̶r̶u̶s bring your textbooks with you, has the same effect but is a little cumbersome)
class LessonContents extends StatelessWidget {
  final SPInterface st;
  final DSInterface ds;

  /// The only thing we need to know is the lesson to build the word list for.
  final LessonNumber lesson;

  const LessonContents({
    Key? key,
    required this.st,
    required this.ds,
    required this.lesson,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LessonScore lessonScore = st.singleLessonScore(ds, lesson);
    final List<Word> wordList = ds.getLessonAllWords(lesson, pruneEditions: true);
    List<WordTile> wordTileList = [];

    /// Build all the [WordTile] we need.
    for (Word word in wordList) {
      wordTileList.add(WordTile(word: word, st: st));
    }

    // Vertical spacing between the title and the beginning of the actual list of words
    // Or technically only a fraction of it, you'll see what I mean soon enough
    final double delayHeight = getScrollDelayHeight(context) * .2;

    return LessonContentsHeader(
      lesson: this.lesson,
      child: Material(
        color: LightTheme.base,
        child: FractionallySizedBox(
          widthFactor: .93,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 1.0 * delayHeight,
              ),
              const Text(
                "Statistics",
                style: TextStyle(
                  color: LightTheme.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSizes.medium,
                ),
              ),
              const SizedBox(
                height: 2.0,
              ),
              Text.rich(
                TextSpan(
                  text: "",
                  style: const TextStyle(
                    color: LightTheme.textColorDim,
                  ),
                  children: <InlineSpan>[
                    const TextSpan(
                      text: "You have mastered ",
                    ),
                    TextSpan(
                      text: (lessonScore[0].floor().toString().length == 2) ? lessonScore[0].floor().toString() : "0${lessonScore[0].floor()}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: " words out of ",
                    ),
                    TextSpan(
                      text: "${lessonScore[1].floor()}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: " in this lesson.\nTaking scores into account, this equates to ",
                    ),
                    TextSpan(
                      text: "${(lessonScore[2] * 100).floor()}%",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: " completion.",
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: FontSizes.nitpick,
                ),
              ),
              SizedBox(
                height: .3 * delayHeight,
              ),
              /* ---------------------------- The reset button ---------------------------- */
              SizedBox(
                height: 35.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IslandDoubleTapButton(
                      animationDuration: Duration.zero,
                      timerDuration: const Duration(seconds: 3),
                      firstBackgroundColor: Colors.transparent,
                      firstBorderColor: Colors.transparent,
                      secondBackgroundColor: Colors.transparent,
                      secondBorderColor: Colors.transparent,
                      offset: .0,
                      onSecondTap: () {
                        st.resetLessonScore(lesson);
                        // Once reset, because I'm too lazy to write a callback that updates all the [WordTile] accordingly, just pop the whole page
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackToast.bar(text: "Lesson $lesson reset successfully", confused: false),
                        );
                      },
                      firstChild: const Padding(
                        padding: EdgeInsets.fromLTRB(12.0, 3.0, 12.0, .0),
                        child: Text(
                          "RESET",
                          style: TextStyle(
                            color: LightTheme.red,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizes.base,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, .0, 12.0, 2.5),
                        child: Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: "(；'-' )",
                                style: TextStyle(
                                  color: LightTheme.red.withValues(alpha: .3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSizes.big,
                                ),
                              ),
                              const WidgetSpan(
                                child: SizedBox(
                                  width: 10.0,
                                ),
                              ),
                              TextSpan(
                                text: "Reset progress for lesson ${this.lesson} ?",
                                style: const TextStyle(
                                  fontSize: FontSizes.nitpick,
                                  fontWeight: FontWeight.bold,
                                  color: LightTheme.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              /* ------------------------------------ . ----------------------------------- */
              SizedBox(
                height: .3 * delayHeight,
              ),
              const TextSeparator(text: "Words"),
              SizedBox(height: .8 * delayHeight),
              const Text.rich(
                TextSpan(
                  text: "Use the buttons to the side of each word to ",
                  style: TextStyle(
                    color: LightTheme.textColorDim,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: "add",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: " or ",
                    ),
                    TextSpan(
                      text: "remove",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: " it from a deck.",
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: FontSizes.nitpick,
                ),
              ),
              SizedBox(height: 1.5 * delayHeight),
              WordGrid(
                wordTileList: wordTileList,
              ),
              const SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
