import "dart:math";
import "dart:ui";
import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/island_text_checkbox.dart";
import "package:hifumi/widgets/drawer/tray_dialog.dart" as tray;
import "package:hifumi/widgets/topping/main_menu_top_bar.dart";
import "package:hifumi/widgets/seasoning/text_separator.dart";
import "package:hifumi/widgets/seasoning/snack_toast.dart";
import "package:hifumi/widgets/drawer/quick_settings.dart";
import "package:hifumi/widgets/lessons_grid_view.dart";
import "package:hifumi/widgets/roofing/lesson_tile.dart";
import "package:hifumi/widgets/combo_button.dart";

/// Called it home because that's what everyone does, but it is really more of a main menu.
/// So please think `MainMenu` whenever you read [Home], thanks.
class Home extends StatefulWidget {
  final StorageInterface st;
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
  late TristateLessonSelectionState lessonSelectionButtonState;

  /// List of selected lessons, will be updated as user interacts with the app.
  /// We could just [StorageInterface.readSelectedLessons], but also having it stored in the state should be faster and safer.
  /// (source : tkt)
  ///
  /// Yes, yes, here's the [meaning](https://www.urbandictionary.com/define.php?term=tkt)
  late List<LessonNumber> selection;

  /// See [LessonTilesGridView].
  /// We store this as a variable because we'll have to call some of its methods outside of the [build] function.
  late final LessonTilesGridView lessonTileList;

  @override
  void initState() {
    super.initState();

    selection = widget.st.readSelectedLessons();

    lessonSelectionButtonState = this.allSelected
        ? TristateLessonSelectionState.all
        : this.noneSelected
            ? TristateLessonSelectionState.none
            : TristateLessonSelectionState.neutral;

    lessonTileList = LessonTilesGridView(
      ds: widget.ds,
      st: widget.st,
      selectionCallback: (LessonNumber number, bool newSelectionValue) {
        // Were we previously in a special state ? The query should be made before we change anything in [selection]
        bool prevSpecialState = allSelected | noneSelected;

        // Reflect the new state in our local copy ([selection])
        setState(() {
          (newSelectionValue) ? selection.add(number) : selection.remove(number);
        });

        // Update the lesson selection button accordingly. For a transition to occur, it should transition to or from a [prevSpecialState]
        if (!prevSpecialState && allSelected) {
          setState(() {
            lessonSelectionButtonState = TristateLessonSelectionState.all;
          });
        } else if (!prevSpecialState && noneSelected) {
          setState(() {
            lessonSelectionButtonState = TristateLessonSelectionState.none;
          });
        } else if (prevSpecialState) {
          setState(() {
            lessonSelectionButtonState = TristateLessonSelectionState.neutral;
          });
        }
      },
    );
  }

  /// Are all [LessonTile]s currently selected ?
  bool get allSelected => (this.selection.length == widget.ds.lessonNumbers.length);

  /// Is the [LessonTile] selection currently empty ?
  bool get noneSelected => this.selection.isEmpty;

  void toggleLessonSelection() {
    switch (lessonSelectionButtonState) {
      case TristateLessonSelectionState.all:
        lessonTileList.unselectAll();
        break;
      case TristateLessonSelectionState.none:
        lessonTileList.selectAll();
        break;
      case TristateLessonSelectionState.neutral:
        lessonTileList.unselectAll();
        break;
    }
  }

  /* ------------------------- [ComboButton] callbacks ------------------------ */

  void onPrimaryLeft() {
    if (selection.isNotEmpty) {
      Navigator.pushNamed(context, "/quiz", arguments: {
        "st": widget.st,
        "ds": widget.ds,
        "review": false,
      }).then(
        (_) {
          lessonTileList.updateScores.call();
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackToast.bar(text: "Select a lesson first"),
      );
    }
  }

  void onSecondaryLeft() {
    tray.showTrayDialog(
      context: context,
      backgroundColor: LightTheme.base,
      pillColor: LightTheme.darkAccent,
      child: QuizQuickSettings(
        st: widget.st,
      ),
    );
  }

  void onPrimaryRight() {
    final Deck targetDeck = widget.st.readTargetDeckReview();

    if (widget.st.readDeck(targetDeck).isNotEmpty) {
      Navigator.pushNamed(context, "/quiz", arguments: {
        "st": widget.st,
        "ds": widget.ds,
        "review": true,
      }).then(
        (_) {
          lessonTileList.updateScores.call();
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

  void onSecondaryRight() {
    tray.showTrayDialog(
      context: context,
      backgroundColor: LightTheme.base,
      pillColor: LightTheme.darkAccent,
      child: ReviewQuickSettings(
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
          checkState: lessonSelectionButtonState,
          variantWithLongestText: TristateLessonSelectionState.neutral,
          tapHandler: toggleLessonSelection,
          compact: true,
        ),
        if (getCurrentSelectionSingleLine(context)) ...[
          const SizedBox(width: 15.0),
          // Black magic ahead, constraints won't be passed down to `SelectionAsList` unless I use that `Flexible` widget.
          Flexible(child: SelectionAsList(selection: selection)),
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
        child: MainMenuTopBar(
          openSettings: () {
            Navigator.pushNamed(context, "/settings", arguments: {
              "st": widget.st,
              "ds": widget.ds,
            });
          },
          child: FractionallySizedBox(
            widthFactor: .91,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: (landscape ? 4 / 5 : 2 / 5) * delayHeight,
                ),
                MainMenuComboButton(
                  onPrimaryLeft: onPrimaryLeft,
                  onPrimaryRight: onPrimaryRight,
                  onSecondaryLeft: onSecondaryLeft,
                  onSecondaryRight: onSecondaryRight,
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
                  SelectionAsList(selection: selection),
                ],
                SizedBox(
                  height: (landscape ? 2 / 5 : 3 / 5) * delayHeight,
                ),
                lessonTileList,
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

/// Feedback on what's selected. Nothing more than a list of the [LessonNumber] of all selected lessons.
class SelectionAsList extends StatelessWidget {
  const SelectionAsList({
    Key? key,
    required this.selection,
  }) : super(key: key);

  final List<LessonNumber> selection;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 500,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: LightTheme.baseAccent,
        borderRadius: BorderRadius.circular(5.0),
      ),
      height: 22.0,
      padding: const EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 3.0),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: LightTheme.textColorDim,
              fontFamily: "Varela Round",
              fontSize: FontSizes.base,
            ),
            child: Row(
              children: <Widget>[
                if (selection.isEmpty)
                  const Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: "無し",
                          style: TextStyle(fontSize: FontSizes.small),
                        ),
                        TextSpan(text: "  ( "),
                        TextSpan(
                          text: "｡",
                          style: TextStyle(fontSize: FontSizes.small),
                        ),
                        TextSpan(text: "- -"),
                        TextSpan(
                          text: "｡",
                          style: TextStyle(fontSize: FontSizes.small),
                        ),
                        TextSpan(text: ")zzZZ"),
                      ],
                    ),
                    style: TextStyle(textBaseline: TextBaseline.alphabetic),
                  )
                else
                  for (var i in selection..sort())
                    if (i == selection.reduce(max))
                      Text(" ${(i.toString().length == 2) ? i : "0$i"}")
                    else
                      Text(
                        " ${(i.toString().length == 2) ? i : "0$i"},",
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
