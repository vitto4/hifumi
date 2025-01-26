import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/casino/almost_flashcard.dart";
import "package:hifumi/widgets/seasoning/quiz_end_card.dart";
import "package:hifumi/widgets/swipeable.dart";
import "package:assorted_layout_widgets/assorted_layout_widgets.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";

/// (beware, not many easter eggs in here, even your favorite narrator runs out eventually)

/// Pile of flashcards displayed when taking a quiz.
/// When one is swiped away, it is not removed from the pile, it just remains offscreen.
/// Except not really, it will only stay as long as [D.RENDER_DEPTH_START] allows for it.
class CardPile extends StatefulWidget {
  final StorageInterface st;

  /// The actual list of [Flashcard] to inclue in the pile.
  final List<Flashcard> cardList;

  /// Called when the card on top of the pile changes.
  /// Is called with the new [Flashcard] and the new progress for the progress bar to display.
  /// The first argument may also be null when all cards have been swiped away.
  final Function(Flashcard?, double) onChange;

  /// Are we doing a review ?
  /// We need to know this because it influences on what happens when a card is discarded.
  final bool review;

  const CardPile({
    Key? key,
    required this.st,
    required this.cardList,
    required this.onChange,
    required this.review,
  }) : super(key: key);

  @override
  State<CardPile> createState() => _CardPileState();
}

class _CardPileState extends State<CardPile> {
  late final CorrectSide correctSide;
  late final Deck? deck;
  late List<Flashcard> _cardList;

  late List<Swipeable> pile;

  int currentCardIndex = 0;
  int resetCount = 0;
  bool crossed = false;

  /// Variable used to tell the [CardMask] what to display (correct or incorrect symbol) when a [Flashcard] is dragged past the discard threshold.
  /// `true` when the threshold on the [correctSide] is crossed.
  bool maskCorrect = false;

  @override
  void initState() {
    super.initState();
    correctSide = widget.st.readCorrectSide();
    _cardList = widget.cardList;

    /// Assign [deck] if this is a review with auto-remove enabled. Else make it null.
    /// This is because if auto-remove is enabled, we may have to remove cards from said deck.
    deck = (widget.review && widget.st.readDeckAutoRemove(widget.st.readTargetDeckReview())) ? widget.st.readTargetDeckReview() : null;
  }

  /// I don't think the way I implemented it is standard practice, but the gist is that I use a [ValueKey] unique to each element
  /// of the pile (i.e. cards), and since it's a single-valued function that depends on [resetCount], it will force flutter to
  /// build new widgets with new states each time [resetCount] changes.
  void reset() {
    setState(() {
      resetCount += 1;
    });
    currentCardIndex = 0;
    widget.onChange.call(_cardList[currentCardIndex], currentCardIndex / _cardList.length);
  }

  /// Discard the flashcard, for a correct answer.
  void discardCorrect(Flashcard card) {
    if (deck is Deck) {
      widget.st.removeFromDeck(_cardList[currentCardIndex].id, deck!);
    } else {
      widget.st.writeWordScore(card.id, true);
    }
    setState(() {
      currentCardIndex += 1;
      maskCorrect = true;
      crossed = false;
    });
    widget.onChange.call(_cardList.elementAtOrNull(currentCardIndex), currentCardIndex / _cardList.length);
  }

  /// Discard the flashcard, for an incorrect answer.
  void discardIncorrect(Flashcard card) {
    if (deck is Deck) {
      // Nothing is done as of right now.
      // I'll leave it like this for ̶f̶u̶t̶u̶r̶e̶ ̶u̶s̶e forever, hopefully it's optimized away by the compiler.
    } else {
      widget.st.writeWordScore(card.id, false);
    }
    setState(() {
      currentCardIndex += 1;
      maskCorrect = false;
      crossed = false;
    });
    widget.onChange.call(_cardList.elementAtOrNull(currentCardIndex), currentCardIndex / _cardList.length);
  }

