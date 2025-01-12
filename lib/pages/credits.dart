import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/pages/settings.dart";
import "package:flutter_settings_ui/flutter_settings_ui.dart";
import "package:url_launcher/url_launcher.dart";

final Uri _shots = Uri.parse("https://github.com/ninest/Shots");
final Uri _duolingo = Uri.parse("https://www.duolingo.com");
final Uri _3A = Uri.parse("https://www.3anet.co.jp/en/");
final Uri _denisowski = Uri.parse("http://www.denisowski.org/Japanese/Japanese.html");
final Uri _valera = Uri.parse("https://fonts.google.com/specimen/Varela+Round");
final Uri _notoSansDisplay = Uri.parse("https://fonts.google.com/noto/specimen/Noto+Sans+Display");
final Uri _notoSansJP = Uri.parse("https://fonts.google.com/noto/specimen/Noto+Sans+JP");
final Uri _notoSerifJP = Uri.parse("https://fonts.google.com/noto/specimen/Noto+Serif+JP");
final Uri _newTegomin = Uri.parse("https://fonts.google.com/specimen/New+Tegomin");
final Uri _minnaNoFlashcards = Uri.parse("https://play.google.com/store/apps/details?id=com.factory201.minnanoflashcards");
// I know `Minna No Flashcards` has been pulled from the play store, but I can't find any other relevant link, so I'll leave it like this

