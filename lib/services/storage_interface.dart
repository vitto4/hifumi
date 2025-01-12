import "dart:convert";
import "dart:math";
import "dart:io";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/ds_interface.dart";
import "package:hifumi/widgets/archipelago/island_text_checkbox.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:file_picker/file_picker.dart";
import "package:file_saver/file_saver.dart";

/// Represents the current state of user-set preferences ([shared_preferences]) for the settings menu (almost exclusively used there).
class UserPrefs {
  // Card front
  bool cardFrontKanji;
  bool cardFrontKana;
  bool cardFrontRomaji;
  bool cardFrontMeaning;

  // Card back
  bool cardBackKanji;
  bool cardBackKana;
  bool cardBackRomaji;
  bool cardBackMeaning;

  // Misc
  DSLanguage language;
  Edition editionBookOne;
  Edition editionBookTwo;
  CorrectSide correctSide;
  bool performance;
  bool contrast;

  UserPrefs({
    required this.cardFrontKanji,
    required this.cardFrontKana,
    required this.cardFrontRomaji,
    required this.cardFrontMeaning,
    required this.cardBackKanji,
    required this.cardBackKana,
    required this.cardBackRomaji,
    required this.cardBackMeaning,
    required this.language,
    required this.editionBookOne,
    required this.editionBookTwo,
    required this.correctSide,
    required this.performance,
    required this.contrast,
  });
}

/// Interfaces with [shared_preferences], used (all over the app) to store and retrieve user data.
class StorageInterface {
  /* ---------------------------------- Setup --------------------------------- */
  late final SharedPreferences _sp;

  StorageInterface();

  Future<void> init() async {
    this._sp = await SharedPreferences.getInstance();
    print("[Loading] Shared preferences initialized !");
  }

  /* ---------------------------------- Utils --------------------------------- */

  /// Reads currently registered preferences, and loads them into a [UserPrefs] object.
  /// Needed because [shared_preferences] can only store simple strings, so we convert them to objects here.
  UserPrefs readUserPrefs() {
    List<String> frontPrefs = this._sp.getStringList(K.CARD_FRONT_ELEMENTS) ?? D.CARD_FRONT_ELEMENTS;
    List<String> backPrefs = this._sp.getStringList(K.CARD_BACK_ELEMENTS) ?? D.CARD_BACK_ELEMENTS;

    UserPrefs fields = UserPrefs(
      cardFrontKanji: frontPrefs.contains(FlashcardElementType.kanji.code.toString()),
      cardFrontKana: frontPrefs.contains(FlashcardElementType.kana.code.toString()),
      cardFrontRomaji: frontPrefs.contains(FlashcardElementType.romaji.code.toString()),
      cardFrontMeaning: frontPrefs.contains(FlashcardElementType.meaning.code.toString()),
      cardBackKanji: backPrefs.contains(FlashcardElementType.kanji.code.toString()),
      cardBackKana: backPrefs.contains(FlashcardElementType.kana.code.toString()),
      cardBackRomaji: backPrefs.contains(FlashcardElementType.romaji.code.toString()),
      cardBackMeaning: backPrefs.contains(FlashcardElementType.meaning.code.toString()),
      language: this.readLanguage(),
      editionBookOne: this.readEdition(Book.one),
      editionBookTwo: this.readEdition(Book.two),
      correctSide: this.readCorrectSide(),
      performance: this.readPerformanceMode(),
      contrast: this.readHighContrastMode(),
    );

    return fields;
  }

  /// Writes a value of [value] to [e] in [shared_preferences]. Used for card front or back preferences.
  void writeFlashcardPrefs(FlashcardElementType e, bool front, bool value) {
    List<String> currentList = List.from(
        this._sp.getStringList(front ? K.CARD_FRONT_ELEMENTS : K.CARD_BACK_ELEMENTS) ?? (front ? D.CARD_FRONT_ELEMENTS : D.CARD_BACK_ELEMENTS));

    if (value) {
      currentList.add(e.code.toString());
    } else {
      currentList.remove(e.code.toString());
    }

    this._sp.setStringList(front ? K.CARD_FRONT_ELEMENTS : K.CARD_BACK_ELEMENTS, currentList);
  }

