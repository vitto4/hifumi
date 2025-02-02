/// Shorter to write.
typedef K = Keyring;

/// Keys for [shared_preferences].
class Keyring {
  const Keyring._();

  static const String SCORE_PREFIX = "score.";

  static const String ONBOARDING = "displayOnboarding";
  static const String DECK_ONE_CONTENTS = "deckOneContents";
  static const String DECK_TWO_CONTENTS = "deckTwoContents";
  static const String DECK_THREE_CONTENTS = "deckThreeContents";
  static const String CARD_FRONT_ELEMENTS = "cardFrontElements";
  static const String CARD_BACK_ELEMENTS = "cardBackElements";
  static const String LANGUAGE = "language";
  static const String BOOK_ONE_EDITION = "bookOneEdition";
  static const String BOOK_TWO_EDITION = "bookTwoEdition";
  static const String SELECTED_LESSONS = "selectedLessons";
  static const String QUIZ_DRAW_WHOLE_SELECTION = "quizDrawWholeSelection";
  static const String QUIZ_WORD_COUNT = "quizWordCount";
  static const String QUIZ_WORD_FILTER = "quizWordFilter";
  static const String REVIEW_ORDER = "reviewOrder";
  static const String CORRECT_SIDE = "correctSide";
  static const String TARGET_DECK_REVIEW = "targetDeckReview";
  static const String TARGET_DECK_INSERT = "targetDeckInsert";
  static const String ENDLESS = "endlessMode";
  static const String AUTOREMOVE = "endlessAutoremove";
  static const String PERFORMANCE_MODE = "performanceMode";
  static const String HIGH_CONTRAST_MODE = "highContrastMode";
}