  /// Could be named `onThresholdCorrectCrossed`.
  void thresholdCorrect() {
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        maskCorrect = true;
        crossed = true;
      });
    });
  }

  /// Could be named `onThresholdIncorrectCrossed`.
  void thresholdIncorrect() {
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        maskCorrect = false;
        crossed = true;
      });
    });
  }

  void thresholdBackInside() {
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        crossed = false;
      });
    });
  }

  /// Exists only to make the code more concise.
  void discardHandler(Flashcard card, Side side) {
    (correctSide == CorrectSide.r)
        ? (side == Side.right)
            ? discardCorrect(card)
            : discardIncorrect(card)
        : (side == Side.left)
            ? discardCorrect(card)
            : discardIncorrect(card);
  }

  /// Exists only to make the code more concise.
  void thresholdHandler(Side side) {
    (correctSide == CorrectSide.r)
        ? (side == Side.right)
            ? thresholdCorrect()
            : thresholdIncorrect()
        : (side == Side.left)
            ? thresholdCorrect()
            : thresholdIncorrect();
  }

  /// Card that is currently displayed on top of the pile. Unlike the other ones, it is [Swipeable].
  /// Also used to build cards that have been discarded but are still within [D.RENDER_DEPTH_START]. (For animation smoothness purposes)
  Swipeable _topCard(Flashcard card, bool onTop, Alignment pileAlignment) {
    /// See [reset].
    final GlobalValueKey<SwipeableState> currentKey = GlobalValueKey((resetCount, card));

    return Swipeable(
      key: currentKey,
      defaultAlignment: pileAlignment,
      onLeftSwipeRelease: () => discardHandler.call(card, Side.left),
      onRightSwipeRelease: () => discardHandler.call(card, Side.right),
      onLeftSwipeKeyboard: () => discardHandler.call(card, Side.left),
      onRightSwipeKeyboard: () => discardHandler.call(card, Side.right),
      onLeftThresholdCrossed: () => thresholdHandler.call(Side.left),
      onRightThresholdCrossed: () => thresholdHandler.call(Side.right),
      onThresholdBackInside: () => thresholdBackInside.call(),
      child: Transform.translate(
        offset: card.positionOffset,
        child: Transform.rotate(
          angle: card.angle,
          child: Stack(
            children: <Widget>[
              AlmostFlashcard(
                color: card.color,
                frontContent: card.frontContent,
                backContent: card.backContent,
                lessonNumber: card.id[0],
                onTop: onTop,
              ),
              IgnorePointer(
                // Need the OR operator to keep the mask on when the discard animation is playing
                child: (crossed || !onTop)
                    ? CardMask(
                        correct: maskCorrect,
                        correctWidget: (deck is Deck)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.layers_clear_rounded,
                                    color: LightTheme.textColorSuperExtraLight,
                                    size: 85.0,
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    "(remove from the deck)",
                                    style: TextStyle(
                                      fontSize: FontSizes.small,
                                      color: LightTheme.base,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                        incorrectWidget: (deck is Deck)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  FaIcon(
                                    FontAwesomeIcons.shieldHalved,
                                    color: LightTheme.textColorSuperExtraLight,
                                    size: 75.0,
                                  ),
                                  SizedBox(height: 15.0),
                                  Text(
                                    "(keep in the deck)",
                                    style: TextStyle(
                                      fontSize: FontSizes.small,
                                      color: LightTheme.base,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the cards to be displayed in the pile, under the top card.
  Align _nextCards(Flashcard card, Alignment pileAlignment) {
    return Align(
      alignment: pileAlignment,
      child: Transform.translate(
        offset: card.positionOffset,
        child: Transform.rotate(
          angle: card.angle,
          child: PleaseScaleMe(
            child: AlmostFlashcardButOnlyHalfOfIt(
              color: card.color,
              lessonNumber: card.id[0],
              content: card.frontContent,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the same pile each time, but make the card on top (being the one at [currentCardIndex]) a [Swipeable] instead of a just an [AlmostFlashcard].
  /// Note : Cards that are already discarded are also rebuilt as [Swipeable], to keep the alignment and keep playing the discarding animation even while the pile is being rebuilt.
  ///        However, they stop being rebuilt when they fall out of [D.RENDER_DEPTH_START].
  List<Widget> _buildPile(List<Flashcard> cards, Alignment pileAlignment) {
    List<Widget> output = [];

    // Convert render depths to indices, and handle edge-cases
    final int start = widget.st.readPerformanceMode() ? D.RENDER_DEPTH_START_PERF : D.RENDER_DEPTH_START;
    final int end = widget.st.readPerformanceMode() ? D.RENDER_DEPTH_END_PERF : D.RENDER_DEPTH_END;
    final int renderDistanceStart = (currentCardIndex - start > 0) ? currentCardIndex - start : 0;
    final int renderDistanceEnd = (currentCardIndex + end <= cards.length - 1) ? currentCardIndex + end : cards.length - 1;

    for (int i = renderDistanceStart; i <= renderDistanceEnd; i++) {
      if (i < currentCardIndex) {
        output.add(_topCard(cards[i], false, pileAlignment));
      } else if (i == currentCardIndex) {
        output.add(_topCard(cards[i], true, pileAlignment));
      } else {
        output.add(_nextCards(cards[i], pileAlignment));
      }
    }

    return output.reversed.toList(); // Reversing to match the direction of the pile
  }

  @override
  Widget build(BuildContext context) {
    final cardPileAlignment = getOrientation(context) == ScreenOrientation.landscape ? const Alignment(.0, -.15) : const Alignment(.0, -.1);

    return Stack(
      children: [
        Align(
          alignment: cardPileAlignment,
          child: PleaseScaleMe(
            child: QuizEndCard(
              displayRestartButton: deck is! Deck,
              restartFunction: reset,
            ),
          ),
        ),
        ..._buildPile(_cardList, cardPileAlignment),
      ],
    );
  }
}