  /// Writes the default values to [shared_preferences] if no data is found.
  void writeDefaults() {
    if (!this._sp.containsKey(K.CARD_FRONT_ELEMENTS)) {
      this._sp.setStringList(K.CARD_FRONT_ELEMENTS, D.CARD_FRONT_ELEMENTS);
    }
    if (!this._sp.containsKey(K.CARD_BACK_ELEMENTS)) {
      this._sp.setStringList(K.CARD_BACK_ELEMENTS, D.CARD_BACK_ELEMENTS);
    }
    if (!this._sp.containsKey(K.LANGUAGE)) {
      this._sp.setInt(K.LANGUAGE, D.LANGUAGE.code);
    }
  }

  /// Returns a snapshot of [shared_preferences] for analysis and validation (see [validate]).
  Map<String, dynamic> get getSnapshot => {for (String key in this._sp.getKeys()) key: this._sp.get(key)};

  /// Should the user be greeted with the onboarding page ?
  bool readOnboarding() {
    // If it's nowhere to be found, it probably means it has yet to be done
    return this._sp.getBool(K.ONBOARDING) ?? D.ONBOARDING;
  }

  /// Used to write `true` to [shared_preferences] when onboarding has been completed.
  void writeOnboarding(bool value) {
    this._sp.setBool(K.ONBOARDING, value);
  }

  /// Reads the score of a word. If none is found, will return 0.
  int readWordScore(WordID id) {
    return this._sp.getInt(id.toKey) ?? D.WORD_SCORE;
  }

  /// Add or subtract one from the score of [id]. Enforces checks so that it remains in interval [D.WORD_SCORE_MIN] ; [D.WORD_SCORE_MAX].
  void writeWordScore(WordID id, bool success) {
    int currentValue = this._sp.getInt(id.toKey) ?? D.WORD_SCORE;
    currentValue = (success)
        ? (currentValue < D.WORD_SCORE_MAX)
            ? currentValue + 1
            : currentValue
        : (currentValue > D.WORD_SCORE_MIN)
            ? currentValue - 1
            : currentValue;

    this._sp.setInt(id.toKey, currentValue);
  }

  /// Read selected [DSLanguage] from [shared_preferences].
  DSLanguage readLanguage() {
    int code = this._sp.getInt(K.LANGUAGE) ?? D.LANGUAGE.code;
    return DSLanguage.fromCode(code);
  }

  /// Write selected [DSLanguage] to [shared_preferences].
  void writeLanguage(DSLanguage language) {
    this._sp.setInt(K.LANGUAGE, language.code);
  }

  /// Read selected [Edition] for [book].
  Edition readEdition(Book book) {
    String key = switch (book) {
      Book.one => K.BOOK_ONE_EDITION,
      Book.two => K.BOOK_TWO_EDITION,
    };
    int code = this._sp.getInt(key) ??
        switch (book) {
          Book.one => D.BOOK_ONE_EDITION.code,
          Book.two => D.BOOK_TWO_EDITION.code,
        };
    return Edition.fromCode(code);
  }

  /// Write selected [edition] for [book] to [shared_preferences].
  void writeEdition(Book book, Edition edition) {
    String key = switch (book) {
      Book.one => K.BOOK_ONE_EDITION,
      Book.two => K.BOOK_TWO_EDITION,
    };
    this._sp.setInt(key, edition.code);
  }

  /// Read selected [Deck] to be used when doing a review.
  Deck readTargetDeckReview() {
    return switch (this._sp.getString(K.TARGET_DECK_REVIEW)) {
      K.DECK_ONE_CONTENTS => Deck.one,
      K.DECK_TWO_CONTENTS => Deck.two,
      K.DECK_THREE_CONTENTS => Deck.three,
      _ => D.SEL_DECK_REVIEW,
    };
  }

  /// Write selected [Deck] to be used when doing a review.
  void writeTargetDeckReview(Deck deck) {
    this._sp.setString(K.TARGET_DECK_REVIEW, deck.key);
  }

