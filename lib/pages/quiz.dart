import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/drawer/deck_insert_section.dart";
import "package:hifumi/widgets/drawer/tray_dialog.dart" as tray;
import "package:hifumi/widgets/seasoning/snack_toast.dart";
import "package:hifumi/widgets/topping/quiz_top_bar.dart";
import "package:hifumi/widgets/casino/card_pile.dart";
import "package:hifumi/widgets/combo_button.dart";
import "package:url_launcher/url_launcher.dart";

/// Probably the most important page of the app.
/// This is where you play your (flash)cards.
///
/// * Note : Despite the name, this is also the page used for "reviews".
class QuizPage extends StatefulWidget {
  final StorageInterface st;
  final DSInterface ds;

  /// Are we displaying the page for a review ?
  /// (else, it's a quiz)
  final bool review;

  const QuizPage({
    Key? key,
    required this.st,
    required this.ds,
    required this.review,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  /// To be displayed in the top-right corner, indicates the source deck for a review, or `"Q"` for a regular quiz.
  late final String quizSource;

  /// The list of flashcards to be displayed in the [CardPile].
  late List<Flashcard> _flashcards;

  /// `true` if the add to/remove from deck button should add the word the deck.
  /// `false` if the word is already in the deck and we want to remove it when the button is pressed.
  late bool deckButtonAddOrRemove;

  /// You know the variable name is bad when even you can't remember what it's about haha
  /// Deck that is currently selected as receiving words when the user clicks on the add to deck button.
  late Deck targetDeckInsert;

  /// Keyboard focus.
  /// This used to be such a hassle, but then I found this [wonderful video](https://www.youtube.com/watch?v=JCDfh5bs1xc)
  /// Gotta hand it to the flutter team, they do an amazing job at documenting their framework !
  late FocusNode _node;

  /// This, on the contrary of [targetDeckInsert], is pretty self-explanatory.
  int currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _node = FocusNode(debugLabel: "cardToFlip");

    // If we're in a review, only allow to remove from said deck
    targetDeckInsert = switch (widget.review) {
      true => widget.st.readTargetDeckReview(),
      false => widget.st.readTargetDeckInsert(),
    };

    // If we're dealing with a regular quiz
    if (!widget.review) {
      quizSource = "Q";

      // Does the user want to be quizzed on all the words `= 0`, or only a finite number `int <number>` of them ?
      int count = (widget.st.readQuizDrawWholeSelection().asBool) ? 0 : widget.st.readWordCountPerQuiz();

      // List of lessons to pick words from
      List<LessonNumber> lessons = widget.st.readSelectedLessons();

      // Filter to use when drawing words
      QuizWordFilter filter = widget.st.readQuizFilter();

      if (filter == QuizWordFilter.none) {
        _flashcards = dealCardsFromLessons(widget.st, widget.ds, lessons, count);
      } else {
        // Else we know [filter] == [QuizWordFilter.mastered]
        _flashcards = dealCardsFromMistakes(widget.st, widget.ds, lessons, count);
        // It may happen that all words from the selection have been mastered
        if (_flashcards.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // In that case we pop back out of the quiz
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackToast.bar(text: "You've mastered all the words in your selection. Check the filter you set !"),
            );
          });
        }
      }
    } else {
      // If we're dealing with a review, we need to know what deck to draw from
      final Deck deck = widget.st.readTargetDeckReview();

      // Update the text accordingly
      quizSource = deck.display;

      // Should we have the croupier shuffle the cards ?
      final bool shuffle = (ReviewOrder.random == widget.st.readReviewOrder());

      _flashcards = dealCardsFromDeck(
        widget.st,
        widget.ds,
        deck,
        shuffle: shuffle,
      );
    }

    deckButtonAddOrRemove = !isInDeck(
      _flashcards,
      targetDeckInsert,
    );
  }

  /// Jisho FTW c:
  void openJisho(List<Flashcard> cardList) async {
    // Safety check, do not attempt to open Jisho if we reached the end of the quiz
    if (currentCardIndex < cardList.length) {
      final Uri url = Uri.parse(cardList[currentCardIndex].jishoURL);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  /// Does the card currently on top of the deck represent a word that is in [deck] ?
  /// If yes, we may want to do something (turn the add to deck button red for example)
  bool isInDeck(List<Flashcard> cardList, Deck deck) {
    return (currentCardIndex < cardList.length)
        ? widget.st.isInDeck(cardList[currentCardIndex].id, deck)
        : false; // If we have already reached the end of the quiz, return false
  }

  /// This name is wayy too long, gives me VBA flashbacks ww
  void updateDeckButtonAddOrRemove(List<Flashcard> cardList, Deck deck) {
    if (currentCardIndex < cardList.length && widget.st.isInDeck(cardList[currentCardIndex].id, deck)) {
      setState(() {
        deckButtonAddOrRemove = false;
      });
    } else {
      setState(() {
        deckButtonAddOrRemove = true;
      });
    }
  }

  /// What should happen when someone presses the add to/remove from deck button.
  void handleDeckButton(List<Flashcard> cardList, Deck targetDeckInsert) {
    if (currentCardIndex < cardList.length) {
      if (widget.st.isInDeck(cardList[currentCardIndex].id, targetDeckInsert)) {
        // If the word is in selected deck, remove it
        widget.st.removeFromDeck(cardList[currentCardIndex].id, targetDeckInsert);
        setState(() {
          deckButtonAddOrRemove = true;
        });
      } else {
        // Else, add it to the deck
        widget.st.addToDeck(cardList[currentCardIndex].id, targetDeckInsert);
        setState(() {
          deckButtonAddOrRemove = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event is! KeyRepeatEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              // Don't do anything if we're in auto remove mode
              (widget.review && widget.st.readDeckAutoRemove(widget.st.readTargetDeckReview()))
                  ? null
                  : handleDeckButton(_flashcards, targetDeckInsert);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
              openJisho(_flashcards);
              return KeyEventResult.handled;
            case _:
              return KeyEventResult.ignored;
          }
        } else {
          return KeyEventResult.ignored;
        }
      },
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
                QuizTopBar(percentage: currentCardIndex / _flashcards.length, source: quizSource),
                Expanded(
                  child: Container(),
                ),
                QuizComboButton(
                  onPrimaryLeft: () => openJisho(_flashcards),
                  onPrimaryRight: () => handleDeckButton(_flashcards, targetDeckInsert),
                  onSecondaryRight: () => tray
                      .showTrayDialog(
                    context: context,
                    backgroundColor: LightTheme.base,
                    pillColor: LightTheme.darkAccent,
                    child: DeckInsertSection(st: widget.st),
                  )
                      .then((_) {
                    setState(
                      () {
                        targetDeckInsert = widget.st.readTargetDeckInsert();
                      },
                    );
                    updateDeckButtonAddOrRemove(_flashcards, targetDeckInsert);
                  }),
                  selectedDeck: targetDeckInsert,
                  rightEnabled: deckButtonAddOrRemove,
                  config: (widget.review)
                      ? (widget.st.readDeckAutoRemove(widget.st.readTargetDeckReview()))
                          ? ComboButtonConfig.onlyLeft
                          : ComboButtonConfig.standardWOnlyRemove
                      : ComboButtonConfig.standard,
                ),
                const SizedBox(height: 26.0),
              ],
            ),
          ),
          SafeArea(
            child: CardPile(
              st: widget.st,
              cardList: _flashcards,
              review: widget.review,
              onChange: (cardIndex) {
                // Setting the state because we want the stateless progress bar to update.
                setState(() {
                  currentCardIndex = cardIndex;
                  deckButtonAddOrRemove = !isInDeck(_flashcards, targetDeckInsert);
                });
              },
            ),
          ),
        ],
      )),
    );
  }
}
