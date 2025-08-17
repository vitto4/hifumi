import "package:hifumi/abstractions/keyring.dart";

/// There are three [Deck]s available to the user.
enum Deck {
  one(
    key: K.DECK_ONE_CONTENTS,
    display: "一",
  ),
  two(
    key: K.DECK_TWO_CONTENTS,
    display: "二",
  ),
  three(
    key: K.DECK_THREE_CONTENTS,
    display: "三",
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