  /// Read selected [Deck] for words to be added to when doing a quiz.
  Deck readTargetDeckInsert() {
    return switch (this._sp.getString(K.TARGET_DECK_INSERT)) {
      K.DECK_ONE_CONTENTS => Deck.one,
      K.DECK_TWO_CONTENTS => Deck.two,
      K.DECK_THREE_CONTENTS => Deck.three,
      _ => D.SEL_DECK_INSERT,
    };
  }

  /// Write selected [Deck] for words to be added to when doing a quiz.
  void writeTargetDeckInsert(Deck deck) {
    this._sp.setString(K.TARGET_DECK_INSERT, deck.key);
  }

  /// Check whether a [WordID] is present in [deck].
  bool isInDeck(WordID id, Deck deck) {
    List<String> currentDeck = this._sp.getStringList(deck.key) ?? D.DECK_CONTENTS;

    return currentDeck.contains(id.toCode);
  }

  /// Add a [WordID] to [deck].
  /// Returns true if the word was added, false if it was already in [deck].
  bool addToDeck(WordID id, Deck deck) {
    bool wasAdded = false;

    List<String> currentDeck = List.from(this._sp.getStringList(deck.key) ?? D.DECK_CONTENTS);

    if (!currentDeck.contains(id.toCode)) {
      currentDeck.add(id.toCode);
      wasAdded = true;
    }

    this._sp.setStringList(deck.key, currentDeck);

    return wasAdded;
  }

  /// Remove a [WordID] from [deck].
  void removeFromDeck(WordID id, Deck deck) {
    List<String> currentDeck = List.from(this._sp.getStringList(deck.key) ?? D.DECK_CONTENTS);

    currentDeck.remove(id.toCode);

    this._sp.setStringList(deck.key, currentDeck);
  }

  /// Read and return the list of all [WordID] from [deck].
  List<WordID> readDeck(Deck deck) {
    List<WordID> output = [];

    List<String> currentDeck = this._sp.getStringList(deck.key) ?? D.DECK_CONTENTS;

    for (String idStr in currentDeck) output.add(WordIDToolkit.fromCode(idStr));

    return output;
  }

  /// Clear all [WordID] from [deck].
  void clearDeck(Deck deck) {
    this._sp.setStringList(deck.key, []);
  }

  /// Is the auto-remove feature enabled on [deck] ?
  bool readDeckAutoRemove(Deck deck) {
    return this._sp.getBool(deck.autoremoveKey) ?? D.AUTOREMOVE;
  }

  /// Enable or disable auto-remove feature on [deck].
  void writeDeckAutoRemove(Deck deck, bool value) {
    this._sp.setBool(deck.autoremoveKey, value);
  }

  /// Add [lesson] to the (stored) list of selected lessons (in the main menu).
  void addSelectedLesson(LessonNumber lesson) {
    List<String> currentLessons = List.from(this._sp.getStringList(K.SELECTED_LESSONS) ?? D.SELECTED_LESSONS);
    currentLessons.add(lesson.toString());
    this._sp.setStringList(K.SELECTED_LESSONS, currentLessons);
  }

  /// Remove [lesson] from the (stored) list of selected lessons (in the main menu).
  void removeSelectedLesson(LessonNumber lesson) {
    List<String> currentLessons = List.from(this._sp.getStringList(K.SELECTED_LESSONS) ?? D.SELECTED_LESSONS);
    currentLessons.remove(lesson.toString());
    this._sp.setStringList(K.SELECTED_LESSONS, currentLessons);
  }

  /// Read and return the list of selected [LessonNumber] from the (stored) list of selected lessons (in the main menu).
  List<LessonNumber> readSelectedLessons() {
    List<String> currentLessons = this._sp.getStringList(K.SELECTED_LESSONS) ?? D.SELECTED_LESSONS;
    return LessonNumberToolkit.fromList(currentLessons);
  }

  /// Remove all [LessonNumber] from the (stored) list of selected lessons (in the main menu).
  void clearSelectedLessons() {
    this._sp.setStringList(K.SELECTED_LESSONS, <String>[]);
  }

