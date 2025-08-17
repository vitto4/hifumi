import "dart:convert";
import "dart:math";
import "package:flutter/services.dart" show rootBundle;
import "package:flutter/foundation.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:yaml/yaml.dart";

/// Everything dataset-related is handled here.
class DSInterface {
  /* ---------------------------------- Setup --------------------------------- */
  late final Map<String, dynamic> dataset;

  /// These won't change throughout this class' lifetime, so might as well cache them once and for all.
  /// Memory footprint seems to be of a few kb at most anyway.
  late final List<String> _allLessonKeys;
  late final List<LessonNumber> _allLessonNumbers;
  late final List<WordID> _allWordIDs;
  late final List<WordYAML> _allWords;

  /// User-selected editions at load time.
  final Edition bookOneEdition;
  final Edition bookTwoEdition;

  DSInterface({
    required this.bookOneEdition,
    required this.bookTwoEdition,
  });

  /// Wake it up gently.
  Future<void> init() async {
    final yamlString = await rootBundle.loadString('assets/dataset/minna-no-ds.yaml');
    // https://github.com/dart-lang/yaml/issues/147
    // Doing this because working on a [Map] with thousands of objects seems to be much faster than on a [YamlMap] (10 to 20 times on my hardware !!)
    this.dataset = json.decode(json.encode(loadYaml(yamlString)));
    this._allLessonKeys = this._getAllLessonKeys;
    this._allLessonNumbers = this._getLessonNumbers;
    this._allWordIDs = this._getAllWordIDs;
    this._allWords = this._getAllWords;
    print("[Loading] Dataset initialized with ${this._allWordIDs.length} words (1: ${this.bookOneEdition}, 2: ${this.bookTwoEdition}).");
  }

  /* ------------------------------------ . ----------------------------------- */

  /// Get the list of YAML keys for lessons.
  /// Something like `["lesson-01", "lesson-02", ...]`.
  List<String> get _getAllLessonKeys => List<String>.from(
    (this.dataset[DSKeyring.LESSONS] as List<dynamic>).map(
      (lesson) => lesson[DSKeyring.LESSON_KEY] as String,
    ),
  );

  /// Fetches all available lessons from the dataset, and returns their [LessonNumber] as a list.
  List<LessonNumber> get _getLessonNumbers {
    final List<dynamic> lessons = this.dataset[DSKeyring.LESSONS];
    return lessons.map<LessonNumber>((lesson) => lesson[DSKeyring.LESSON_NUMBER] as LessonNumber).toList();
  }

  /// Returns all available lessons from the dataset as a list of [LessonNumber].
  List<LessonNumber> get lessonNumbers => this._allLessonNumbers;

  /// One hour ! A whole hour has gone into getting this type cast to work =(
  List<WordID> get _getAllWordIDs => this._allLessonKeys
      .expand(
        (key) => (this.dataset[key] as List<dynamic>).map((word) => (word[DSKeyring.WORD_ID] as List<dynamic>).cast<int>()),
      )
      .toList();

  /// Does what it says, generates a list of all words from the dataset, in [WordYAML] format.
  List<WordYAML> get _getAllWords => this._allLessonKeys.expand((key) => (this.dataset[key] as List<dynamic>)).toList().cast<WordYAML>();

  /// Simple function to turn `x` ([int]) into the expected key `"lesson-x"` ([String]).
  String _lessonKeyFromNumber(LessonNumber number) {
    final List<dynamic> lessons = this.dataset[DSKeyring.LESSONS];
    return lessons.firstWhere((lesson) => lesson[DSKeyring.LESSON_NUMBER] == number)[DSKeyring.LESSON_KEY];
  }

  /// Checks whether [id] corresponds to an existing word.
  bool isInDS(WordID id) {
    return this._allWordIDs.any((WordID _id) => listEquals(_id, id));
  }

  /// Fetches a word using its [WordID]. Will handle the conversion from [WordYAML] to [Word].
  Word fetchWordByID(WordID idToFetch) {
    WordYAML wordYAML = this._allWords
        .where(
          (word) =>
              word[DSKeyring.WORD_ID][DSKeyring.ID_INDEX_LESSON] == idToFetch[DSKeyring.ID_INDEX_LESSON] &&
              word[DSKeyring.WORD_ID][DSKeyring.ID_INDEX_WORD] == idToFetch[DSKeyring.ID_INDEX_WORD],
        )
        .elementAt(0); // We want a map, not an iterable. There should be only one match so we take the first one anyway.

    return Word(
      wordYAML: wordYAML,
      supportedLanguages: this.getSupportedLanguages,
    );
  }

