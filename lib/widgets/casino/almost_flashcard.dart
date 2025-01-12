import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/responsive_layout_niceties.dart";
import "package:hifumi/widgets/casino/card_element.dart";
import "package:hifumi/widgets/polyjuice.dart";

/// [AlmostFlashcard], but not quite. Can be flipped over, but not swiped around just yet.
class AlmostFlashcard extends StatefulWidget {
  /// Indicate on the card which lesson the word is from.
  final LessonNumber lessonNumber;

  /// Always using the same color would be a little boring, wouldn't it ?
  final Color color;

  /// [onTop] of the pile ? Those who aren't will not flip when tapped, and won't request keyboard focus.
  final bool onTop;

  final List<CardElement> frontContent;
  final List<CardElement> backContent;

  const AlmostFlashcard({
    Key? key,
    required this.lessonNumber,
    required this.color,
    required this.onTop,
    required this.frontContent,
    required this.backContent,
  }) : super(key: key);

  @override
  State<AlmostFlashcard> createState() => _AlmostFlashcardState();
}

class _AlmostFlashcardState extends State<AlmostFlashcard> {
  late FocusNode _node;

  /// Used to call [FlipCardState.toggleCard].
  final GlobalKey<PolyjuiceState> _polyjuiceKey = GlobalKey<PolyjuiceState>();

  /// Don't be gluttonous. No need to request focus multiple times.
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node = FocusNode(debugLabel: "AlmostFlashcard");
  }

  @override
  Widget build(BuildContext context) {
    // If the card is on top of the stack, request global focus
    if (widget.onTop && !_focused) {
      FocusScope.of(context).requestFocus(_node);
      _focused = true;
    }

    return Focus(
      focusNode: _node,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event is! KeyRepeatEvent && event.logicalKey == LogicalKeyboardKey.space) {
          // If the user pressed space, flip the card
          _polyjuiceKey.currentState?.flip();
          return KeyEventResult.handled;
        } else {
          // If the event isn't the one we're listening for, propagate it up the focus tree
          return KeyEventResult.ignored;
        }
      },
      child: PleaseScaleMe(
        child: Polyjuice(
          key: _polyjuiceKey,
          front: AlmostFlashcardButOnlyHalfOfIt(
            color: widget.color,
            lessonNumber: widget.lessonNumber,
            content: widget.frontContent,
          ),
          back: AlmostFlashcardButOnlyHalfOfIt(
            color: widget.color,
            lessonNumber: widget.lessonNumber,
            content: widget.backContent,
          ),
        ),
      ),
    );
  }
}

/// Outrageously unprofessional name >:(
/// [AlmostFlashcardButOnlyHalfOfIt] is the inner scaffolding of [AlmostFlashcard].
class AlmostFlashcardButOnlyHalfOfIt extends StatelessWidget {
  final LessonNumber lessonNumber;
  final Color color;
  final List<CardElement> content;

  const AlmostFlashcardButOnlyHalfOfIt({
    Key? key,
    required this.lessonNumber,
    required this.color,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: D.CARD_RENDER_HEIGHT,
      width: D.CARD_RENDER_WIDTH,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.symmetric(horizontal: .1 * D.CARD_RENDER_WIDTH, vertical: .1 * D.CARD_RENDER_HEIGHT),
      decoration: BoxDecoration(
        color: this.color,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 7.0,
          color: Colors.transparent.withValues(alpha: .3),
        ),
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Align(
            alignment: const Alignment(1.27, 1.38),
            child: Text(
              // For the sake of consistency, we want `<LessonNumber> 1` to turn into `"01"` but keep `<LessonNumber> 11` as `"11"`.
              (this.lessonNumber.toString().length == 2) ? this.lessonNumber.toString() : "0${this.lessonNumber}",
              style: TextStyle(
                fontSize: 30,
                color: Colors.transparent.withValues(alpha: .15),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          /// hmpffff
          ///
          /// It took me an hour to figure this out ,_,
          ///
          /// Here's the story because why not :
          /// 1. I want the contents of the card to shrink if they exceed the height of the card.
          /// 2. I decide to use a `FittedBox`.
          /// 3. What do you know, the `Column` gets all shy and shrinks down. I don't want that.
          /// 4. I can't wrap it in a nice fluffy `Expanded` to reassure it, because, fancy that, constraints stop cascading down when they meet the `FittedBox`.
          ///    It definitely doesn't blend in, one could even say it doesn't ... fit
          /// 5. Fine, I'll handle the constraints myself. Gimme a `LayoutBuilder`, capture the constraints upstream and place them back downstream.
          /// 6. Yeah, about that, it actually defeats the purpose of a `FittedBox`, the `Column` will overflow `maxHeight` just like before.
          /// 7. Set no `maxHeight`, and set `minHeight` to what `maxHeight` should've been.
          /// 8. Profit.
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // Little hack to prevent `CardElement`s from touching and enable `FittedBox` to scale them down anyway.
                    children: this.content.isEmpty
                        ? [Container()]
                        : content
                            .map<Widget>(
                              (e) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: e,
                              ),
                            )
                            .toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Mask to be used with [AlmostFlashcard]. (should be stacked on top of it)
/// Provides feedback to the user when the discard threshold is crossed.
///
/// Yapping :
///   Could have been stateless, but to prevent the value of [correct] from changing when animating out at the same time as other cards ;
///   I use the state as a kind of deep copy of [correct], only capturing its contents upon first build (i.e. in `initState`).
///   ([correct] is provided by [CardPile] but exists only in one copy despite being potentially used in multiple cards)
class CardMask extends StatefulWidget {
  /// Did we cross the [correct] threshold ? If yes, display [correctWidget].
  final bool correct;

  /// The [Widget] used for correct answers will be different if auto-remove is enabled.
  final Widget? correctWidget;

  /// The [Widget] used for incorrect answers will be different if auto-remove is enabled.
  final Widget? incorrectWidget;

  const CardMask({
    Key? key,
    required this.correct,
    this.correctWidget,
    this.incorrectWidget,
  }) : super(key: key);

  @override
  State<CardMask> createState() => _CardMaskState();
}

class _CardMaskState extends State<CardMask> {
  late final Widget correctWidget;
  late final Widget incorrectWidget;

  // See `Yapping`
  late final bool _correct;

  @override
  void initState() {
    super.initState();
    correctWidget = widget.correctWidget ??
        const Icon(
          Icons.check,
          color: LightTheme.textColorSuperExtraLight,
          size: 85.0,
        );
    incorrectWidget = widget.incorrectWidget ??
        const Icon(
          Icons.close,
          color: LightTheme.textColorSuperExtraLight,
          size: 85.0,
        );
    _correct = widget.correct;
  }

  @override
  Widget build(BuildContext context) {
    final Widget display = (_correct) ? correctWidget : incorrectWidget;

    return PleaseScaleMe(
      child: Container(
        height: D.CARD_RENDER_HEIGHT,
        width: D.CARD_RENDER_WIDTH,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .65),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(child: display),
      ),
    );
  }
}