  /// Add all possible [LessonNumber] to the (stored) list of selected lessons (in the main menu).
  void writeSelectAllLessons(DSInterface ds) {
    this._sp.setStringList(K.SELECTED_LESSONS, LessonNumberToolkit.toList(ds.lessonNumbers));
  }

  /// Read and return whether to limit the number of words drawn to [readWordCountPerQuiz] when drawing for a quiz.
  WholeSelectionButtonState readQuizDrawWholeSelection() {
    return ((this._sp.getBool(K.QUIZ_DRAW_WHOLE_SELECTION) ?? D.QUIZ_DRAW_WHOLE_SELECTION) == true)
        ? WholeSelectionButtonState.yes
        : WholeSelectionButtonState.no;
  }

  /// Write whether to limit the number of words drawn to [readWordCountPerQuiz] when drawing for a quiz.
  void writeQuizDrawWholeSelection(WholeSelectionButtonState value) {
    this._sp.setBool(K.QUIZ_DRAW_WHOLE_SELECTION, value.asBool);
  }

  /// Reads the number of words to draw for each quiz.
  int readWordCountPerQuiz() {
    int count = this._sp.getInt(K.QUIZ_WORD_COUNT) ?? D.QUIZ_WORD_COUNT;
    return count;
  }

  /// Writes the number of words to draw for each quiz.
  void writeWordCountPerQuiz(int count) {
    this._sp.setInt(K.QUIZ_WORD_COUNT, count);
  }

  /// Read selected [QuizWordFilter].
  QuizWordFilter readQuizFilter() {
    int code = this._sp.getInt(K.QUIZ_WORD_FILTER) ?? D.QUIZ_WORD_FILTER.code;
    return QuizWordFilter.fromCode(code);
  }

  /// Write selected [QuizWordFilter].
  void writeQuizFilter(QuizWordFilter filter) {
    this._sp.setInt(K.QUIZ_WORD_FILTER, filter.code);
  }

  /// Read selected [ReviewOrder].
  ReviewOrder readReviewOrder() {
    int code = this._sp.getInt(K.REVIEW_ORDER) ?? D.REVIEW_ORDER.code;
    return ReviewOrder.fromCode(code);
  }

  /// Write selected [ReviewOrder].
  void writeReviewOrder(ReviewOrder order) {
    this._sp.setInt(K.REVIEW_ORDER, order.code);
  }

  /// Remove all [Word] that aren't from [readEdition] in [wordList].
  List<Word> pruneWordListToEdition(DSInterface ds, List<Word> wordList) {
    final Edition editionBookOne = this.readEdition(Book.one);
    final Edition editionBookTwo = this.readEdition(Book.two);

    return wordList
        .where(
          (word) => (word.id[DSKeyring.ID_INDEX_LESSON] <= 25) ? word.edition.contains(editionBookOne) : word.edition.contains(editionBookTwo),
        )
        .toList();
  }

  /// Read the [LessonScore] for a single [lessonNumber].
  LessonScore singleLessonScore(DSInterface ds, LessonNumber lessonNumber) {
    List<Word> wordPool = this.pruneWordListToEdition(ds, ds.getLessonAllWords(lessonNumber));

    int masteredCount = 0;
    int scorePoints = 0;
    // Check individual scores of each existing words for this lesson
    for (final Word word in wordPool) {
      // fetch em word scores
      int wordScore = this._sp.getInt(word.id.toKey) ?? D.WORD_SCORE;
      scorePoints += wordScore;

      if (wordScore >= D.WORD_SCORE_MAX) {
        masteredCount += 1;
      }
    }

    return <double>[masteredCount.toDouble(), wordPool.length.toDouble(), scorePoints / ((D.WORD_SCORE_MAX - D.WORD_SCORE_MIN) * wordPool.length)];
  }

  /// Reset the score of [lessonNumber]. Will delete entries of word scores for the corresponding lesson.
  void resetLessonScore(LessonNumber lessonNumber) {
    final Set<String> idStrList = this._sp.getKeys();
    // Will match any string that follows the pattern `"lessonNumber,someInteger"`
    final RegExp pattern = RegExp("^${K.SCORE_PREFIX}$lessonNumber,\\d+");

    final matchingIds = idStrList.where((idStr) => pattern.hasMatch(idStr));

    // Remove all matching entries from [shared_preferences]
    for (final idStr in matchingIds) {
      this._sp.remove(idStr);
    }
  }