  /// Remove all [Word]s that aren't from selected [Edition]s in [wordList].
  List<Word> pruneToEditions(List<Word> wordList) {
    return wordList
        .where(
          (word) =>
              (word.id[DSKeyring.ID_INDEX_LESSON] <= 25) ? word.edition.contains(this.bookOneEdition) : word.edition.contains(this.bookTwoEdition),
        )
        .toList();
  }

  /// Get a list of all the words lesson n°[lessonNumber].
  List<Word> getLessonAllWords(LessonNumber lessonNumber, {bool pruneEditions = false}) {
    List<WordYAML> outputYAML = [];
    outputYAML.addAll(this.dataset[this._lessonKeyFromNumber(lessonNumber)].cast<WordYAML>());

    List<Word> wordList = [
      for (WordYAML wordYAML in outputYAML)
        Word(
          wordYAML: wordYAML,
          supportedLanguages: this.getSupportedLanguages,
        ),
    ];
    if (pruneEditions) wordList = this.pruneToEditions(wordList);

    return wordList;
  }

  /// Creates a pool of (all) words from selected [lessons].
  List<Word> _getPoolFromLesson(List<LessonNumber> lessons, {bool pruneEditions = false}) {
    List<Word> output = [];
    for (var lessonNumber in lessons) {
      output.addAll(this.getLessonAllWords(lessonNumber, pruneEditions: pruneEditions));
    }
    return output;
  }

  /// Creates a list of all the words' IDs from selected [lessons].
  List<WordID> bakeWordIDListFromLessons(List<LessonNumber> lessons, {bool pruneEditions = false}) {
    return <WordID>[
      for (LessonNumber number in lessons) ...(getLessonAllWords(number, pruneEditions: pruneEditions).map<WordID>((word) => word.id)),
    ];
  }

  /// Slices a [List] that is first shuffled, resulting in a new [List] being a random subset of the parent [List], containing [wordCount] elements.
  /// As you guessed from the parameters' names, this is designed to operate on word pools [List<Word>], though it will work for any type [T] of [List<T>].
  static List<T> stirGentlyThenDice<T>(List<T> pool, int wordCount) {
    // If `wordCount` is more than there are elements in the list, just return the whole thing
    final int sliceEnd = ((wordCount < pool.length) && wordCount != 0) ? wordCount : pool.length;

    final random = Random();
    final List<T> shuffledPool = List.from(pool)..shuffle(random);

    return shuffledPool.sublist(0, sliceEnd);
  }

  /// Final step of the recipe, combines [_getPoolFromLesson] and [stirGentlyThenDice] to create a random pool of [wordCount] words from [lessons].
  ///
  /// Season as desired, and serve immediately.
  List<Word> bakeWordPoolFromLessons(List<LessonNumber> lessons, {int wordCount = 0, bool pruneEditions = false}) {
    List<Word> pool = this._getPoolFromLesson(lessons, pruneEditions: pruneEditions);
    return DSInterface.stirGentlyThenDice(pool, wordCount);
  }

  /// Same as [bakeWordPoolFromLessons] minus the random aspect, since we're specifically looking for words with [WordID] in [idList] so we don't have to draw them at random.
  List<Word> bakeWordPoolFromID(List<WordID> idList) {
    return <Word>[for (int i = 0; i < idList.length; i++) this.fetchWordByID(idList[i])];
  }

  /// Returns currently supported languages in the dataset.
  ///
  /// Languages available in the dataset still have to be manually added to the app to function. This may change in the future.
  /// So for now this is just an illusion and this getter doesn't really do anything that we couldn't have hardcoded in the app.
  ///
  /// (but I like it that way anyway)
  List<DSLanguage> get getSupportedLanguages {
    Map<String, dynamic> languageMap = this.dataset[DSKeyring.LANGUAGES];

    List<DSLanguage> output = [];

    for (String key in languageMap.keys) {
      // ---> Add languages from the dataset here to enable them.
      switch (key) {
        case "en":
          output.add(DSLanguage.en);
        case "fr":
          output.add(DSLanguage.fr);
      }
    }

    return output;
  }
}
