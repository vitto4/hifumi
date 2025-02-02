import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/storage_interface.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";
import "package:hifumi/widgets/seasoning/snack_toast.dart";

/// Used in the review quick settings and during quizzes.
class IslandDeckSelector extends StatefulWidget {
  final StorageInterface st;

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
      SnackToast.bar(text: "Deck ${deck.display} reset successfully", confused: false),
    );
  }

  // Yup, spaghetti code right there ; but also since this widget is only used once no need to make it too reusable

  @override
  Widget build(BuildContext context) {
    return _Scaffold(
      one: DeckTile(
        deck: Deck.one,
        cardCount: widget.st.readDeck(Deck.one).length,
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
        cardCount: widget.st.readDeck(Deck.two).length,
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
        cardCount: widget.st.readDeck(Deck.three).length,
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
        this.three
      ],
    );
  }
}

/// Tile used to select a deck. Includes a reset button that requires double-tap confirmation.
class DeckTile extends StatefulWidget {
  final Deck deck;
  final int cardCount;

  final Color selectedBackgroundColor;
  final Color selectedBorderColor;
  final Color selectedTextColor;

  final bool isSelected;
  final bool showClearButton;
  final Function onTapped;
  final Function onReset;

  const DeckTile({
    Key? key,
    required this.deck,
    required this.selectedBackgroundColor,
    required this.selectedBorderColor,
    required this.selectedTextColor,
    required this.isSelected,
    required this.onTapped,
    required this.onReset,
    required this.showClearButton,
    required this.cardCount,
  }) : super(key: key);

  @override
  State<DeckTile> createState() => _DeckTileState();
}

class _DeckTileState extends State<DeckTile> {
  @override
  Widget build(BuildContext context) {
    return IslandButton(
        smartExpand: true,
        onTap: () => widget.onTapped.call(),
        backgroundColor: widget.isSelected ? widget.selectedBackgroundColor : LightTheme.base,
        borderColor: widget.isSelected ? widget.selectedBorderColor : LightTheme.baseAccent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, .0, 20.0, .0),
          child: Row(
            children: <Widget>[
              const SizedBox(
                height: 50.0,
              ),
              Text(
                widget.deck.display,
                style: TextStyle(
                    fontSize: FontSizes.huge,
                    fontWeight: FontWeight.bold,
                    color: widget.isSelected ? widget.selectedTextColor : LightTheme.textColorDimmer),
              ),
              const Spacer(),
              Text(
                widget.cardCount.toString(),
                style: TextStyle(
                    fontSize: FontSizes.base,
                    fontWeight: FontWeight.bold,
                    color: widget.isSelected ? widget.selectedTextColor : LightTheme.textColorDimmer),
              ),
              SizedBox(
                width: 15.0,
              ),
              if (widget.showClearButton)
                IslandDoubleTapButton(
                  timerDuration: const Duration(seconds: 3),
                  offset: .0,
                  animationDuration: Duration.zero,
                  firstBackgroundColor: Colors.transparent,
                  firstBorderColor: Colors.transparent,
                  secondBackgroundColor: Colors.transparent,
                  secondBorderColor: Colors.transparent,
                  onSecondTap: () => widget.onReset.call(),
                  firstChild: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, .0),

                    /// Leaving this here in case I ever need it, these were the candidates for the `reset` icon :
                    /// * bolt
                    /// * blur_on
                    /// * bedtime_outlined / rounded
                    /// * auto_awesome_outlined
                    /// * clear_all
                    ///
                    /// In the end plain text works just fine.
                    child: Text(
                      "RESET",
                      style: TextStyle(
                        color: widget.isSelected ? LightTheme.blue : LightTheme.red,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSizes.base,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, .0, 10.0, 2.5),
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: "(；'-' )",
                            style: TextStyle(
                              color: widget.isSelected ? LightTheme.blue.withValues(alpha: .4) : LightTheme.red.withValues(alpha: .55),
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
                            text: "Sure ?",
                            style: TextStyle(
                              fontSize: FontSizes.nitpick,
                              fontWeight: FontWeight.bold,
                              color: widget.isSelected ? LightTheme.blue : LightTheme.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ));
  }
}
