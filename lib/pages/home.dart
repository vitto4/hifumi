import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/abstractions/ui/@screen_orientation.dart";
import "package:hifumi/pages/home/selection_as_list.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/island_text_checkbox.dart";
import "package:hifumi/pages/home/quiz_menu/quiz_menu.dart";
import "package:hifumi/pages/home/lesson_grid/lesson_selection_state.dart";
import "package:hifumi/pages/home/home_combo_button.dart";
import "package:hifumi/widgets/overlays/tray_dialog.dart" as tray;
import "package:hifumi/pages/home/home_header.dart";
import "package:hifumi/widgets/seasoning/text_separator.dart";
import "package:hifumi/widgets/seasoning/snack_toast.dart";
import "package:hifumi/pages/home/review_menu/review_menu.dart";
import "package:hifumi/pages/home/lesson_grid/lesson_grid.dart";
import "package:hifumi/pages/home/lesson_grid/lesson_tile.dart";

/// Called it home because that's what everyone does, but it is really more of a main menu.
/// So please think `MainMenu` whenever you read [Home], thanks.
class Home extends StatefulWidget {
  final SPInterface st;
  final DSInterface ds;

  const Home({
    Key? key,
    required this.st,
    required this.ds,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// Very much unclear name, but it's supposed to represent the general selection state of lessons, as in :
  ///   * All (everything is selected)
  ///   * Misc (some are selected)
  ///   * None
  late LessonSelectionState _lessonSelectionButtonState;

  /// List of selected lessons, will be updated as user interacts with the app.
  /// We could just [SPInterface.readSelectedLessons], but also having it stored in the state should be faster and safer.
  /// (source : tkt)
  ///
  /// Yes, yes, here's the [meaning](https://www.urbandictionary.com/define.php?term=tkt)
  late List<LessonNumber> _selection;

  /// See [LessonGrid].
  /// We store this as a variable because we'll have to call some of its methods outside of the [build] function.
  late final LessonGrid _lessonTileList;

  @override
  void initState() {
    super.initState();

    _selection = widget.st.readSelectedLessons();

    _lessonSelectionButtonState = this._allSelected
        ? LessonSelectionState.all
        : this._noneSelected
        ? LessonSelectionState.none
        : LessonSelectionState.neutral;

    _lessonTileList = LessonGrid(
      ds: widget.ds,
      st: widget.st,
      selectionCallback: (LessonNumber number, bool newSelectionValue) {
        // Were we previously in a special state ? The query should be made before we change anything in [selection]
        bool prevSpecialState = _allSelected | _noneSelected;

        // Reflect the new state in our local copy ([selection])
        setState(() {
          (newSelectionValue) ? _selection.add(number) : _selection.remove(number);
        });

        // Update the lesson selection button accordingly. For a transition to occur, it should transition to or from a [prevSpecialState]
        if (!prevSpecialState && _allSelected) {
          setState(() {
            _lessonSelectionButtonState = LessonSelectionState.all;
          });
        } else if (!prevSpecialState && _noneSelected) {
          setState(() {
            _lessonSelectionButtonState = LessonSelectionState.none;
          });
        } else if (prevSpecialState) {
          setState(() {
            _lessonSelectionButtonState = LessonSelectionState.neutral;
          });
        }
      },
    );
  }

  /// Are all [LessonTile]s currently selected ?
  bool get _allSelected => (this._selection.length == widget.ds.lessonNumbers.length);

  /// Is the [LessonTile] selection currently empty ?
  bool get _noneSelected => this._selection.isEmpty;

  void _toggleLessonSelection() {
    switch (_lessonSelectionButtonState) {
      case LessonSelectionState.all:
        _lessonTileList.unselectAll();
        break;
      case LessonSelectionState.none:
        _lessonTileList.selectAll();
        break;
      case LessonSelectionState.neutral:
        _lessonTileList.unselectAll();
        break;
    }
  }

  /* ------------------------- [ComboButton] callbacks ------------------------ */

  void _onPrimaryLeft() {
    if (_selection.isNotEmpty) {
      Navigator.pushNamed(
        context,
        "/quiz",
        arguments: {
          "st": widget.st,
          "ds": widget.ds,
          "review": false,
        },
      ).then(
        (_) {
          _lessonTileList.updateScores.call();
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackToast.bar(text: "Select a lesson first"),
      );
    }
  }

  void _onSecondaryLeft() {
    tray.showTrayDialog(
      context: context,
      backgroundColor: LightTheme.base,
      pillColor: LightTheme.darkAccent,
      child: QuizMenu(
        st: widget.st,
      ),
    );
  }

  void _onPrimaryRight() {
    final Deck targetDeck = widget.st.readTargetDeckReview();

    if (widget.st.readDeck(targetDeck).isNotEmpty) {
      Navigator.pushNamed(
        context,
        "/quiz",
        arguments: {
          "st": widget.st,
          "ds": widget.ds,
          "review": true,
        },
      ).then(
        (_) {
          _lessonTileList.updateScores.call();
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackToast.bar(
          text: "Deck ${targetDeck.display} is empty",
        ),
      );
    }
  }

  void _onSecondaryRight() {
    tray.showTrayDialog(
      context: context,
      backgroundColor: LightTheme.base,
      pillColor: LightTheme.darkAccent,
      child: ReviewMenu(
        st: widget.st,
      ),
    );
  }

  /* ------------------------------------ . ----------------------------------- */

  @override
  Widget build(BuildContext context) {
    final double delayHeight = getScrollDelayHeight(context);
    final bool landscape = getOrientation(context) == ScreenOrientation.landscape;

    Row selectionFeedback = Row(
      children: <Widget>[
        const Text(
          "Current selection",
          style: TextStyle(
            color: LightTheme.blue,
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.medium,
          ),
        ),
        const SizedBox(width: 15.0),
        IslandTextCheckbox(
          checkState: _lessonSelectionButtonState,
          variantWithLongestText: LessonSelectionState.neutral,
          tapHandler: _toggleLessonSelection,
          compact: true,
        ),
        if (getCurrentSelectionSingleLine(context)) ...[
          const SizedBox(width: 15.0),
          // Black magic ahead, constraints won't be passed down to `SelectionAsList` unless I use that `Flexible` widget.
          Flexible(child: SelectionAsList(selection: _selection)),
        ],
      ],
    );

    Text explanation = Text.rich(
      const TextSpan(
        text: "Select the lessons you want to be quizzed on.",
        style: TextStyle(
          color: LightTheme.textColorDim,
        ),
        children: <InlineSpan>[
          TextSpan(
            text: " Long press",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: " on a lesson to reveal its contents."),
        ],
      ),
      style: TextStyle(
        fontSize: landscape ? FontSizes.nitpick : FontSizes.base,
      ),
    );

    /* ------------------------------------ . ----------------------------------- */

    return Scaffold(
      body: SafeArea(
        child: HomeHeader(
          openSettings: () {
            Navigator.pushNamed(
              context,
              "/settings",
              arguments: {
                "st": widget.st,
                "ds": widget.ds,
              },
            );
          },
          child: FractionallySizedBox(
            widthFactor: .91,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: (landscape ? 4 / 5 : 2 / 5) * delayHeight,
                ),
                HomeComboButton(
                  onPrimaryLeft: _onPrimaryLeft,
                  onPrimaryRight: _onPrimaryRight,
                  onSecondaryLeft: _onSecondaryLeft,
                  onSecondaryRight: _onSecondaryRight,
                ),
                SizedBox(
                  height: (landscape ? 2 / 5 : 3 / 5) * delayHeight,
                ),
                const TextSeparator(text: "Lessons"),
                SizedBox(
                  height: (landscape ? 1 / 5 : 2 / 5) * delayHeight,
                ),
                explanation,
                const SizedBox(
                  height: 20.0,
                ),
                selectionFeedback,
                if (!getCurrentSelectionSingleLine(context)) ...[
                  const SizedBox(height: 6.0),
                  SelectionAsList(selection: _selection),
                ],
                SizedBox(
                  height: (landscape ? 2 / 5 : 3 / 5) * delayHeight,
                ),
                _lessonTileList,
                const SizedBox(
                  height: 50.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
