import "dart:ui";
import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/seasoning/click_me.dart";

/// I should probably be sleeping instead of writing silly comments.
/// –anyway, why are `i` and `j` a good source of information ?

const double WORD_TILE_HEIGHT = 100.0; // Not private because used in `lesson_contents.dart`
const double _WORD_TILE_BORDER_RADIUS = 12.0;

/// Tile widget displaying word information with interactive deck assignment buttons.
class WordTile extends StatefulWidget {
  final Word word;
  final SPInterface st;

  const WordTile({
    Key? key,
    required this.word,
    required this.st,
  }) : super(key: key);

  @override
  State<WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> {
  late int _scoreState;

  @override
  void initState() {
    super.initState();
    _scoreState = widget.st.readWordScore(widget.word.id);
  }

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = switch (_scoreState) {
      0 => LightTheme.baseAccent,
      1 => LightTheme.darkAccent.withAlpha(70),
      2 => LightTheme.darkAccent.withAlpha(90),
      3 => LightTheme.darkAccent.withAlpha(130),
      _ => LightTheme.baseAccent,
    };

    final Color scoreTextColor = switch (_scoreState) {
      0 => LightTheme.textColorDimmer,
      1 => LightTheme.textColorDim.withAlpha(150),
      2 => LightTheme.textColorDim.withAlpha(200),
      3 => LightTheme.base,
      _ => LightTheme.textColorDimmer,
    };

    return ScrollConfiguration(
      // Allow scrolling by dragging around with a mouse
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: LightTheme.baseAccent, width: 1.0),
                  top: BorderSide(color: LightTheme.baseAccent, width: 1.0),
                  bottom: BorderSide(color: LightTheme.baseAccent, width: 1.0),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_WORD_TILE_BORDER_RADIUS),
                  bottomLeft: Radius.circular(_WORD_TILE_BORDER_RADIUS),
                ),
                color: LightTheme.base,
              ),
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 7.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          (widget.word.needsFurigana)
                              ? Text(
                                  widget.word.kana,
                                  style: const TextStyle(
                                    color: LightTheme.textColorDimmer,
                                    fontSize: 10.0,
                                  ),
                                )
                              : Container(height: 6.0),
                          Text(
                            widget.word.kanji,
                            style: const TextStyle(
                              color: LightTheme.textColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Meaning section
                    IntrinsicWidth(
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: LightTheme.baseAccent,
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                        ),
                        height: 23.0,
                        padding: const EdgeInsets.fromLTRB(5.0, 2.0, 5.0, 2.0),
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              widget.word.meaning[widget.st.readLanguage()]!,
                              style: const TextStyle(
                                fontSize: FontSizes.small,
                                color: LightTheme.textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Everything to the right side of the tile
          Row(
            children: <Widget>[
              IntrinsicWidth(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: LightTheme.lightAccent,
                          border: Border(
                            left: BorderSide(color: LightTheme.baseAccent),
                            top: BorderSide(color: LightTheme.baseAccent),
                          ),
                        ),
                        child: const RotatedBox(
                          quarterTurns: 1,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                              child: Text(
                                "Score",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: LightTheme.textColorDimmer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: scoreColor,
                        border: const Border(
                          bottom: BorderSide(color: LightTheme.baseAccent),
                          left: BorderSide(color: LightTheme.baseAccent),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                        child: Text(
                          _scoreState.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scoreTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: _WordTileDeckButton(
                        deck: Deck.one,
                        id: widget.word.id,
                        position: _Position.top,
                        st: widget.st,
                      ),
                    ),
                    Expanded(
                      child: _WordTileDeckButton(
                        deck: Deck.two,
                        id: widget.word.id,
                        position: _Position.middle,
                        st: widget.st,
                      ),
                    ),
                    Expanded(
                      child: _WordTileDeckButton(
                        deck: Deck.three,
                        id: widget.word.id,
                        position: _Position.bottom,
                        st: widget.st,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _Position { top, middle, bottom }

/// The strange buttons on the right side of the [WordTile].
/// (allows users to assign words to specific decks)
///
/// Yes, yes, they are buttons, I know it's not obvious ; discovering barely-advertised features is where all the fun of this app is !
class _WordTileDeckButton extends StatefulWidget {
  final WordID id;
  final Deck deck;
  final _Position position;
  final SPInterface st;

  const _WordTileDeckButton({
    Key? key,
    required this.id,
    required this.deck,
    required this.position,
    required this.st,
  }) : super(key: key);

  @override
  State<_WordTileDeckButton> createState() => _WordTileDeckButtonState();
}

class _WordTileDeckButtonState extends State<_WordTileDeckButton> {
  late bool _isHovering;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _isHovering = false;
    _enabled = widget.st.isInDeck(widget.id, widget.deck);
  }

  void _mouseEnter(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color borderColor = LightTheme.blueLight;
    const Color backgroundColor = LightTheme.blueLighter;
    const Color textColor = LightTheme.blue;

    // Matrices for color effects when the button is hovered
    const List<double> identityMatrix = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    const List<double> darkenHoverMatrix = [1 + -.02, 0, 0, 0, 0, 0, 1 + -.02, 0, 0, 0, 0, 0, 1 + -.02, 0, 0, 0, 0, 0, 1, 0];

    return ClickMePrettyPlease(
      child: MouseRegion(
        onEnter: (event) => _mouseEnter(true),
        onExit: (event) => _mouseEnter(false),
        // Since the geometry of these buttons is a bit complex, the mouse hover effect is produced using a [ColorFilter] instead of our usual [Color.darken]
        child: ColorFiltered(
          colorFilter: _isHovering ? ColorFilter.matrix(darkenHoverMatrix) : ColorFilter.matrix(identityMatrix),
          child: GestureDetector(
            onTap: () {
              if (_enabled) {
                widget.st.removeFromDeck(widget.id, widget.deck);
                setState(() {
                  _enabled = false;
                });
              } else {
                widget.st.addToDeck(widget.id, widget.deck);
                setState(() {
                  _enabled = true;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: _enabled ? backgroundColor : LightTheme.lightAccent,
                border: Border(
                  left: BorderSide(color: _enabled ? borderColor : LightTheme.baseAccent),
                  top: (widget.position == _Position.top) ? BorderSide(color: _enabled ? borderColor : LightTheme.baseAccent) : BorderSide.none,
                  right: BorderSide(color: _enabled ? borderColor : LightTheme.baseAccent),
                  bottom: (widget.position == _Position.bottom) ? BorderSide(color: _enabled ? borderColor : LightTheme.baseAccent) : BorderSide.none,
                ),
                borderRadius: BorderRadius.only(
                  topRight: (widget.position == _Position.top) ? const Radius.circular(_WORD_TILE_BORDER_RADIUS) : Radius.zero,
                  bottomRight: (widget.position == _Position.bottom) ? const Radius.circular(_WORD_TILE_BORDER_RADIUS) : Radius.zero,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
                child: Text(
                  widget.deck.display,
                  style: TextStyle(
                    color: _enabled ? textColor : LightTheme.textColorDimmer,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
