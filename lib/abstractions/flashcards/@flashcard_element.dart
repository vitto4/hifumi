import "package:hifumi/abstractions/@data_code.dart";

/// Enum of all element types that may be displayed on either side of a flashcard, with their [code] for use in [shared_preferences]
enum FlashcardElementType with HippityHoppityANumberYouShallBe {
  kanji(1),
  kana(2),
  romaji(3),
  meaning(4);

  const FlashcardElementType(this.code);

  @override
  final int code;

  // To be consistent with the rest of the code, we should declare a `factory` here. However, it isn't needed for this class, so it is fine as is
}
