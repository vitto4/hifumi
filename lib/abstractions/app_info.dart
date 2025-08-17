/// Application metadata and constants.
///
/// I know this could (should ?) have been in the `pubspec.yaml`, but this way is so much easier, no async code and available with a simple import.
/// In the future, we may be able to use https://dart.dev/language/macros to alter this class at compile time.
class AppInfo {
  const AppInfo._();

  static const String name = "hifumi";
  static const String license = "MPL-2.0";

  static const String _repo = "https://github.com/vitto4/hifumi";

  static final Uri repoUrl = Uri.parse(_repo);
  static final Uri bugReportsUrl = Uri.parse("$_repo/issues");

  static final Uri dsUrl = Uri.parse("https://github.com/vitto4/MinnaNoDS");

  /// These will be updated during the build workflow (GitHub actions)
  static const String version = "missing-version";
  static const String commitHash = "missing-commit";
}
