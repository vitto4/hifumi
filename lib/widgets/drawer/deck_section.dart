import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/storage_interface.dart";
import "package:hifumi/widgets/archipelago/island_container.dart";
import "package:hifumi/widgets/drawer/deck_selector.dart";

/// Quick settings section to select what deck one wants to use for the next review.
class DeckSection extends StatelessWidget {
  final StorageInterface st;

  const DeckSection({
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
                  text: "Deck to use for the review. Tap the ",
                  style: TextStyle(
                    color: LightTheme.textColor,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: "reset button",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " twice to clear all words from the corresponding deck."),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              IslandDeckSelector(
                st: st,
                areWeDoingAQuizATM: false,
              )
            ],
          )),
    );
  }
}
