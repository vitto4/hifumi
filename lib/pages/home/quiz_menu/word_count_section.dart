import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";

/// Quick settings section that allows users to configure the number of words displayed in each quiz session.
class WordCountSection extends StatefulWidget {
  final SPInterface st;

  const WordCountSection({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  State<WordCountSection> createState() => _WordCountSectionState();
}

class _WordCountSectionState extends State<WordCountSection> {
  late double _currentSliderValue;
  late WholeSelectionButtonState _wholeSelection;
  late final WholeSelectionButtonState _initialWholeSelection;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.st.readWordCountPerQuiz().toDouble();
    _initialWholeSelection = widget.st.readQuizDrawWholeSelection();
    _wholeSelection = _initialWholeSelection;
  }

  @override
  Widget build(BuildContext context) {
    return FlatIslandContainer(
      backgroundColor: LightTheme.base,
      borderColor: LightTheme.baseAccent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 20.0, 13.0, 30.0),
        child: _Scaffold(
          checkbox: IslandTextCheckbox(
            checkState: _wholeSelection,
            variantWithLongestText: WholeSelectionButtonState.yes,
            smartExpand: getWordCountSliderCompactMode(context),
            tapHandler: () {
              setState(() {
                _wholeSelection = _wholeSelection.opposite;
                widget.st.writeQuizDrawWholeSelection(_wholeSelection);
              });
            },
          ),
          slider: AbsorbPointer(
            absorbing: _wholeSelection.asBool,
            child: Slider(
              value: _currentSliderValue,
              max: D.WORD_COUNT_MAX.toDouble(),
              min: D.WORD_COUNT_MIN.toDouble(),
              divisions: 9,
              label: _currentSliderValue.round().toString(),
              activeColor: !(_wholeSelection.asBool) ? LightTheme.blue : LightTheme.baseAccent,
              inactiveColor: LightTheme.baseAccent,
              onChanged: (double value) {
                widget.st.writeWordCountPerQuiz(value.round());
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final IslandTextCheckbox checkbox;
  final AbsorbPointer slider;

  const _Scaffold({
    Key? key,
    required this.checkbox,
    required this.slider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Will affect the position of the `Whole selection` button
    final bool compact = getWordCountSliderCompactMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        !compact
            ? Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      "Words",
                      style: TextStyle(
                        color: LightTheme.textColor,
                        fontSize: FontSizes.medium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: this.checkbox,
                  ),
                ],
              )
            : const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  "Words",
                  style: TextStyle(
                    color: LightTheme.textColor,
                    fontSize: FontSizes.medium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        const SizedBox(
          height: 10.0,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text.rich(
            TextSpan(
              text: "Number of words to draw for each quiz. The",
              style: TextStyle(color: LightTheme.textColor),
              children: <TextSpan>[
                TextSpan(
                  text: " whole selection ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: "button will have all words from every selected lessons drawn."),
              ],
            ),
          ),
        ),
        SizedBox(
          height: compact ? 20.0 : 10.0,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  overlayShape: SliderComponentShape.noThumb,
                ),
                child: this.slider,
              ),
            ),
          ],
        ),
        // This looks weird but it works
        ...compact
            ? [
                const SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: this.checkbox,
                ),
              ]
            : [],
      ],
    );
  }
}

/// This one only has two states.
/// I'm a little lazy so don't hesitate to Shift+F12 to see what it's used for.
/// (If you're a vscode user, that is. If not, you probably know better than me what shortcut you should use.)
enum WholeSelectionButtonState with IslandTextCheckboxState {
  yes("Whole selection"),
  no("Whole selection");

  const WholeSelectionButtonState(this.text);

  @override
  final String text;

  @override
  Color get backgroundColor {
    switch (this) {
      case WholeSelectionButtonState.yes:
        return LightTheme.blueLighter;
      default:
        return LightTheme.base;
    }
  }

  @override
  Color get borderColor {
    switch (this) {
      case WholeSelectionButtonState.yes:
        return LightTheme.blueLight;
      default:
        return LightTheme.baseAccent;
    }
  }

  @override
  Color get textColor {
    switch (this) {
      case WholeSelectionButtonState.yes:
        return LightTheme.blue;
      default:
        return LightTheme.textColorDim;
    }
  }

  WholeSelectionButtonState get opposite => this == WholeSelectionButtonState.yes ? WholeSelectionButtonState.no : WholeSelectionButtonState.yes;

  bool get asBool => this == WholeSelectionButtonState.yes ? true : false;
}
