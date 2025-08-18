import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";

/// Shorter to write.
typedef D = Defaults;

/// Various default values used within the app that may be further refined by anyone before compiling.
/// TODO : Improve formatting when https://github.com/Dart-Code/Dart-Code/issues/4482#issuecomment-2290119795 is released.
class Defaults {
  const Defaults._();

  /* -------------------------------------------------------------------------- */
  /*                                USER DEFAULTS                               */
  /* -------------------------------------------------------------------------- */
  /// Default values for various things used in various places for various purposes throughout the code.
  /// Also, in no particular order.

  // dart format off

  static const bool             ONBOARDING                  = true;
  static const List<String>     DECK_CONTENTS               = [];
  static const List<String>     CARD_FRONT_ELEMENTS         = ["1", "2"];
  static const List<String>     CARD_BACK_ELEMENTS          = ["4"];
  static const DSLanguage       LANGUAGE                    = DSLanguage.en;
  static const Edition          BOOK_ONE_EDITION            = Edition.second;
  static const Edition          BOOK_TWO_EDITION            = Edition.second;
  static const List<String>     SELECTED_LESSONS            = [];
  static const bool             QUIZ_DRAW_WHOLE_SELECTION   = false;
  static const int              QUIZ_WORD_COUNT             = 20;
  static const QuizWordFilter   QUIZ_WORD_FILTER            = QuizWordFilter.none;
  static const ReviewOrder      REVIEW_ORDER                = ReviewOrder.insertion;
  static const CorrectSide      CORRECT_SIDE                = CorrectSide.r;
  static const Deck             SEL_DECK_REVIEW             = Deck.one;
  static const Deck             SEL_DECK_INSERT             = Deck.one;
  static const bool             ENDLESS                     = false;
  static const bool             AUTOREMOVE                  = false;
  static const bool             PERFORMANCE_MODE            = false;
  static const bool             HIGH_CONTRAST_MODE          = false;
  static const int              WORD_SCORE                  = D.WORD_SCORE_MIN;

  // dart format on

  /* -------------------------------------------------------------------------- */
  /*                               SYSTEM DEFAULTS                              */
  /* -------------------------------------------------------------------------- */

  /// Min and max number of words allowed in a quiz.
  static const int WORD_COUNT_MIN = 10;
  static const int WORD_COUNT_MAX = 100;

  /// Each word is given a score by the app. They all start at [WORD_SCORE_MIN].
  /// When the user gets it right, the score is increased.
  /// When the user gets it wrong, it is decreased.
  ///
  /// A word that has a score of [WORD_SCORE_MAX] counts as `mastered` by the app.
  /// Any such word can be filtered out from quizzes using [QuizWordFilter.mastered].
  static const int WORD_SCORE_MAX = 3;
  static const int WORD_SCORE_MIN = 0;

  /// * [RENDER_DEPTH_END] sets the number of cards to render after (under) the one displayed on top.
  /// * [RENDER_DEPTH_START] sets the number of cards to render before (over) the one displayed on top.
  ///   Note that these should be off-screen because already discarded, and are only rendered to not vanish in the midst of a discard animation.
  static const int RENDER_DEPTH_END = 3;
  static const int RENDER_DEPTH_START = 2;

  /// Used when performance mode is turned on.
  static const int RENDER_DEPTH_END_PERF = 1;
  static const int RENDER_DEPTH_START_PERF = 1;

  /* -------------------------------------------------------------------------- */
  /*                                 UI DEFAULTS                                */
  /* -------------------------------------------------------------------------- */

  /// Dimensions used to render [AlmostFlashcard].
  /// It will not set their apparent dimensions though, as these are (sort of) [Transform.scale]'d before rendering.
  static const double CARD_RENDER_WIDTH = 205.0;
  static const double CARD_RENDER_HEIGHT = 295.0;

  /// List of colors flashcards can (randomly) take when rendered.
  static const List<Color> CARD_COLORS = [
    Color.fromARGB(255, 219, 150, 45),
    Color.fromARGB(255, 117, 50, 231),
    Color.fromARGB(255, 61, 119, 221),
    Color.fromARGB(255, 196, 53, 53),
    Color.fromARGB(255, 45, 119, 112),
    Color.fromARGB(255, 150, 41, 88),
    Color.fromARGB(255, 177, 187, 201), // « Arctic Gray With A Touch Of Blue » @colornames.org
    Color.fromARGB(255, 125, 137, 53), // « Mossy Forest Tree Stump » @colornames.org
    Color.fromARGB(255, 194, 148, 74), // « Tree Stump Rings Brown » @colornames.org
    Color.fromARGB(255, 143, 195, 88), // « Matcha » @colornames.org
    Color.fromARGB(255, 199, 174, 206),
  ];

  /// Same as above, but with only those that contrast well with white (text).
  static const List<Color> CARD_COLORS_HIGH_CONTRAST = [
    Color.fromARGB(255, 61, 119, 221),
    Color.fromARGB(255, 117, 50, 231),
    Color.fromARGB(255, 45, 119, 112),
    Color.fromARGB(255, 150, 41, 88),
    Color.fromARGB(255, 125, 137, 53), // « Mossy Forest Tree Stump » @colornames.org
  ];

  /// List of orientations (angles) flashcards can (randomly) take when rendered.
  static const List<double> CARD_ANGLES = [
    -.02,
    -.01,
    .00,
    .01,
    .02,
  ];

  /// When a card is rendered, it is slightly offset from the card pile's center.
  /// These are the bounds of the interval from which card offsets are (randomly) drawn.
  static const int CARD_OFFSET_MIN = -5;
  static const int CARD_OFFSET_MAX = 5;
}
