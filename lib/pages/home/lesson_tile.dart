import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/services/grayscale.dart";
import "package:hifumi/widgets/seasoning/shiny_progressbar.dart";
import "package:hifumi/widgets/archipelago/island_button.dart";
import "package:hifumi/pages/home/colorful_badge.dart";
import "package:hifumi/pages/lesson_detail.dart";

const Alignment _LESSON_TILE_PROGRESS_BAR_ALIGNMENT = Alignment(.0, .80);

/// Tile widget representing a lesson.
///
/// Yes, the folder is called `roofing` because this is a tile.
class LessonTile extends StatefulWidget {
  final DSInterface ds;
  final StorageInterface st;

  /// [LessonNumber] of the lesson this widget represents.
  final LessonNumber lesson;

  /// What happens when the user taps this [LessonTile] ?
  final Function(bool) onTap;

  const LessonTile({
    Key? key,
    required this.st,
    required this.ds,
    required this.lesson,
    required this.onTap,
  }) : super(key: key);

  @override
  State<LessonTile> createState() => LessonTileState();
}

class LessonTileState extends State<LessonTile> {
  /// Completion score of the lesson this widget represents.
  late LessonScore lessonScore;

  /// Selection state. Is the tile selected ?
  late bool isSelected;

  /// Get lesson completion score as a percentage.
  double get _completion => lessonScore[2];

  @override
  void initState() {
    super.initState();
    isSelected = widget.st.readSelectedLessons().contains(widget.lesson);
    lessonScore = widget.st.singleLessonScore(widget.ds, widget.lesson);
  }

  /// Select this [LessonTile].
  void select() {
    setState(() {
      isSelected = true;
    });
    widget.st.addSelectedLesson(widget.lesson);
  }

  /// Unselect this [LessonTile].
  void unselect() {
    setState(() {
      isSelected = false;
    });
    widget.st.removeSelectedLesson(widget.lesson);
  }

  /// On tap, select or unselect accordingly. We shall not forget to propagate this event up the widget tree,
  /// by also calling [LessonTile.onTap].
  void onTap() {
    isSelected ? unselect() : select();
    widget.onTap.call(isSelected);
  }

  /// This is called when the higher-ups decide so. To not waste resources, do not comply if we're already up-to-date.
  /// No worries, they won't get mad.
  void updateScore() {
    LessonScore perhapsNewScore = widget.st.singleLessonScore(widget.ds, widget.lesson);
    !(perhapsNewScore[2] == lessonScore[2])
        ? setState(
            () {
              lessonScore = perhapsNewScore;
            },
          )
        : null;
  }

  /// Display the lesson detail page, and update the score when popped.
  /// (it may have changed if the user reset progress for this lesson)
  void displayWordList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetail(lesson: widget.lesson, ds: widget.ds, st: widget.st),
        barrierDismissible: true,
      ),
    ).then((_) {
      updateScore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = (getLessonTilesCrossCount(context) < 0);

    return IslandButton(
      backgroundColor: (isSelected) ? LightTheme.greenLighter : LightTheme.base,
      borderColor: (isSelected) ? LightTheme.green : LightTheme.baseAccent,
      offset: 4.0,
      onTap: onTap,
      onLongPress: displayWordList,
      tapDuration: Duration(milliseconds: 30),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: _LESSON_TILE_PROGRESS_BAR_ALIGNMENT,
            // https://stackoverflow.com/questions/59499901/why-doesnt-container-respect-the-size-it-was-given <-- vestige of me learning flutter on the job
            child: ShinyProgressBar(
              color: (isSelected) ? LightTheme.orange.grayScale : LightTheme.orange,
              completionPercentage: _completion,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 11.0),
                child: Align(
                  alignment: const Alignment(.0, -.15),
                  child: Text(
                    (widget.lesson.toString().length == 2) ? widget.lesson.toString() : "0${widget.lesson}",
                    style: const TextStyle(
                      fontSize: 30.0,
                      color: LightTheme.textColorDimmer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: Align(
                  alignment: const Alignment(.0, -.15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // Compact mode shows both mastered and total count of words in a single badge
                    children: (compact)
                        ? <Widget>[
                            ColorfulBadge(
                              backgroundColorLeft: (isSelected) ? LightTheme.greenLighter.grayScale : LightTheme.greenLighter,
                              backgroundColorRight: (isSelected) ? LightTheme.green.grayScale : LightTheme.green,
                              childLeft: Text(
                                (lessonScore[0].floor().toString().length == 2) ? lessonScore[0].floor().toString() : "0${lessonScore[0].floor()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (isSelected) ? LightTheme.green.grayScale : LightTheme.green,
                                ),
                              ),
                              childRight: Text(
                                "${lessonScore[1].floor()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: LightTheme.base,
                                ),
                              ),
                            ),
                          ]
                        : <Widget>[
                            ColorfulBadge(
                              backgroundColorLeft: (isSelected) ? LightTheme.blueLighter.grayScale : LightTheme.blueLighter,
                              backgroundColorRight: (isSelected) ? LightTheme.blue.grayScale : LightTheme.blue,
                              childLeft: Text(
                                "Mastered",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (isSelected) ? LightTheme.blue.grayScale : LightTheme.blue,
                                ),
                              ),
                              childRight: Text(
                                (lessonScore[0].floor().toString().length == 2) ? lessonScore[0].floor().toString() : "0${lessonScore[0].floor()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: LightTheme.base,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 25.0,
                            ),
                            ColorfulBadge(
                              backgroundColorLeft: (isSelected) ? LightTheme.greenLighter.grayScale : LightTheme.greenLighter,
                              backgroundColorRight: (isSelected) ? LightTheme.green.grayScale : LightTheme.green,
                              childLeft: Text(
                                "Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (isSelected) ? LightTheme.green.grayScale : LightTheme.green,
                                ),
                              ),
                              childRight: Text(
                                "${lessonScore[1].floor()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: LightTheme.base,
                                ),
                              ),
                            ),
                          ],
                  ),
                ),
              ),
            ],
          ),
          Opacity(
            opacity: .1,
            child: Container(
              color: (isSelected) ? LightTheme.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
