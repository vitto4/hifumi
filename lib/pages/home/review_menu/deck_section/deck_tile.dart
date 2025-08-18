import 'package:flutter/material.dart';
import 'package:hifumi/abstractions/abstractions_barrel.dart';
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";

/// Tile used to select a deck. Includes a reset button that requires double-tap confirmation.
class DeckTile extends StatefulWidget {
  final Deck deck;
  final int wordCount;

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
    required this.wordCount,
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
                color: widget.isSelected ? widget.selectedTextColor : LightTheme.textColorDimmer,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(
                widget.wordCount.toString(),
                style: TextStyle(
                  fontSize: FontSizes.base,
                  fontWeight: FontWeight.bold,
                  color: widget.isSelected ? widget.selectedTextColor : LightTheme.textColorDimmer,
                ),
              ),
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
                    "CLEAR",
                    style: TextStyle(
                      color: widget.isSelected ? LightTheme.blue : LightTheme.red,
                      fontWeight: FontWeight.bold,
                      fontSize: FontSizes.smallNitpick,
                      letterSpacing: .4,
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
              ),
          ],
        ),
      ),
    );
  }
}
