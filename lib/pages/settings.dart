import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/seasoning/app_logo.dart";
import "package:hifumi/pages/settings/edition_picker.dart";
import "package:hifumi/pages/settings/language_picker.dart";
import "package:hifumi/widgets/seasoning/snack_toast.dart";
import "package:hifumi/pages/settings/side_picker.dart";
import "package:hifumi/pages/credits.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:flutter_settings_ui/flutter_settings_ui.dart";
import "package:url_launcher/url_launcher.dart";

/// The settings page.
class Settings extends StatefulWidget {
  final SPInterface st;
  final DSInterface ds;

  const Settings({
    Key? key,
    required this.st,
    required this.ds,
  }) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late UserPrefs _settingsFields;
  final Color _activeSwitchColor = LightTheme.blueBorder;
  // Used to preserve state without having to read the language from shared [shared_preferences] when the user stays on this page.
  late DSLanguage _selectedLanguage;
  late Edition _selectedEditionBookOne;
  late Edition _selectedEditionBookTwo;
  late CorrectSide _selectedCorrectSide;
  late bool _performance;
  late bool _contrast;

  @override
  void initState() {
    super.initState();
    _settingsFields = widget.st.readUserPrefs();
    _selectedLanguage = _settingsFields.language;
    _selectedEditionBookOne = _settingsFields.editionBookOne;
    _selectedEditionBookTwo = _settingsFields.editionBookTwo;
    _selectedCorrectSide = _settingsFields.correctSide;
    _performance = _settingsFields.performance;
    _contrast = _settingsFields.contrast;
  }

