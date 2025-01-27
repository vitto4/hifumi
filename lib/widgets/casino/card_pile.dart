import "dart:math";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/casino/almost_flashcard.dart";
import "package:hifumi/widgets/seasoning/quiz_end_card.dart";
import "package:hifumi/widgets/seasoning/snack_toast.dart";
import "package:hifumi/widgets/swipeable.dart";
import "package:assorted_layout_widgets/assorted_layout_widgets.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:circular_buffer/circular_buffer.dart";

/// (beware, not many easter eggs in here, even your favorite narrator runs out eventually)

extension Window<T> on List<T> {
  /// Returns a sublist of elements around [index] with specified spans on both sides.
  /// Ensures the returned window stays within list bounds.
  ///
  /// Example : [1, 2, 3, 4, 5].window(2, 1, 1) --> [2, 3, 4]
  List<T> window(int index, int spanLeft, int spanRight) {
    int start = max(0, index - spanLeft);
    int end = min(this.length, index + spanRight + 1);
    return this.sublist(start, end);
  }
}

/// Returns a random subset of [set_] with [length] elements.
///
/// If [length] is greater than the length of [set_], returns the whole set and additional (random) elements.
/// (in which case repetitions are allowed)
List<T> randomSubset<T>(Set<T> set_, int length) {
  Random random = Random();
  List<T> result = set_.toList()..shuffle(random);

  return result
      .take(length)
      .followedBy(List.generate(
        max(0, length - set_.length),
        (_) => set_.elementAt(random.nextInt(set_.length)),
      ))
      .toList();
}

/// Pile of flashcards displayed when taking a quiz.
/// When one is swiped away, it is not removed from the pile, it just remains offscreen.
/// Except not really, it will only stay as long as [D.RENDER_DEPTH_START] allows for it.
class CardPile extends StatefulWidget {
  final StorageInterface st;

  /// The actual list of [Flashcard]s to inclue in the pile.
  final List<Flashcard> cardList;

  /// Called when the card on top of the pile changes.
  /// Is called with the new [Flashcard] and the new progress for the progress bar to display.
  /// The first argument may also be null when all cards have been swiped away.
  final Function(Flashcard?, double) onChange;

  /// Are we doing a review ?
  /// (needed for [QuizEndCard])
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

  /// Only initialized when in endless mode.
  late final bool autoRemove;

  /// Used to dimension [_cardBuffer] correctly
  late final int renderDepthStart;
  late final int renderDepthEnd;

  /// Carousel that spins round and round always in sync with [_cardBuffer].
  /// Used to uniquely identify each card in the [_cardBuffer], even if there are duplicates.
  /// (needed for [GlobalValueKey] shenanigans)
  late CircularBuffer<int> _syncedBuffer;

  /// Contains the cards currently (actively) rendered by the [CardPile].
  /// Constantly evolves to reflect [widget.cardList] (ordered in normal mode, random in endless mode).
  late final CircularBuffer<Flashcard?> _cardBuffer;

  /// Use exclusively in endless mode, to keep track of which cards are available to display on the fly as the user progresses through the review.
  late Set<Flashcard> _cardSet;

  /// Used both as a way to check if we're in endless mode (`endlessDeck is Deck`), and when it's the case, to know what deck to remove cards from.
  late final Deck? endlessDeck;

  /// Keep track of how many cards have been discarded.
  /// Mostly useful to navigate [widget.cardList] when in normal mode.
  int masterListCurrentIndex = 0;

  /// See [reset].
  int resetCount = 0;

  /// See [_topCard].
  bool thresholdCrossed = false;

  /// Variable used to tell the [CardMask] what to display (correct or incorrect symbol) when a [Flashcard] is dragged past the discard threshold.
  /// `true` when the threshold on the [correctSide] is crossed.
  bool maskCorrect = false;

