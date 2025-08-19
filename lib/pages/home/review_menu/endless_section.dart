import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";

const double _ENDLESS_SECTION_BUTTON_WIDTH = 190.0;

/// Quick settings section for everything endless mode.
/// This is another humdrum file, not much to see.
class EndlessModeSection extends StatefulWidget {
  final SPInterface st;

  const EndlessModeSection({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  State<EndlessModeSection> createState() => _EndlessModeSectionState();
}

class _EndlessModeSectionState extends State<EndlessModeSection> {
  late bool _endlessMode;
  late bool _autoRemove;

  @override
  void initState() {
    super.initState();
    _endlessMode = widget.st.readReviewEndlessMode();
    _autoRemove = widget.st.readEndlessAutoRemove();
  }

  void _onTapEndless() {
    widget.st.writeReviewEndlessMode(!_endlessMode);
    setState(() {
      _endlessMode = !_endlessMode;
    });
  }

  void _onTapAutoRemove() {
    widget.st.writeEndlessAutoRemove(!_autoRemove);
    setState(() {
      _autoRemove = !_autoRemove;
    });
  }

  @override
  Widget build(BuildContext context) {
    Padding autoremoveButtonContents = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: SizedBox(
        width: _ENDLESS_SECTION_BUTTON_WIDTH,
        child: Column(
          children: <Widget>[
            Text(
              "Auto-remove",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontSizes.big,
                fontWeight: FontWeight.bold,
                color: _endlessMode
                    ? _autoRemove
                          ? LightTheme.blue
                          : LightTheme.textColorDim
                    : _autoRemove
                    ? LightTheme.textColorDim.withAlpha(130)
                    : LightTheme.textColorDim.withAlpha(70),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "Enable for endless reviews",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontSizes.base,
                color: _endlessMode
                    ? _autoRemove
                          ? LightTheme.blue
                          : LightTheme.textColorDimmer
                    : _autoRemove
                    ? LightTheme.textColorDimmer.withAlpha(130)
                    : LightTheme.textColorDimmer.withAlpha(70),
              ),
            ),
          ],
        ),
      ),
    );

    return FlatIslandContainer(
      backgroundColor: LightTheme.base,
      borderColor: LightTheme.baseAccent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 15.0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Endless mode",
              style: TextStyle(
                color: LightTheme.textColor,
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text.rich(
              TextSpan(
                text: "Keeps the review going so long as each word from the deck hasn't been answered correctly. Incorrect answers ",
                style: TextStyle(color: LightTheme.textColor),
                children: <InlineSpan>[
                  TextSpan(
                    text: "do not",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " decrease words' scores.\n"),
                  TextSpan(
                    text: "Auto-remove",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // color: LightTheme.blue,
                    ),
                  ),
                  TextSpan(
                    text: ": remove (",
                  ),
                  WidgetSpan(
                    child: Icon(Icons.layers_clear_rounded, color: LightTheme.textColorDim, size: FontSizes.medium),
                  ),
                  TextSpan(
                    text: ") words from the deck when answered correctly. Incorrect answers leave the deck unchanged (",
                  ),
                  WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 1.5),
                      child: FaIcon(FontAwesomeIcons.shieldHalved, color: LightTheme.textColorDim, size: FontSizes.base),
                    ),
                  ),
                  TextSpan(
                    text: ").",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            _Scaffold(
              endless: IslandButton(
                smartExpand: true,
                backgroundColor: _endlessMode ? LightTheme.blueLighter : LightTheme.base,
                borderColor: _endlessMode ? LightTheme.blueLight : LightTheme.baseAccent,
                onTap: () => _onTapEndless.call(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  child: SizedBox(
                    width: _ENDLESS_SECTION_BUTTON_WIDTH,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Endless mode",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSizes.big,
                            fontWeight: FontWeight.bold,
                            color: _endlessMode ? LightTheme.blue : LightTheme.textColorDim,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Reviews will be endless",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSizes.base,
                            color: _endlessMode ? LightTheme.blue : LightTheme.textColorDimmer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              autoRemove: _endlessMode
                  ? IslandButton(
                      smartExpand: true,
                      backgroundColor: _autoRemove ? LightTheme.blueLighter : LightTheme.base,
                      borderColor: _autoRemove ? LightTheme.blueLight : LightTheme.baseAccent,
                      onTap: () => _onTapAutoRemove.call(),
                      child: autoremoveButtonContents,
                    )
                  : IslandContainer(
                      smartExpand: true,
                      tapped: true,
                      backgroundColor: _autoRemove ? LightTheme.lightAccent : LightTheme.base,
                      borderColor: _autoRemove ? LightTheme.baseAccent : LightTheme.baseAccent.withAlpha(70),
                      child: autoremoveButtonContents,
                    ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text.rich(
              TextSpan(
                style: TextStyle(color: LightTheme.textColor),
                children: <InlineSpan>[
                  TextSpan(
                    text: "Note —",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: LightTheme.blue,
                    ),
                  ),
                  TextSpan(
                    text:
                        " This is intended to help you quickly memorise exactly what you need and without having to worry about making mistakes. Once you reach the end of the quiz, you're all set !",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final Widget endless;
  final Widget autoRemove;

  const _Scaffold({
    Key? key,
    required this.endless,
    required this.autoRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool compact = getEndlessSelectorCompactMode(context);

    return compact
        ? Column(
            children: <Widget>[
              endless,
              const SizedBox(height: 8.0),
              autoRemove,
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              this.endless,
              this.autoRemove,
            ],
          );
  }
}
