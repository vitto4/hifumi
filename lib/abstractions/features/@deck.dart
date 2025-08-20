import "package:hifumi/abstractions/sp_keyring.dart";

/// There are three [Deck]s available to the user.
enum Deck {
  one(
    key: K.DECK_ONE_CONTENTS,
    display: "\u2663", // ♣︎
  ),
  two(
    key: K.DECK_TWO_CONTENTS,
    display: "\u2660", // ♠
  ),
  three(
    key: K.DECK_THREE_CONTENTS,
    display: "\u2666", // ♦︎
  );

  const Deck({
    required this.key,
    required this.display,
  });

  /// To be used in [shared_preferences]
  final String key;

  /// Text to display in the app when mentioning the deck
  final String display;
}
