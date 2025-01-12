import "package:hifumi/entities/keyring.dart";

/// There are three [Deck]s available to the user.
enum Deck {
  one(
    key: K.DECK_ONE_CONTENTS,
    autoremoveKey: K.DECK_ONE_AUTOREMOVE,
    display: "一",
  ),
  two(
    key: K.DECK_TWO_CONTENTS,
    autoremoveKey: K.DECK_TWO_AUTOREMOVE,
    display: "二",
  ),
  three(
    key: K.DECK_THREE_CONTENTS,
    autoremoveKey: K.DECK_THREE_AUTOREMOVE,
    display: "三",
  );

  const Deck({
    required this.key,
    required this.autoremoveKey,
    required this.display,
  });

  /// To be used in [shared_preferences]
  final String key;

  /// To be used in [shared_preferences]
  final String autoremoveKey;

  /// Text to display in the app when mentioning the deck
  final String display;
}
