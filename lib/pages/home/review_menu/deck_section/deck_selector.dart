import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/pages/home/review_menu/deck_section/deck_tile.dart";
import "package:hifumi/services/sp_interface.dart";
import "package:hifumi/widgets/seasoning/snack_toast.dart";

/// Used in the review quick settings and during quizzes.
class IslandDeckSelector extends StatefulWidget {
  final SPInterface st;

  /// Are choosing a deck to add words to, or to use when reviewing ?
  final bool areWeDoingAQuizATM;

  const IslandDeckSelector({
    Key? key,
    required this.st,
    required this.areWeDoingAQuizATM,
  }) : super(key: key);

  @override
  State<IslandDeckSelector> createState() => _IslandDeckSelectorState();
}

class _IslandDeckSelectorState extends State<IslandDeckSelector> {
  late Deck _selectedDeck;

  @override
  void initState() {
    super.initState();
    _selectedDeck = widget.areWeDoingAQuizATM ? widget.st.readTargetDeckInsert() : widget.st.readTargetDeckReview();
  }

  void selectionHandler(Deck deck) {
    Function(Deck) func = widget.areWeDoingAQuizATM ? widget.st.writeTargetDeckInsert : widget.st.writeTargetDeckReview;
    func.call(deck);
  }

  void resetHelper(BuildContext context, Deck deck) {
    widget.st.clearDeck.call(deck);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackToast.bar(text: "Deck ${deck.display} cleared successfully", confused: false),
    );
  }

  // Yup, spaghetti code right there ; but also since this widget is only used once no need to make it too reusable

  @override
  Widget build(BuildContext context) {
    return _Scaffold(
      one: DeckTile(
        deck: Deck.one,
        wordCount: widget.st.readDeck(Deck.one).length,
        selectedBackgroundColor: LightTheme.blueLighter,
        selectedBorderColor: LightTheme.blueLight,
        selectedTextColor: LightTheme.blue,
        isSelected: _selectedDeck == Deck.one,
        showClearButton: !(widget.areWeDoingAQuizATM),
        onTapped: () {
          selectionHandler(Deck.one);
          setState(() {
            _selectedDeck = Deck.one;
          });
        },
        onReset: () => resetHelper(context, Deck.one),
      ),
      two: DeckTile(
        deck: Deck.two,
        wordCount: widget.st.readDeck(Deck.two).length,
        selectedBackgroundColor: LightTheme.blueLighter,
        selectedBorderColor: LightTheme.blueLight,
        selectedTextColor: LightTheme.blue,
        isSelected: _selectedDeck == Deck.two,
        showClearButton: !(widget.areWeDoingAQuizATM),
        onTapped: () {
          selectionHandler(Deck.two);
          setState(() {
            _selectedDeck = Deck.two;
          });
        },
        onReset: () => resetHelper(context, Deck.two),
      ),
      three: DeckTile(
        deck: Deck.three,
        wordCount: widget.st.readDeck(Deck.three).length,
        selectedBackgroundColor: LightTheme.blueLighter,
        selectedBorderColor: LightTheme.blueLight,
        selectedTextColor: LightTheme.blue,
        isSelected: _selectedDeck == Deck.three,
        showClearButton: !(widget.areWeDoingAQuizATM),
        onTapped: () {
          selectionHandler(Deck.three);
          setState(() {
            _selectedDeck = Deck.three;
          });
        },
        onReset: () => resetHelper(context, Deck.three),
      ),
    );
  }
}

/// Extracted out of [IslandDeckSelector] to avoid code repetition.
class _Scaffold extends StatelessWidget {
  final Widget one;
  final Widget two;
  final Widget three;

  const _Scaffold({
    Key? key,
    required this.one,
    required this.two,
    required this.three,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        this.one,
        const SizedBox(
          height: 8.0,
        ),
        this.two,
        const SizedBox(
          height: 8.0,
        ),
        this.three,
      ],
    );
  }
}
