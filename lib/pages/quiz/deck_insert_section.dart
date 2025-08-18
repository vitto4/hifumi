import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/services/sp_interface.dart";
import "package:hifumi/widgets/archipelago/island_container.dart";
import "package:hifumi/pages/home/review_menu/deck_section/deck_selector.dart";

/// Same thing as [DeckSection] except it's displayed when in a quiz, to select which deck to add words to.
class DeckInsertSection extends StatelessWidget {
  final SPInterface st;

  const DeckInsertSection({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatIslandContainer(
      backgroundColor: LightTheme.base,
      borderColor: LightTheme.baseAccent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 15.0, 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Deck",
              style: TextStyle(
                color: LightTheme.textColor,
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text.rich(
              TextSpan(
                text: "Select a deck to add words to.",
                style: TextStyle(color: LightTheme.textColor),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            IslandDeckSelector(
              st: st,
              areWeDoingAQuizATM: true,
            ),
          ],
        ),
      ),
    );
  }
}