class Credits extends StatelessWidget {
  const Credits({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LightTheme.base,
        title: const Text(
          "Credits",
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
          const SettingsSection(
            tiles: [
              CustomSettingsTile(
                child: Kudos(),
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'Design',
              style: cmonApplyTheFontPlease.copyWith(color: LightTheme.blue, fontWeight: FontWeight.bold),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const CardsIcon(),
                title: const Text("Flashcards", style: cmonApplyTheFontPlease),
                value: const Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: "Design inspired by ",
                      ),
                      TextSpan(
                        text: "ninest / Shots",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: cmonApplyTheFontPlease,
                ),
                onPressed: (context) async {
                  if (await canLaunchUrl(_shots)) {
                    await launchUrl(_shots);
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.color_lens),
                title: const Text("Color palette", style: cmonApplyTheFontPlease),
                value: const Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: "Primarily drawn from ",
                      ),
                      TextSpan(
                        text: "Duolingo",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: cmonApplyTheFontPlease,
                  softWrap: true,
                ),
                onPressed: (context) async {
                  if (await canLaunchUrl(_duolingo)) {
                    await launchUrl(_duolingo);
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.design_services),
                title: const Text("Design language", style: cmonApplyTheFontPlease),
                value: const Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: "Influenced by ",
                      ),
                      TextSpan(
                        text: "Duolingo",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: cmonApplyTheFontPlease,
                ),
                onPressed: (context) async {
                  if (await canLaunchUrl(_duolingo)) {
                    await launchUrl(_duolingo);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'Data',
              style: cmonApplyTheFontPlease.copyWith(color: LightTheme.blue, fontWeight: FontWeight.bold),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.text_fields_rounded),
                title: const Text("Lexicon", style: cmonApplyTheFontPlease),
                value: const Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: "Words and translations from ",
                      ),
                      TextSpan(
                        text: "みんなの日本語 Ⅰ & Ⅱ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "　© 3A Corporation",
                      ),
                    ],
                  ),
                  style: cmonApplyTheFontPlease,
                ),
                onPressed: (context) async {
                  if (await canLaunchUrl(_3A)) {
                    await launchUrl(_3A);
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.data_array),
                title: const Text("Source", style: cmonApplyTheFontPlease),
                value: const Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: "Expanding on ",
                      ),
                      TextSpan(
                        text: "Paul Denisowski",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "'s English みんなの日本語 vocabulary list",
                      ),
                    ],
                  ),
                  style: cmonApplyTheFontPlease,
                ),
                onPressed: (context) async {
                  if (await canLaunchUrl(_denisowski)) {
                    await launchUrl(_denisowski);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'Fonts',
              style: cmonApplyTheFontPlease.copyWith(color: LightTheme.blue, fontWeight: FontWeight.bold),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const SizedBox(
                  height: 24.0,
                  width: 24.0,
                  child: Text(
                    "Aa",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                      fontSize: 19,
                      fontFamily: "Valera Round",
                    ),
                  ),
                ),
                title: const Text("Valera Round", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  if (await canLaunchUrl(_valera)) {
                    await launchUrl(_valera);
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const SizedBox(
                  height: 24.0,
                  width: 24.0,
                  child: Text(
                    "Aa",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                      fontSize: 19,
                      fontFamily: "NotoSansDisplay",
                    ),
                  ),
                ),
                title: const Text("Noto Sans Display", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  if (await canLaunchUrl(_notoSansDisplay)) {
                    await launchUrl(_notoSansDisplay);
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const Text(
                  "あ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: LightTheme.textColorDim,
                    fontSize: 23,
                    fontFamily: "NotoSansJP",
                  ),
                ),
                title: const Text("Noto Sans JP", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  if (await canLaunchUrl(_notoSansJP)) {
                    await launchUrl(_notoSansJP);
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const Text(
                  "あ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: LightTheme.textColorDim,
                    fontSize: 23,
                    fontFamily: "NotoSerifJP",
                  ),
                ),
                title: const Text("Noto Serif JP", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  if (await canLaunchUrl(_notoSerifJP)) {
                    await launchUrl(_notoSerifJP);
                  }
                },
              ),
              SettingsTile.navigation(
                leading: Transform.scale(
                  scale: 1.20,
                  child: const Text(
                    "あ",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                      fontSize: 23,
                      fontFamily: "NewTegomin",
                    ),
                  ),
                ),
                title: const Text("New Tegomin", style: cmonApplyTheFontPlease),
                onPressed: (context) async {
                  if (await canLaunchUrl(_newTegomin)) {
                    await launchUrl(_newTegomin);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'Other',
              style: cmonApplyTheFontPlease.copyWith(color: LightTheme.blue, fontWeight: FontWeight.bold),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.light_rounded),
                title: const Text("Concept", style: cmonApplyTheFontPlease),
                value: const Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: "Adapted from ",
                      ),
                      TextSpan(
                        text: "Minna No Flashcards",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: " by 201 Factory",
                      ),
                    ],
                  ),
                  style: cmonApplyTheFontPlease,
                ),
                onPressed: (context) async {
                  if (await canLaunchUrl(_minnaNoFlashcards)) {
                    await launchUrl(_minnaNoFlashcards);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Kudos extends StatefulWidget {
  const Kudos({
    Key? key,
  }) : super(key: key);

  @override
  State<Kudos> createState() => _KudosState();
}

class _KudosState extends State<Kudos> {
  bool _dispAltText = false;

  @override
  Widget build(BuildContext context) {
    const String text = "Kudos to everyone involved in the following projects";
    const String altText = "(*ᵕᴗᵕㅅ)";

    final Stack stack = Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Opacity(
          opacity: _dispAltText ? .0 : 1.0,
          child: Text(
            text,
            style: cmonApplyTheFontPlease.copyWith(color: LightTheme.textColorDimmer),
          ),
        ),
        Opacity(
          opacity: !_dispAltText ? .0 : 1.0,
          child: const Text(
            altText,
            style: TextStyle(fontFamily: "NotoSansDisplay", color: LightTheme.textColorDimmer),
          ),
        ),
      ],
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: (kIsWeb)
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
              ),
      ),
    );
  }
}

class CardsIcon extends StatelessWidget {
  const CardsIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.0,
      width: 24.0,
      child: Stack(
        children: <Widget>[
          Transform.translate(
            offset: const Offset(8.0, .0),
            child: Transform.rotate(
              angle: .3,
              child: Container(
                width: 14.0,
                height: 21.0,
                decoration: BoxDecoration(
                  color: themeData.leadingIconsColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(-2.0, -1.0),
            child: Transform.rotate(
              angle: -.17,
              child: Container(
                width: 14.0 + 1.3,
                height: 21.0 + 1.3,
                decoration: BoxDecoration(
                  color: themeData.leadingIconsColor,
                  borderRadius: BorderRadius.circular(4.0),
                  border: const Border(
                    right: BorderSide(
                      color: LightTheme.base,
                      width: 1.3,
                    ),
                    bottom: BorderSide(
                      color: LightTheme.base,
                      width: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