  /// Is performance mode enabled ?
  bool readPerformanceMode() {
    return this._sp.getBool(K.PERFORMANCE_MODE) ?? D.PERFORMANCE_MODE;
  }

  /// Write set preference for performance mode.
  void writePerformanceMode(bool value) {
    this._sp.setBool(K.PERFORMANCE_MODE, value);
  }

  /// Is high contrast mode enabled ?
  bool readHighContrastMode() {
    return this._sp.getBool(K.HIGH_CONTRAST_MODE) ?? D.HIGH_CONTRAST_MODE;
  }

  /// Write set preference for high contrast mode.
  void writeHighContrastMode(bool value) {
    this._sp.setBool(K.HIGH_CONTRAST_MODE, value);
  }

  /// Read selected [CorrectSide].
  CorrectSide readCorrectSide() {
    int code = this._sp.getInt(K.CORRECT_SIDE) ?? D.CORRECT_SIDE.code;
    return CorrectSide.fromCode(code);
  }

  /// Write selected [CorrectSide].
  void writeCorrectSide(CorrectSide s) {
    this._sp.setInt(K.CORRECT_SIDE, s.code);
  }

  /// Performs tests on the entries found in [snapshot], to ensure they are of valid types and within expected range.
  /// When [snapshot] is null, validates the [shared_preferences] state.
  /// Returns modified data for external snapshots, null for internal validation.
  ///
  /// Also I made up a syntax to spell out tests before writing them in code :
  /// ```
  /// Must be : <type>
  /// !>> action to take if the above is not true
  ///
  /// With elements (for lists) :
  ///   * Condition an element of the list must fill
  ///   * Or <another condition>
  ///   * Or ...
  /// !>> action to take if the above is not true
  ///
  ///
  /// With values (for int or String) :
  ///   * Condition that must be filled
  ///   * Or ...
  /// !>> action to take if the above is not true
  /// ```
  Map<String, dynamic>? validate(DSInterface ds, {Map<String, dynamic>? snapshot}) {
    /// Are we validating [this] or a user-provided instance ?
    final bool isLocal = snapshot is! Map<String, dynamic>;

    final Map<String, dynamic> _snapshot = isLocal ? this.getSnapshot : snapshot;
    Map<String, dynamic>? output = isLocal ? null : Map.from(_snapshot);

    final Function(String) removeFn = isLocal ? this._sp.remove : output!.remove;
    final Function(String, List<String>) writeFn = isLocal ? this._sp.setStringList : (String key, List<String> list) => output![key] = list;

    _snapshot.forEach(
      (key, value) {
        switch (key) {
          /// Must be : [bool]
          /// !>> delete entry
          case K.ONBOARDING:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! bool) fix.call();
            }

          /// Must be : [List<String>]
          /// !>> delete entry
          ///
          /// With elements :
          ///   * none (empty list)
          ///   * [String.toWordID] contained in the DS
          /// !>> remove element
          case K.DECK_ONE_CONTENTS || K.DECK_TWO_CONTENTS || K.DECK_THREE_CONTENTS:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! List)
                fix.call();
              else {
                List<String> perhapsFixed = value.where((s) => s is String && ds.isInDS(WordIDToolkit.fromCode(s))).toList().cast<String>();

                if (perhapsFixed.length != value.length) {
                  writeFn(key, perhapsFixed);
                  // print("Some elements were removed from $key");
                }
              }
            }

