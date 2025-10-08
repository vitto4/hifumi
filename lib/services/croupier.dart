import "dart:math";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/abstractions/@symbols.dart";
import "package:hifumi/pages/quiz/card_pile/card_element.dart";

/// ! TW : spaghetti code.
///
/// Turns a word and its data into a collection of [CardElement].
/// Two [List]s actually, one for the front of the flashcard, the second for the back.
List<List<CardElement>> _cardElementBuilder(DSInterface ds, UserPrefs userPreferences, Word word) {
  List<List<CardElement>> output = [[], []];

  /// (Safety check, we know that the DS contains meanings for all supported languages)
  DSLanguage language = (ds.getSupportedLanguages.contains(userPreferences.language)) ? userPreferences.language : DSLanguage.en;

  /* ------------------------------- CARD FRONT ------------------------------- */

  if (userPreferences.cardFrontKanji) {
    final bool displayKanji = word.hasKanji || !(userPreferences.cardFrontKana || userPreferences.cardFrontRomaji);
    output[0].add(
      CardElement(
        title: "Kanji",
        text: displayKanji ? word.withKanji : "∅",
        fontSize: fontSizeHandler(Symbols.japanese, word.withKanji.length),
        symbols: Symbols.japanese,
        fadeText: !displayKanji,
      ),
    );
  }
  if (userPreferences.cardFrontKana) {
    output[0].add(
      CardElement(
        title: "Kana",
        text: word.kana,
        fontSize: fontSizeHandler(Symbols.japanese, word.kana.length),
        symbols: Symbols.japanese,
      ),
    );
  }
  if (userPreferences.cardFrontRomaji) {
    output[0].add(
      CardElement(
        title: "Rōmaji",
        text: word.romaji,
        fontSize: fontSizeHandler(Symbols.latin, word.romaji.length) + 2,
      ),
    );
  }
  if (userPreferences.cardFrontMeaning) {
    final String meaning = (word.meaning)[language]!; // Shouldn't cause problems, thanks to the check we did earlier on `language`
    output[0].add(
      CardElement(
        title: "Meaning",
        text: meaning,
        fontSize: fontSizeHandler(Symbols.latin, meaning.length),
      ),
    );
  }

  /* -------------------------------- CARD BACK ------------------------------- */

  if (userPreferences.cardBackKanji) {
    final bool displayKanji = word.hasKanji || !(userPreferences.cardBackKana || userPreferences.cardBackRomaji);
    output[1].add(
      CardElement(
        title: "Kanji",
        text: displayKanji ? word.withKanji : "∅",
        fontSize: fontSizeHandler(Symbols.japanese, word.withKanji.length),
        symbols: Symbols.japanese,
        fadeText: !displayKanji,
      ),
    );
  }
  if (userPreferences.cardBackKana) {
    output[1].add(
      CardElement(
        title: "Kana",
        text: word.kana,
        fontSize: fontSizeHandler(Symbols.japanese, word.kana.length),
        symbols: Symbols.japanese,
      ),
    );
  }
  if (userPreferences.cardBackRomaji) {
    output[1].add(
      CardElement(
        title: "Rōmaji",
        text: word.romaji,
        fontSize: fontSizeHandler(Symbols.latin, word.romaji.length) + 2,
      ),
    );
  }
  if (userPreferences.cardBackMeaning) {
    final String meaning = (word.meaning)[language]!;
    output[1].add(
      CardElement(
        title: "Meaning",
        text: meaning,
        fontSize: fontSizeHandler(Symbols.latin, meaning.length),
      ),
    );
  }
  return output;
}

/// Build a set of [Flashcard] with [cardCount] cards from selected [lessons].
/// Will be shuffled as well, see [DSInterface.stirGentlyThenDice].
///
/// (it's mildly annoying how I can't figure out a way to arrange the function's code in a way that doesn't look bad haha)
List<Flashcard> dealCardsFromLessons(SPInterface st, DSInterface ds, List<LessonNumber> lessons, int cardCount) {
  final UserPrefs userPreferences = st.readUserPrefs();
  final List<Word> wordPool = ds.bakeWordPoolFromLessons(lessons, wordCount: cardCount, pruneEditions: true);
  List<Flashcard> output = [];

  for (Word word in wordPool) {
    final List<List<CardElement>> elements = _cardElementBuilder(ds, userPreferences, word);
    output.add(
      Flashcard(
        id: word.id,
        jishoURL: "https://jisho.org/search/${word.withKanji}",
        frontContent: elements[0],
        backContent: elements[1],
      ),
    );
  }

  return output;
}

