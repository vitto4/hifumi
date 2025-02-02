import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";

/// Used only when the [IslandContainer] isn't in compact mode.
/// Otherwise, because of [smartExpand] and containers forcing tight constraints, this will be disregarded.
const double _FILTER_BUTTON_WIDTH = 180.0;

/// Quick settings section to select the filter to use when drawing words for a quiz.
class WordFilterSection extends StatefulWidget {
  final StorageInterface st;

  const WordFilterSection({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  State<WordFilterSection> createState() => _WordFilterSectionState();
}

class _WordFilterSectionState extends State<WordFilterSection> {
  late QuizWordFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.st.readQuizFilter();
  }

  @override
  Widget build(BuildContext context) {
    return FlatIslandContainer(
      backgroundColor: LightTheme.base,
      borderColor: LightTheme.baseAccent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 15.0, 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Filtering",
              style: TextStyle(
                color: LightTheme.textColor,
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text.rich(
              TextSpan(
                style: TextStyle(
                  color: LightTheme.textColor,
                  fontSize: FontSizes.base,
                ),
                children: <InlineSpan>[
                  TextSpan(text: "Filter to apply when drawing words.\n"),
                  WidgetSpan(
                    child: SizedBox(
                      height: 2 * FontSizes.base,
                    ),
                  ),
                  TextSpan(
                    text: "Note —",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: LightTheme.blue,
                    ),
                  ),
                  TextSpan(
                    text: " Each word is scored from zero to three : ",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                    ),
                  ),
                  TextSpan(
                    text: "+1",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " for a correct answer, ",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                    ),
                  ),
                  TextSpan(
                    text: "-1",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " for an incorrect one. Are flagged as ",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                    ),
                  ),
                  TextSpan(
                    text: "mastered",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " all words with a score of ",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                    ),
                  ),
                  TextSpan(
                    text: "3",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ".",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            IslandSegmentedSelector(
              leftBackgroundColor: _selectedFilter == QuizWordFilter.none ? LightTheme.blueLighter : LightTheme.base,
              leftBorderColor: _selectedFilter == QuizWordFilter.none ? LightTheme.blueLight : LightTheme.baseAccent,
              rightBackgroundColor: _selectedFilter == QuizWordFilter.mastered ? LightTheme.blueLighter : LightTheme.base,
              rightBorderColor: _selectedFilter == QuizWordFilter.mastered ? LightTheme.blueLight : LightTheme.baseAccent,
              compact: getQuizSegmentedSelectorCompactMode(context),
              onLeftTapped: () {
                widget.st.writeQuizFilter(QuizWordFilter.none);
                setState(() {
                  _selectedFilter = QuizWordFilter.none;
                });
              },
              onRightTapped: () {
                widget.st.writeQuizFilter(QuizWordFilter.mastered);
                setState(() {
                  _selectedFilter = QuizWordFilter.mastered;
                });
              },
              leftChild: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: SizedBox(
                  width: _FILTER_BUTTON_WIDTH,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "None",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedFilter == QuizWordFilter.none ? LightTheme.blue : LightTheme.textColorDim,
                          fontSize: FontSizes.big,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Include all words",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedFilter == QuizWordFilter.none ? LightTheme.blue : LightTheme.textColorDimmer,
                          fontSize: FontSizes.base,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              rightChild: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: SizedBox(
                  width: _FILTER_BUTTON_WIDTH,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Mastered",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedFilter == QuizWordFilter.mastered ? LightTheme.blue : LightTheme.textColorDim,
                          fontSize: FontSizes.big,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Exclude mastered words",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedFilter == QuizWordFilter.mastered ? LightTheme.blue : LightTheme.textColorDimmer,
                          fontSize: FontSizes.base,
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
    );
  }
}