  @override
  void initState() {
    super.initState();
    correctSide = widget.st.readCorrectSide();
    renderDepthStart = widget.st.readPerformanceMode() ? D.RENDER_DEPTH_START_PERF : D.RENDER_DEPTH_START;
    renderDepthEnd = widget.st.readPerformanceMode() ? D.RENDER_DEPTH_END_PERF : D.RENDER_DEPTH_END;

    /// Assign [endlessDeck] if this is a review in endless mode. Else make it null.
    /// This is because when endless mode is enabled, we may have to remove cards from said deck.
    endlessDeck = (widget.review && widget.st.readDeckAutoRemove(widget.st.readTargetDeckReview())) ? widget.st.readTargetDeckReview() : null;

    // If we are in endless mode
    if (endlessDeck is Deck) {
      _cardSet = widget.cardList.toSet();
      // Set the fixed length of the buffer, and populate it with the first cards to be displayed
      _cardBuffer =
          CircularBuffer<Flashcard?>.of(randomSubset(_cardSet, renderDepthEnd + 1).cast<Flashcard?>(), renderDepthStart + renderDepthEnd + 1);
      // Check if auto-remove mode is enabled
      autoRemove = widget.st.readDeckAutoRemove(endlessDeck!);
    } else {
      // Set the fixed length of the buffer, and populate it with the first cards to be displayed
      _cardBuffer = CircularBuffer<Flashcard?>.of(widget.cardList.window(0, renderDepthStart, renderDepthEnd), renderDepthStart + renderDepthEnd + 1);
    }

    // Also generate the [_syncedBuffer], while keeping it of the same length as [_cardBuffer]
    _syncedBuffer = CircularBuffer<int>.of(List.generate(renderDepthEnd + 1, (i) => i), renderDepthStart + renderDepthEnd + 1);

    // Ping the quiz page with the [currentCard] so it knows what's displayed
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChange.call(currentCard, currentProgress));
  }

  /// Index of the card displayed on top of the pile.
  /// It is constant, except when the [_cardBuffer] has yet to be filled.
  int get topCardIndex => (_cardBuffer.isFilled) ? renderDepthStart : _cardBuffer.length - renderDepthEnd - 1;

  /// In normal mode, the window of [widget.cardList] containing all cards to be rendered at the moment.
  List<Flashcard> get currentWindow => widget.cardList.window(masterListCurrentIndex, renderDepthStart, renderDepthEnd);

  /// In normal mode, peak one step to the right of the [currentWindow].
  /// Is used to [generateNextCard] for the [_cardBuffer].
  /// Will return [null] if the window steps outside of the master list.
  Flashcard? get windowPeak => (masterListCurrentIndex < widget.cardList.length - renderDepthEnd - 1)
      ? widget.cardList.window(masterListCurrentIndex, renderDepthStart, renderDepthEnd + 1).last
      : null;

  /// [Flashcard] currently displayed on top of the pile.
  Flashcard? get currentCard => _cardBuffer[topCardIndex];

  /// For [widget.onChange] callback, reflects what the progress bar should display.
  double get currentProgress =>
      (endlessDeck is! Deck) ? masterListCurrentIndex / widget.cardList.length : 1 - _cardSet.length / widget.cardList.length;

  /// In endless mode, corresponds to the three [_nextCards].
  /// Used when [generateNextCard], to try and not have the same card back to back in the pile.
  Set<Flashcard?> get currentExclusionSet => _cardBuffer.sublist(topCardIndex + 1, topCardIndex + 1 + renderDepthEnd).toSet();

  /// In endless mode, the allowed subset to draw cards from when [generateNextCard].
  /// See [currentExclusionSet].
  Set<Flashcard> get currentAllowedSubset => _cardSet.difference(currentExclusionSet);

  /// Clears matching cards from the buffer and regenerates new ones from a given starting index.
  /// Effectively shifts non-matching cards to the beginning and fills the remaining positions with randomly selected cards.
  void clearAndRegenerate(CircularBuffer<Flashcard?> buffer, Flashcard? toBeCleared, int startIndex) {
    int totalLength = buffer.length - startIndex;

    // List from [startIndex] to end of buffer
    List<Flashcard?> result = List<Flashcard?>.from(buffer.sublist(startIndex, buffer.length));
    int writeIndex = 0;

    // Shift matches to the end of the list
    for (int readIndex = 0; readIndex < totalLength; readIndex++) {
      if (result[readIndex] != toBeCleared) {
        result[writeIndex] = result[readIndex];
        writeIndex++;
      }
    }

    // Fill matched positions with new cards
    for (int i = writeIndex; i < totalLength; i++) {
      Set<Flashcard> workingSet = (currentAllowedSubset.isEmpty) ? _cardSet : currentAllowedSubset;
      result[i] = (workingSet.isNotEmpty) ? workingSet.elementAt(Random().nextInt(workingSet.length)) : null;
    }

    // Update buffer accordingly
    buffer.setRange(startIndex, startIndex + totalLength, result);
  }

  /// Generates the next card and inserts it into the [_cardBuffer].
  /// * In endless mode, the card is drawn from either [currentAllowedSubset] or [_cardSet]
  /// * In normal mode, the card is obtained from [widget.cardList] using [windowPeak]
  void generateNextCard() {
    if (endlessDeck is Deck) {
      Set<Flashcard> workingSet = (currentAllowedSubset.isEmpty) ? _cardSet : currentAllowedSubset;
      Flashcard? card = (workingSet.isNotEmpty) ? workingSet.elementAt(Random().nextInt(workingSet.length)) : null;
      _cardBuffer.add(card);
    } else {
      _cardBuffer.add(windowPeak);
    }

    /// Keep the buffer in sync. We'll cheat a little bit and use [masterListCurrentIndex] to make sure we add the right [int].
    _syncedBuffer.add((masterListCurrentIndex + renderDepthEnd + 1) % (renderDepthStart + renderDepthEnd + 1));
  }

  /// I don't think the way I implemented it is standard practice, but the gist is that I use a [ValueKey] unique to each element
  /// of the pile (i.e. cards), and since it's a single-valued function that depends on [resetCount], it will force flutter to
  /// build new widgets with new states each time [resetCount] changes.
  ///
  /// ! Shall not be used when in endless mode.
  void reset() {
    // Remove all cards currently being displayed
    _cardBuffer.clear();

    // Reset the position at which to read the master list ([widget.cardList])
    masterListCurrentIndex = 0;

    // Since we know we're in normal mode, add the cards from [currentWindow] to the buffer
    for (Flashcard card in currentWindow) {
      _cardBuffer.add(card);
    }

    // Also reset the sync buffer
    _syncedBuffer = CircularBuffer<int>.of(List.generate(currentWindow.length, (i) => i), renderDepthStart + renderDepthEnd + 1);

    // Have all of these changes take effect
    setState(() {
      resetCount += 1;
    });

    // And don't forget to report back to the quiz page
    widget.onChange.call(currentCard, currentProgress);
  }

  /// Discard the flashcard, for a correct answer.
  void discardCorrect() {
    if (endlessDeck is Deck) {
      // If we're in endless mode, remove the card from [_cardSet]
      _cardSet.remove(currentCard);
      // And remove all its (potential) copies currently rendered as [_nextCards]
      clearAndRegenerate(_cardBuffer, currentCard, topCardIndex + 1);
    } else {
      // If we're in normal mode, nothing more to do than update the card's score
      widget.st.writeWordScore(currentCard!.id, true);
    }

    // Insert the next card into the buffer
    generateNextCard();

    setState(() {
      masterListCurrentIndex += 1;
      maskCorrect = true;
      thresholdCrossed = false;
    });
    widget.onChange.call(currentCard, currentProgress);
  }

  /// Discard the flashcard, for an incorrect answer.
  void discardIncorrect() {
    if (endlessDeck is Deck) {
      // Nothing is done as of right now.
      // I'll leave it like this for ̶f̶u̶t̶u̶r̶e̶ ̶u̶s̶e forever, hopefully it's optimized away by the compiler.
    } else {
      widget.st.writeWordScore(currentCard!.id, false);
    }

    // Insert the next card into the buffer
    generateNextCard();

    setState(() {
      masterListCurrentIndex += 1;
      maskCorrect = false;
      thresholdCrossed = false;
    });
    widget.onChange.call(currentCard, currentProgress);
  }

  /// Exists only to make the code more concise.
  void discardHandler(Side side) {
    (correctSide == CorrectSide.r)
        ? (side == Side.right)
            ? discardCorrect()
            : discardIncorrect()
        : (side == Side.left)
            ? discardCorrect()
            : discardIncorrect();
  }

  /// Could be named `onThresholdCorrectCrossed`.
  void thresholdCorrect() {
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        maskCorrect = true;
        thresholdCrossed = true;
      });
    });
  }

  /// Could be named `onThresholdIncorrectCrossed`.
  void thresholdIncorrect() {
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        maskCorrect = false;
        thresholdCrossed = true;
      });
    });
  }

  void thresholdBackInside() {
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thresholdCrossed = false;
      });
    });
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
  Swipeable _topCard(int cardIndex, bool onTop, Alignment pileAlignment) {
    final Flashcard card = _cardBuffer[cardIndex]!;

    /// See [reset].
    /// Also, this is required since we want to be able to identify each [Flashcard], or we may fail to rebuild them while preserving their state.
    /// The [_syncedBuffer] makes sure that the key is unique even if a [card] is present twice in the pile.
    final GlobalValueKey<SwipeableState> currentKey = GlobalValueKey((resetCount, card, _syncedBuffer[cardIndex]));

    return Swipeable(
      key: currentKey,
      defaultAlignment: pileAlignment,
      onLeftSwipeRelease: () => discardHandler.call(Side.left),
      onRightSwipeRelease: () => discardHandler.call(Side.right),
      onLeftSwipeKeyboard: () => discardHandler.call(Side.left),
      onRightSwipeKeyboard: () => discardHandler.call(Side.right),
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
                child: (thresholdCrossed || !onTop)
                    ? CardMask(
                        correct: maskCorrect,
                        correctWidget: (endlessDeck is Deck && autoRemove)
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
                        incorrectWidget: (endlessDeck is Deck && autoRemove)
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
  List<Widget> _buildPile(Alignment pileAlignment) {
    List<Widget> output = [];

    for (int i = 0; i < _cardBuffer.length; i++) {
      // If the card is [null], do not attempt to build it
      if (_cardBuffer[i] is Flashcard) {
        if (i < topCardIndex) {
          output.add(_topCard(i, false, pileAlignment));
        } else if (i == topCardIndex) {
          output.add(_topCard(i, true, pileAlignment));
        } else {
          output.add(_nextCards(_cardBuffer[i]!, pileAlignment));
        }
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
              displaySecondButton: !widget.review || (endlessDeck is Deck),
              onSecondButton: (endlessDeck is Deck)
                  ? () {
                      widget.st.clearDeck(endlessDeck!);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackToast.bar(text: "Deck ${endlessDeck!.display} reset successfully", confused: false),
                      );
                    }
                  : reset,
              // Clear deck button is available only in endless mode.
              secondButtonType: (endlessDeck is Deck) ? SecondButtonType.clearDeck : SecondButtonType.restart,
            ),
          ),
        ),
        ..._buildPile(cardPileAlignment),
      ],
    );
  }
}