          /// Must be : [List<String>]
          /// !>> delete entry
          ///
          /// With elements :
          ///   * none (empty list)
          ///   * [FlashcardElementType.<variant>.code]
          /// !>> remove element
          case K.CARD_FRONT_ELEMENTS || K.CARD_BACK_ELEMENTS:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! List)
                fix.call();
              else {
                final List<int> validCodes = FlashcardElementType.values.map((e) => e.code).toList();
                List<String> perhapsFixed = value
                    .where(
                      (element) {
                        late final bool output;
                        if (element is String) {
                          int? code = int.tryParse(element);
                          output = code is int && validCodes.contains(code);
                        } else {
                          output = false;
                        }
                        return output;
                      },
                    )
                    .toList()
                    .cast<String>();

                if (perhapsFixed.length != value.length) {
                  writeFn(key, perhapsFixed);
                  // print("Some elements were removed from $key");
                }
              }
            }

          /// Must be : [int]
          /// !>> delete entry
          ///
          /// With values :
          ///   * [DSLanguage.<variant>.name]
          /// !>> delete entry
          case K.LANGUAGE:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! int)
                fix.call();
              else {
                final List<int> validCodes = DSLanguage.values.map((e) => e.code).toList();
                if (!(validCodes.contains(value))) fix();
              }
            }

          /// Must be : [List<String>]
          /// !>> delete entry
          ///
          /// With elements :
          ///   * none (empty list)
          ///   * [LessonNumber.<variant>.toString()]
          /// !>> remove element
          case K.SELECTED_LESSONS:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! List)
                fix.call();
              else {
                final int minLesson = ds.lessonNumbers.reduce(min);
                final int maxLesson = ds.lessonNumbers.reduce(max);
                List<String> perhapsFixed = value
                    .where(
                      (element) {
                        late final bool output;
                        if (element is String) {
                          LessonNumber? number = LessonNumber.tryParse(element);
                          output = number is LessonNumber && number >= minLesson && number <= maxLesson;
                        } else {
                          output = false;
                        }
                        return output;
                      },
                    )
                    .toList()
                    .cast<String>();

                if (perhapsFixed.length != value.length) {
                  writeFn(key, perhapsFixed);
                  // print("Some elements were removed from $key");
                }
              }
            }

          /// Must be : [bool]
          /// !>> delete entry
          case K.QUIZ_DRAW_WHOLE_SELECTION:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! bool) fix.call();
            }

          /// Must be : [int]
          /// !>> delete entry
          ///
          /// With values :
          ///   * [D.WORD_COUNT_MIN] <= _ <= [D.WORD_COUNT_MAX]
          /// !>> delete entry
          case K.QUIZ_WORD_COUNT:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! int || value < D.WORD_COUNT_MIN || value > D.WORD_COUNT_MAX) fix.call();
            }

          /// Must be : [int]
          /// !>> delete entry
          ///
          /// With values :
          ///   * [QuizWordFilter.<variant>.code]
          /// !>> delete entry
          case K.QUIZ_WORD_FILTER:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! int)
                fix.call();
              else {
                final List<int> validCodes = QuizWordFilter.values.map((e) => e.code).toList();
                if (!(validCodes.contains(value))) fix();
              }
            }

          /// Must be : [int]
          /// !>> delete entry
          ///
          /// With values :
          ///   * [ReviewOrder.<variant>.code]
          /// !>> delete entry
          case K.REVIEW_ORDER:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! int)
                fix.call();
              else {
                final List<int> validCodes = ReviewOrder.values.map((e) => e.code).toList();
                if (!(validCodes.contains(value))) fix();
              }
            }

          /// Must be : [int]
          /// !>> delete entry
          ///
          /// With values :
          ///   * [CorrectSide.<variant>.code]
          /// !>> delete entry
          case K.CORRECT_SIDE:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! int)
                fix.call();
              else {
                final List<int> validCodes = CorrectSide.values.map((e) => e.code).toList();
                if (!(validCodes.contains(value))) fix();
              }
            }

          /// Must be : [String]
          /// !>> delete entry
          ///
          /// With values :
          ///   * [Deck.<variant>.key]
          /// !>> delete entry
          case K.TARGET_DECK_REVIEW || K.TARGET_DECK_INSERT:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! String)
                fix.call();
              else {
                final List<String> validCodes = Deck.values.map((e) => e.key).toList();
                if (!(validCodes.contains(value))) fix();
              }
            }

          /// Must be : [bool]
          /// !>> delete entry
          case K.DECK_ONE_AUTOREMOVE || K.DECK_TWO_AUTOREMOVE || K.DECK_THREE_AUTOREMOVE:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! bool) fix.call();
            }

          /// Must be : [bool]
          /// !>> delete entry
          case K.PERFORMANCE_MODE:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! bool) fix.call();
            }

          /// Must be : [bool]
          /// !>> delete entry
          case K.HIGH_CONTRAST_MODE:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! bool) fix.call();
            }

          /// Must be : [int]
          /// !>> delete entry
          ///
          /// With values :
          ///   * [Edition.<variant>.code]
          /// !>> delete entry
          case K.BOOK_ONE_EDITION || K.BOOK_TWO_EDITION:
            {
              fix() {
                removeFn(key);
                // print("removed $key : $value");
              }

              if (value is! int)
                fix.call();
              else {
                final List<int> validCodes = Edition.values.map((e) => e.code).toList();
                if (!(validCodes.contains(value))) fix();
              }
            }
          default:
            {
              /// Must be : [int]
              /// !>> delete entry
              ///
              /// With values :
              ///   * [D.WORD_SCORE_MIN] <= _ <= [D.WORD_SCORE_MAX]
              /// !>> delete entry
              if (key.startsWith(K.SCORE_PREFIX)) {
                fix() {
                  removeFn(key);
                  // print("SCORE removed $key : $value");
                }

                if (value is! int || value < D.WORD_SCORE_MIN || value > D.WORD_SCORE_MAX) fix.call();
              } else {
                fix() {
                  removeFn(key);
                  // print("INVALID removed $key : $value");
                }

                fix.call();
              }
            }
        }
      },
    );
    return output;
  }

  /// Exports all user data to a JSON file.
  /// The file can then be used as a backup or transfer progress to another device.
  void dumpToJSON() async {
    final data = {for (String key in this._sp.getKeys()) key: this._sp.get(key)};

    final String jsonString = jsonEncode(data);

    final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

    kIsWeb
        ? await FileSaver.instance.saveFile(
            name: "data",
            bytes: bytes,
            ext: "json",
            mimeType: MimeType.json,
          )
        : await FileSaver.instance.saveAs(
            name: "data",
            bytes: bytes,
            ext: "json",
            mimeType: MimeType.json,
          );
  }

  /// ! Clear all user data. There is no going back !
  void clearData() {
    this._sp.clear();
  }

  /// Imports user data from a JSON file into [shared_preferences].
  /// Returns [true] if the import was successful.
  ///
  /// ! Note : This will clear all existing data before importing.
  Future<bool> importFromFile(DSInterface ds) async {
    bool output = false;
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>["json"],
      );
    } on PlatformException catch (e) {
      if (e.code == "FilePicker") {
        result = await FilePicker.platform.pickFiles(type: FileType.any);
      }
    }

    if (result is FilePickerResult) {
      String jsonString;

      if (kIsWeb) {
        final Uint8List bytes = result.files.single.bytes!;
        jsonString = utf8.decode(bytes);
      } else {
        File file = File(result.files.single.path!);
        jsonString = await file.readAsString();
      }

      try {
        final Map<String, dynamic> rawData = jsonDecode(jsonString);
        final Map<String, dynamic> processedData = this.validate(ds, snapshot: rawData) ?? rawData;

        this.clearData();

        processedData.forEach(
          (key, value) {
            if (value is bool) {
              // print("Got BOOL ${key} : ${value}");
              this._sp.setBool(key, value);
            } else if (value is String) {
              // print("Got STRING ${key} : ${value}");
              this._sp.setString(key, value);
            } else if (value is int) {
              // print("Got INT ${key} : ${value}");
              this._sp.setInt(key, value);
            } else if (value is List && value.every((element) => element is String)) {
              // print("Got LIST<STR> ${key} : ${value}");
              this._sp.setStringList(key, value.map((e) => e as String).toList());
            } else {
              // If we don't know what it is, don't do anything with it.
              // print("UNKNOWN $key : $value of type ${value.runtimeType}");
            }
          },
        );
        output = true;
      } catch (_) {} // Do not crash if it didn't work
    }
    return output;
  }
}
