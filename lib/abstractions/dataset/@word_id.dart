import "package:hifumi/abstractions/sp_keyring.dart";

/// Each word has a unique [WordID], being a list of two integers. E.g. `[2, 10]`.
typedef WordID = List<int>;

/// See also [LessonNumberToolkit], you'll get a better explanation there.
extension WordIDToolkit on WordID {
  /// Used as value in [shared_preferences], to keep track of what words are in which deck.
  String get toCode => this.join(",");

  static WordID fromCode(String code) => code.split(",").map((String s) => int.parse(s)).toList();

  /// Used as a key in [shared_preferences], to store the score for a word.
  String get toKey => K.SCORE_PREFIX + this.toCode;
}
