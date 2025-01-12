import "package:hifumi/entities/defaults.dart";
import "package:hifumi/entities/@data_code.dart";

/// List of languages supported by the dataset and available to the user.
/// This is *not* the app's display language (the app is only available in english for now)
enum DSLanguage with HippityHoppityANumberYouShallBe {
  // `<enum variant>.name` corresponds to ISO 639 language code.
  en(1, "English", "English"),
  fr(2, "French", "Français");

  const DSLanguage(this.code, this.display, this.displayTranslated);

  // These two are only for display purposes
  final String display;
  final String displayTranslated;

  @override
  final int code;

  factory DSLanguage.fromCode(int code) => switch (code) {
        1 => DSLanguage.en,
        2 => DSLanguage.fr,
        _ => D.LANGUAGE,
      };
}
