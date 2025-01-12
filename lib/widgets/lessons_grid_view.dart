import "package:flutter/material.dart";
import "package:hifumi/entities/@lesson_number.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/roofing/lesson_tile.dart";

const double _LESSON_TILE_HEIGHT = 99.0;
const double _LESSON_TILE_GRID_SPACING_HORIZONTAL = 10.0;
const double _LESSON_TILE_GRID_SPACING_VERTICAL = 10.0;

/// Represents the list of [LessonTile] widgets to be displayed. States are stored in [LessonTileState].
/// This is effectively a supercharged [GridView] able to perform operations over its dear [LessonTile] children.
///
/// Operations :
///   * [selectAll]
///   * [unselectAll]
///   * [updateScores]
///
/// This was unpleasant to make at best, I don't think I really get how state management is supposed to be done in flutter  ﹥∼﹤
class LessonTilesGridView extends StatelessWidget {
  final StorageInterface st;
  final DSInterface ds;

  /// Will be called with {[bool]: newSelectionState}. Should be used in the main menu to keep a local copy
  /// of the lesson selection ([List<LessonNumber>]) on top of what's stored in [shared_preferences].
  final Function(LessonNumber, bool) selectionCallback;

  /// List of all [LessonNumber] of lessons available in the dataset.
  late final List<LessonNumber> lessonNumbers;

  /// A map of keys to use when generating all the [LessonTile]s. This allows us to access their states on the fly.
  late final Map<LessonNumber, GlobalKey<LessonTileState>> keyMap;

  LessonTilesGridView({
    Key? key,
    required this.st,
    required this.ds,
    required this.selectionCallback,
  }) : super(key: key) {
    this.lessonNumbers = this.ds.lessonNumbers;
    this.keyMap = _buildKeyMap();
  }

  /// Build the [keyMap].
  Map<LessonNumber, GlobalKey<LessonTileState>> _buildKeyMap() {
    return {for (LessonNumber number in this.lessonNumbers) number: GlobalKey<LessonTileState>(debugLabel: "LessonTile #$number")};
  }

  /// Select all lessons. Is achieved by calling [LessonTileState.onTap] on all currently unselected tiles.
  void selectAll() {
    for (LessonNumber number in this.lessonNumbers) {
      // If it somehow fails and we get `null`, just ignore it (hence default to `true` = selected)
      !(this.keyMap[number]?.currentState?.isSelected ?? true) ? this.keyMap[number]!.currentState!.onTap() : null;
    }
  }

  /// Unselect all lessons. Is achieved by calling [LessonTileState.onTap] on all currently selected tiles.
  void unselectAll() {
    for (LessonNumber number in this.lessonNumbers) {
      // If it somehow fails and we get `null`, just ignore it (hence default to `false` = unselected)
      (this.keyMap[number]?.currentState?.isSelected ?? false) ? this.keyMap[number]!.currentState!.onTap() : null;
    }
  }

  /// (Politely) ask each lesson tile to update their scores.
  /// If there is no need to do so, it may (politely) decline.
  void updateScores() {
    for (LessonNumber number in this.lessonNumbers) {
      this.keyMap[number]?.currentState?.updateScore();
    }
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = getLessonTilesCrossCount(context);
    double screenWidth = getScreenDimensions(context).width;
    double aspectRatio = screenWidth /
        (crossAxisCount *
            _LESSON_TILE_HEIGHT); // Super duper advanced math that will keep the height of the tiles constant no matter the crossAxisCount >:3

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount.abs(),
        crossAxisSpacing: _LESSON_TILE_GRID_SPACING_HORIZONTAL,
        mainAxisSpacing: _LESSON_TILE_GRID_SPACING_VERTICAL,
        childAspectRatio: aspectRatio.abs(),
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: this.lessonNumbers.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        final LessonNumber currentNumber = index + 1;
        return LessonTile(
          key: this.keyMap[currentNumber],
          ds: ds,
          st: st,
          lesson: currentNumber,
          onTap: (newSelectionValue) {
            // Call the ̶e̶x̶o̶r̶c̶i̶s̶t̶\̶n̶B̶i̶s̶h̶o̶p̶ ̶w̶e̶n̶t̶ ̶o̶n̶ ̶v̶a̶c̶a̶t̶i̶o̶n̶,̶ ̶n̶e̶v̶e̶r̶ ̶c̶a̶m̶e̶ ̶b̶a̶c̶k main menu indicating which lesson was selected/unselected.
            this.selectionCallback(currentNumber, newSelectionValue);
          },
        );
      },
    );
  }
}
