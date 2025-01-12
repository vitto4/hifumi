/// Keys for the YAML word dataset, should increase code readability in [ds_interface.dart].
class DSKeyring {
  const DSKeyring._();

  static const String LANGUAGES = "languages";
  static const String LESSONS = "lessons";
  static const String WORD_ID = "id";
  static const String WORD_EDITION = "edition";
  static const String WORD_KANJI = "kanji";
  static const String WORD_KANA = "kana";
  static const String WORD_ROMAJI = "romaji";
  static const String WORD_MEANING = "meaning";
  static const String LESSON_NUMBER = "id";
  static const String LESSON_KEY = "key";

  static const int ID_INDEX_LESSON = 0;
  static const int ID_INDEX_WORD = 1;
}