/// Removes all the [WordID] of words that have been mastered from a list of [WordID].
List<WordID> _pruneIDListToMistakes(SPInterface st, List<WordID> idList) {
  List<WordID> output = idList.toList();
  for (WordID id in idList) {
    if (st.readWordScore(id) >= D.WORD_SCORE_MAX) {
      // If the card has already been mastered
      output.remove(id);
    }
  }
  return output;
}

/// Build a set of [Flashcard] from a list of [WordID].
List<Flashcard> _dealCardsFromIDs(SPInterface st, DSInterface ds, List<WordID> idList, {bool shuffle = false}) {
  final random = Random();
  final UserPrefs userPreferences = st.readUserPrefs();
  final List<Word> wordPool = ds.bakeWordPoolFromID(idList);
  List<Flashcard> output = [];

  for (var word in wordPool) {
    final List<List<CardElement>> elements = _cardElementBuilder(ds, userPreferences, word);
    output.add(
      Flashcard(
        id: word.id,
        jishoURL: "https://jisho.org/search/${word.withKanji}",
        frontContent: elements[0],
        backContent: elements[1],
      ),
    );
  }

  // If shuffle is enabled, shuffle the list before returning
  if (shuffle) output.shuffle(random);

  return output;
}

/// Build a set of [Flashcard] from selected [lessons], but remove mastered words, and if applicable trim down to [cardCount].
/// Will be shuffled.
List<Flashcard> dealCardsFromMistakes(SPInterface st, DSInterface ds, List<LessonNumber> lessons, int cardCount) {
  // When doing a quiz, we don't want words from other editions showing up, hence `pruneEdition: true`
  List<WordID> idList = ds.bakeWordIDListFromLessons(lessons, pruneEditions: true);

  List<WordID> idListPruned = _pruneIDListToMistakes(st, idList);

  // [DSInterface.stirGentlyThenDice] is supposed to be used with a word pool, but since it's designed independently of the list type, it'll work just fine here.
  // Shuffles `idListPruned` and slices it if it contains more than `cardCount` IDs.
  List<WordID> idListPrunedSliced = DSInterface.stirGentlyThenDice(idListPruned, cardCount);

  return _dealCardsFromIDs(st, ds, idListPrunedSliced);
}

/// Build a set of [Flashcard] from selected [deck].
List<Flashcard> dealCardsFromDeck(SPInterface st, DSInterface ds, Deck deck, {bool shuffle = false}) {
  List<WordID> idList = st.readDeck(deck);

  // When doing a review, it's fine for words from other editions to show up if they're in a deck.
  return _dealCardsFromIDs(st, ds, idList, shuffle: shuffle);
}

/// Japanese symbols tend to be wider than latin ones.
/// To properly fit inside the cards, font size is adapted as follows.
/// Font size values were determined by trial and error.
const double _kFontSizeLatinShort = 18.0;
const double _kFontSizeLatinMedium = 15.0;
const double _kFontSizeLatinLong = 13.0;
const double _kFontSizeJapaneseShort = 24.0;
const double _kFontSizeJapaneseMedium = 20.0;
const double _kFontSizeJapaneseLong = 16.0;

/// Adjusts font size based on text length.
double fontSizeHandler(Symbols type, int length) {
  return switch (type) {
    Symbols.latin =>
      (length < 50)
          ? _kFontSizeLatinShort
          : (length > 100)
          ? _kFontSizeLatinLong
          : _kFontSizeLatinMedium,
    Symbols.japanese =>
      (length < 11)
          ? _kFontSizeJapaneseShort
          : (length > 15)
          ? _kFontSizeJapaneseLong
          : _kFontSizeJapaneseMedium,
  };
}
