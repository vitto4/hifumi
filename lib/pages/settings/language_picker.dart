import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/abstractions/ui/@screen_orientation.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/abstractions/@symbols.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";
import "package:hifumi/pages/quiz/card_pile/card_element.dart";

const double _LANGUAGE_TILE_VERTICAL_PADDING = 5.0;

/// The [LanguagePicker] is made of :
///   * [_TitleAndDescription]
///   * A set of clickable [_LanguageTile]
///   * A [_Demonstrator] to illustrate the effects of language selection
class LanguagePicker extends StatefulWidget {
  final SPInterface st;
  final DSInterface ds;
  final Function onDone;

  const LanguagePicker({
    Key? key,
    required this.st,
    required this.ds,
    required this.onDone,
  }) : super(key: key);

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  late final List<DSLanguage> languages;
  late final Word exampleWord;
  late DSLanguage selectedLanguage;

  @override
  void initState() {
    super.initState();
    languages = widget.ds.getSupportedLanguages;
    exampleWord = widget.ds.fetchWordByID([2, 10]);
    selectedLanguage = widget.st.readLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final bool landscape = getOrientation(context) == ScreenOrientation.landscape;

    return Scaffold(
      backgroundColor: LightTheme.base,
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: landscape ? .57 : .88,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    height: getPickersShrink(context) ? 500.0 : constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: Column(
                      children: <Widget>[
                        const Spacer(flex: 1),
                        SizedBox(
                          width: 300.0,
                          child: _Demonstrator(exampleWord: exampleWord, selectedLanguage: selectedLanguage),
                        ),
                        const Spacer(flex: 1),
                        const _TitleAndDescription(),
                        const SizedBox(height: 30.0),
                        SizedBox(
                          height: 152.0 + 2 * _LANGUAGE_TILE_VERTICAL_PADDING,
                          child: FlatIslandContainer(
                            backgroundColor: LightTheme.base,
                            borderColor: LightTheme.baseAccent,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          for (DSLanguage lang in languages) ...[
                                            _LanguageTile(
                                              isSelected: selectedLanguage == lang,
                                              language: lang,
                                              onTap: () => setState(
                                                () => selectedLanguage = lang,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),
                        IslandButton(
                          backgroundColor: LightTheme.green,
                          borderColor: LightTheme.greenBorder,
                          smartExpand: true,
                          onTap: () {
                            widget.st.writeLanguage(selectedLanguage);
                            widget.onDone.call();
                          },
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  fontSize: FontSizes.huge,
                                  fontWeight: FontWeight.bold,
                                  color: LightTheme.base,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleAndDescription extends StatelessWidget {
  const _TitleAndDescription({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Text(
            "Language selection",
            style: TextStyle(
              color: LightTheme.textColorDim,
              fontSize: FontSizes.huge,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 15.0),
        Text(
          "Select a display language for flashcards.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LightTheme.textColor,
            fontSize: FontSizes.base,
          ),
        ),
        SizedBox(height: 1.0),
        Text(
          "This will not affect the rest of the app.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LightTheme.textColor,
            fontSize: FontSizes.base,
          ),
        ),
      ],
    );
  }
}

class _Demonstrator extends StatelessWidget {
  final Word exampleWord;
  final DSLanguage selectedLanguage;

  const _Demonstrator({
    Key? key,
    required this.exampleWord,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatIslandContainer(
      backgroundColor: LightTheme.lightAccent,
      borderColor: LightTheme.baseAccent,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Transform.scale(
                scale: .8,
                child: CardElement(
                  title: "Kanji",
                  text: this.exampleWord.kanji,
                  symbols: Symbols.japanese,
                  textColor: LightTheme.textColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Transform.scale(
                scale: .8,
                child: CardElement(
                  title: "Meaning",
                  text: this.exampleWord.meaning[this.selectedLanguage]!,
                  textColor: LightTheme.textColor,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final bool isSelected;
  final DSLanguage language;
  final Function onTap;

  const _LanguageTile({
    Key? key,
    required this.isSelected,
    required this.language,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _LANGUAGE_TILE_VERTICAL_PADDING),
      child: IslandButton(
        smartExpand: true,
        onTap: this.onTap,
        backgroundColor: this.isSelected ? LightTheme.blueLighter : LightTheme.base,
        borderColor: this.isSelected ? LightTheme.blueLight : LightTheme.baseAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: <Widget>[
              const SizedBox(
                height: 50.0,
              ),
              Text(
                this.language.displayTranslated,
                style: TextStyle(
                  fontSize: FontSizes.huge,
                  fontWeight: FontWeight.bold,
                  color: this.isSelected ? LightTheme.blue : LightTheme.textColorDimmer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
