import "package:hifumi/abstractions/dataset/@ds_language.dart";
import "package:hifumi/abstractions/dataset/ds_keyring.dart";
import "package:hifumi/abstractions/dataset/@word_id.dart";
import "package:hifumi/abstractions/dataset/@edition.dart";

/// Raw word data from the YAML dataset, before conversion to [Word] class.
typedef WordYAML = Map<String, dynamic>;

/// Represents a single word entry from the dataset in a structured format, easier to work with than [WordYAML)].
class Word {
  late final WordID id;
  late final List<Edition> edition;
  late final String withKanji;
  late final String kana;
  late final String romaji;
  late final Map<DSLanguage, String> meaning;
  late final bool hasKanji;

  Word({
    required WordYAML wordYAML,
    required List<DSLanguage> supportedLanguages,
  }) {
    this.id = (wordYAML[DSKeyring.WORD_ID] as List<dynamic>).map((e) => e as int).toList();
    this.edition = (wordYAML[DSKeyring.WORD_EDITION] as List<dynamic>).map((e) => Edition.fromCode((e as int))).toList();
    // Defaults to the kana version
    this.withKanji = wordYAML[DSKeyring.WORD_KANJI] ?? wordYAML[DSKeyring.WORD_KANA];
    this.kana = wordYAML[DSKeyring.WORD_KANA];
    this.romaji = wordYAML[DSKeyring.WORD_ROMAJI];
    // Map a meaning to each supported language. Retrieval of `[DSKeyring.WORD_MEANING][lang.name]` shouldn't fail because we (kinda) fetched [supportedLanguages] straight from the DS.
    this.meaning = {for (DSLanguage lang in supportedLanguages) lang: wordYAML[DSKeyring.WORD_MEANING][lang.name] ?? "placeholder"};
    this.hasKanji = wordYAML[DSKeyring.WORD_KANJI] is String;
  }

  @override
  String toString() {
    return "Word{id: $id, kanji: $withKanji, kana: $kana, romaji: $romaji, meaning: $meaning}";
  }
}
