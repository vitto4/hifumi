import 'package:flutter/material.dart';
import 'package:hifumi/abstractions/ui/@screen_orientation.dart';
import 'package:hifumi/pages/lesson_contents/word_tile.dart';
import 'package:hifumi/services/services_barrel.dart';

const double _WORD_TILE_GRID_MAIN_AXIS_SPACING = 7.0;
const double _WORD_TILE_GRID_CROSS_AXIS_SPACING = 12.0;

/// Good job on scrolling down all the way here, this is the actual widget that displays all the [WordTile].
class WordGrid extends StatelessWidget {
  final List<Widget> wordTileList;

  const WordGrid({
    Key? key,
    required this.wordTileList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///   * Orientation is portrait ? One tile per line
    ///   * Orientation is landscape ? do whatever [getWordTilesCrossCount] says
    int crossAxisCount = (getOrientation(context) == ScreenOrientation.portrait) ? 1 : getWordTilesCrossCount(context);
    double screenWidth = getScreenDimensions(context).width;
    double aspectRatio =
        screenWidth /
        (crossAxisCount *
            WORD_TILE_HEIGHT); // Super duper advanced math that will keep the height of the tiles constant no matter the crossAxisCount >:)

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: _WORD_TILE_GRID_CROSS_AXIS_SPACING,
      mainAxisSpacing: _WORD_TILE_GRID_MAIN_AXIS_SPACING,
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      childAspectRatio: aspectRatio,
      children: wordTileList,
    );
  }
}