  /// Since we need two of these (for the front and backside of the cards) I put the code in a helper function.
  /// * Relevant Decoding Flutter : https://www.youtube.com/watch?v=IOyq-eTRhvo
  SettingsSection _flashcardsSettings(bool front) {
    return SettingsSection(
      title: Text(
        'Flashcards – ${front ? "Front" : "Back"}',
        style: cmonApplyTheFontPlease.copyWith(color: LightTheme.blue, fontWeight: FontWeight.bold),
      ),
      tiles: <SettingsTile>[
        SettingsTile.switchTile(
          activeSwitchColor: _activeSwitchColor,
          onToggle: (value) {
            widget.st.writeFlashcardPrefs(FlashcardElementType.kanji, front, value);
            setState(() {
              front
                  ? _settingsFields.cardFrontKanji = !(_settingsFields.cardFrontKanji)
                  : _settingsFields.cardBackKanji = !(_settingsFields.cardBackKanji);
            });
          },
          initialValue: front ? _settingsFields.cardFrontKanji : _settingsFields.cardBackKanji,
          leading: const Text(
            "字",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: LightTheme.textColorDim,
              fontSize: 23,
              fontFamily: "NewTegomin",
            ),
          ),
          title: const Text('Kanji', style: cmonApplyTheFontPlease),
        ),
        SettingsTile.switchTile(
          activeSwitchColor: _activeSwitchColor,
          onToggle: (value) {
            widget.st.writeFlashcardPrefs(FlashcardElementType.kana, front, value);
            setState(() {
              front
                  ? _settingsFields.cardFrontKana = !(_settingsFields.cardFrontKana)
                  : _settingsFields.cardBackKana = !(_settingsFields.cardBackKana);
            });
          },
          initialValue: front ? _settingsFields.cardFrontKana : _settingsFields.cardBackKana,
          leading: const Text(
            "あ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: LightTheme.textColorDim,
              fontSize: 23,
              fontFamily: "NotoSerifJP",
            ),
          ),
          title: const Text('Kana', style: cmonApplyTheFontPlease),
        ),
        SettingsTile.switchTile(
          activeSwitchColor: _activeSwitchColor,
          onToggle: (value) {
            widget.st.writeFlashcardPrefs(FlashcardElementType.romaji, front, value);
            setState(() {
              front
                  ? _settingsFields.cardFrontRomaji = !(_settingsFields.cardFrontRomaji)
                  : _settingsFields.cardBackRomaji = !(_settingsFields.cardBackRomaji);
            });
          },
          initialValue: front ? _settingsFields.cardFrontRomaji : _settingsFields.cardBackRomaji,
          leading: const Icon(Icons.font_download),
          title: const Text('Rōmaji', style: cmonApplyTheFontPlease),
        ),
        SettingsTile.switchTile(
          activeSwitchColor: _activeSwitchColor,
          onToggle: (value) {
            widget.st.writeFlashcardPrefs(FlashcardElementType.meaning, front, value);
            setState(() {
              front
                  ? _settingsFields.cardFrontMeaning = !(_settingsFields.cardFrontMeaning)
                  : _settingsFields.cardBackMeaning = !(_settingsFields.cardBackMeaning);
            });
          },
          initialValue: front ? _settingsFields.cardFrontMeaning : _settingsFields.cardBackMeaning,
          leading: const Icon(Icons.translate),
          title: const Text('Meaning', style: cmonApplyTheFontPlease),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LightTheme.base,
        title: const Text(
          "Settings",
          style: TextStyle(color: LightTheme.textColorDim, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SettingsList(
        platform: DevicePlatform.android,
        lightTheme: themeData,
        darkTheme: themeData,
        sections: [
          SettingsSection(
            title: Text(
              'Common',
              style: cmonApplyTheFontPlease.copyWith(color: LightTheme.blue, fontWeight: FontWeight.bold),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language', style: cmonApplyTheFontPlease),
                value: Text(_selectedLanguage.displayTranslated),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LanguagePicker(
                        st: widget.st,
                        ds: widget.ds,
                        onDone: () {
                          setState(
                            () {
                              _selectedLanguage = widget.st.readLanguage();
                            },
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      barrierDismissible: true,
                    ),
                  );
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.check_box_rounded),
                title: const Text('Side', style: cmonApplyTheFontPlease),
                value: Text(_selectedCorrectSide.display, style: cmonApplyTheFontPlease),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CorrectSidePicker(
                        st: widget.st,
                        onDone: () {
                          setState(
                            () {
                              _selectedCorrectSide = widget.st.readCorrectSide();
                            },
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      barrierDismissible: true,
                    ),
                  );
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.new_label),
                title: const Text('Edition', style: cmonApplyTheFontPlease),
                value: const Text("Configure the edition for each book", style: cmonApplyTheFontPlease),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditionPicker(
                        st: widget.st,
                        onDone: () {
                          Navigator.of(context).pushNamedAndRemoveUntil("/", (Route<dynamic> _) => false);
                        },
                      ),
                      barrierDismissible: true,
                    ),
                  );
                },
              ),
              SettingsTile.switchTile(
                activeSwitchColor: _activeSwitchColor,
                onToggle: (value) {
                  setState(
                    () {
                      widget.st.writePerformanceMode(value);
                      _performance = value;
                    },
                  );
                },
                initialValue: _performance,
                leading: Transform.scale(scale: 1.2, child: const Icon(Icons.bolt_rounded)),
                title: const Text("Performance mode", style: cmonApplyTheFontPlease),
                description: const Text("Reduce the number of flashcards rendered at once", style: cmonApplyTheFontPlease),
              ),
              SettingsTile.switchTile(
                activeSwitchColor: _activeSwitchColor,
                onToggle: (value) {
                  setState(
                    () {
                      widget.st.writeHighContrastMode(value);
                      _contrast = value;
                    },
                  );
                },
                initialValue: _contrast,
                leading: const Icon(Icons.contrast),
                title: const Text("High contrast", style: cmonApplyTheFontPlease),
                description: const Text("Remove lower-contrast flashcard colors", style: cmonApplyTheFontPlease),
              ),
            ],
          ),
          _flashcardsSettings(true),
          _flashcardsSettings(false),
          SettingsSection(
            title: Text(
              'Data',
              style: cmonApplyTheFontPlease.copyWith(color: LightTheme.blue, fontWeight: FontWeight.bold),
            ),
            tiles: <AbstractSettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.cloud_upload_rounded),
                title: const Text("Import", style: cmonApplyTheFontPlease),
                value: const Text("Import your progress from a file", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  await widget.st.importFromFile(widget.ds)
                      ? Navigator.of(context).pushNamedAndRemoveUntil("/", (Route<dynamic> _) => false)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          SnackToast.bar(text: "Could not read the file"),
                        );
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.cloud_download_rounded),
                title: const Text("Export", style: cmonApplyTheFontPlease),
                value: const Text("Export your progress to a file", style: cmonApplyTheFontPlease),
                onPressed: (context) {
                  widget.st.dumpToJSON();
                },
              ),
              CustomSettingsTile(child: _ResetSettingsTile(st: widget.st)),
            ],
          ),
          SettingsSection(
            title: Text(
              'About',
              style: cmonApplyTheFontPlease.copyWith(color: LightTheme.blue, fontWeight: FontWeight.bold),
            ),
            tiles: <AbstractSettingsTile>[
              CustomSettingsTile(
                child: _VersionSettingsTile(),
              ),
              SettingsTile.navigation(
                leading: Transform.scale(scale: 1.25, child: const Icon(Icons.bug_report_rounded)),
                title: const Text("Bugs", style: cmonApplyTheFontPlease),
                value: const Text("Found one ? Report it here !", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  if (await canLaunchUrl(AppInfo.bugReportsUrl)) {
                    await launchUrl(AppInfo.bugReportsUrl);
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const FaIcon(FontAwesomeIcons.github),
                title: const Text("Code", style: cmonApplyTheFontPlease),
                value: const Text("Released under ${AppInfo.license}", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  if (await canLaunchUrl(AppInfo.repoUrl)) {
                    await launchUrl(AppInfo.repoUrl);
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const FaIcon(FontAwesomeIcons.database),
                title: const Text("Dataset", style: cmonApplyTheFontPlease),
                value: const Text("Available on GitHub", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  if (await canLaunchUrl(AppInfo.dsUrl)) {
                    await launchUrl(AppInfo.dsUrl);
                  }
                },
              ),
              SettingsTile.navigation(
                // Icons.feed_rounded
                leading: const Icon(Icons.dashboard_customize),
                title: const Text("Libraries", style: cmonApplyTheFontPlease),
                value: const Text("List and open-source licenses", style: cmonApplyTheFontPlease),
                onPressed: (context) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const LicensePage(
                        applicationVersion: "${AppInfo.version}+${AppInfo.commitHash}",
                        applicationIcon: AppLogo(),
                        applicationLegalese: "Released under ${AppInfo.license}",
                      ),
                      barrierDismissible: true,
                    ),
                  );
                },
              ),
              SettingsTile(
                // Icons.menu_book
                leading: const Icon(Icons.receipt),
                title: const Text("Credits", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Credits(),
                      barrierDismissible: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Special [SettingsTile] that changes color when tapped, and trigger if a second tap happens soon enough.
class _ResetSettingsTile extends StatefulWidget {
  final SPInterface st;

  const _ResetSettingsTile({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  State<_ResetSettingsTile> createState() => _ResetSettingsTileState();
}

class _ResetSettingsTileState extends State<_ResetSettingsTile> {
  late int _pressedHowManyTimes;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pressedHowManyTimes = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tapHandler() {
    if (_pressedHowManyTimes == 0) {
      setState(() {
        _pressedHowManyTimes = 1;
      });
      // Timer duration can be changed here
      _timer = Timer(const Duration(seconds: 5), () {
        setState(() {
          _pressedHowManyTimes = 0;
        });
      });
    } else if (_pressedHowManyTimes == 1) {
      _onSecondTap.call();
      setState(() {
        _pressedHowManyTimes = 0;
      });
      _timer?.cancel();
    }
  }

  void _onSecondTap() {
    widget.st.clearData();
    Navigator.of(context).pushNamedAndRemoveUntil(
      "/",
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool warn = _pressedHowManyTimes == 1;

    return SettingsTile(
      leading: warn
          ? Text(
              "(；'-' )",
              style: TextStyle(
                color: LightTheme.base.withValues(alpha: .4),
                fontWeight: FontWeight.bold,
                fontSize: FontSizes.big,
              ),
            )
          : Transform.scale(scale: 1.3, child: const Icon(Icons.rotate_left_rounded)),
      title: warn
          ? Text(
              "Reset ?",
              style: cmonApplyTheFontPlease.copyWith(
                color: LightTheme.base,
                fontWeight: FontWeight.bold,
              ),
            )
          : const Text("Reset", style: cmonApplyTheFontPlease),
      value: warn
          ? Text(
              "This cannot be undone",
              style: cmonApplyTheFontPlease.copyWith(
                color: LightTheme.base,
              ),
            )
          : const Text("Reset your progress", style: cmonApplyTheFontPlease),
      backgroundColor: warn ? LightTheme.redLight : null,
      onPressed: (_) => _tapHandler.call(),
    );
  }
}

/// Special [SettingsTile] do display the version of the app.
/// When moused over, will reveal the commit hash of the build.
class _VersionSettingsTile extends StatefulWidget {
  const _VersionSettingsTile({
    Key? key,
  }) : super(key: key);

  @override
  State<_VersionSettingsTile> createState() => _VersionSettingsTileState();
}

class _VersionSettingsTileState extends State<_VersionSettingsTile> {
  bool _dispAltText = false;

  @override
  Widget build(BuildContext context) {
    final SettingsTile stack = SettingsTile(
      leading: SizedBox(
        height: 24.0,
        width: 24.0,
        child: Transform.scale(scale: .9, child: const FaIcon(FontAwesomeIcons.codeCommit)),
      ),
      title: const Text("Version", style: cmonApplyTheFontPlease),
      value: Text(_dispAltText ? "${AppInfo.version}+${AppInfo.commitHash}" : AppInfo.version, style: cmonApplyTheFontPlease),
    );

    return (kIsWeb)
        ? MouseRegion(
            onEnter: (event) => setState(() {
              _dispAltText = true;
            }),
            onExit: (event) => setState(() {
              _dispAltText = false;
            }),
            child: stack,
          )
        : Listener(
            onPointerDown: (event) => setState(() {
              _dispAltText = true;
            }),
            onPointerUp: (event) => setState(() {
              _dispAltText = false;
            }),
            child: stack,
          );
  }
}

SettingsThemeData themeData = const SettingsThemeData(
  settingsListBackground: LightTheme.base,
  settingsSectionBackground: LightTheme.base,
  tileHighlightColor: LightTheme.baseAccent,
  tileDescriptionTextColor: LightTheme.textColorDimmer,
  settingsTileTextColor: LightTheme.textColorDim,
  titleTextColor: LightTheme.textColor,
  leadingIconsColor: LightTheme.textColorDim,
  dividerColor: LightTheme.baseAccent,
);

const TextStyle cmonApplyTheFontPlease = TextStyle(
  fontFamily: "Varela Round",
);
