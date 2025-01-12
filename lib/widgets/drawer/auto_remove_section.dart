import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";

/// Quick settings section to select what deck to enable the auto-remove feature on.
/// This is another humdrum file, not much to see.
class AutoRemoveSection extends StatefulWidget {
  final StorageInterface st;

  const AutoRemoveSection({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  State<AutoRemoveSection> createState() => _AutoRemoveSectionState();
}

class _AutoRemoveSectionState extends State<AutoRemoveSection> {
  late bool one;
  late bool two;
  late bool three;

  @override
  void initState() {
    super.initState();
    one = widget.st.readDeckAutoRemove(Deck.one);
    two = widget.st.readDeckAutoRemove(Deck.two);
    three = widget.st.readDeckAutoRemove(Deck.three);
  }

  void onTapOne() {
    widget.st.writeDeckAutoRemove(Deck.one, !one);
    setState(() {
      one = !one;
    });
  }

  void onTapTwo() {
    widget.st.writeDeckAutoRemove(Deck.two, !two);
    setState(() {
      two = !two;
    });
  }

  void onTapThree() {
    widget.st.writeDeckAutoRemove(Deck.three, !three);
    setState(() {
      three = !three;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlatIslandContainer(
      backgroundColor: LightTheme.base,
      borderColor: LightTheme.baseAccent,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 15.0, 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Auto-remove",
                style: TextStyle(
                  color: LightTheme.textColor,
                  fontSize: FontSizes.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text.rich(TextSpan(
                text: "Automatically remove (",
                style: TextStyle(color: LightTheme.textColor),
                children: <InlineSpan>[
                  WidgetSpan(
                    child: Icon(Icons.layers_clear_rounded, color: LightTheme.textColorDim, size: FontSizes.medium),
                  ),
                  TextSpan(
                    text: ") words from the deck when answered correctly. An incorrect answer ",
                  ),
                  TextSpan(
                    text: "will not",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " (",
                  ),
                  WidgetSpan(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 1.5),
                        child: FaIcon(FontAwesomeIcons.shieldHalved, color: LightTheme.textColorDim, size: FontSizes.base)),
                  ),
                  TextSpan(
                    text: ") decrease the word's score.\n",
                  ),
                  WidgetSpan(
                    child: SizedBox(
                      height: 2 * FontSizes.base,
                    ),
                  ),
                  TextSpan(
                    text: "Note —",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: LightTheme.blue,
                    ),
                  ),
                  TextSpan(
                    text:
                        " This is intended to help you memorise exactly what you need without having to worry about making mistakes. Once the deck is empty, you're all set !",
                    style: TextStyle(
                      color: LightTheme.textColorDim,
                    ),
                  ),
                ],
              )),
              const SizedBox(
                height: 20.0,
              ),
              _Scaffold(
                one: IslandButton(
                  smartExpand: true,
                  backgroundColor: one ? LightTheme.blueLighter : LightTheme.base,
                  borderColor: one ? LightTheme.blueLight : LightTheme.baseAccent,
                  onTap: () => onTapOne.call(),
                  child: SizedBox(
                    width: 180.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      child: Column(children: <Widget>[
                        Text(
                          Deck.one.display,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSizes.huge,
                            fontWeight: FontWeight.bold,
                            color: one ? LightTheme.blue : LightTheme.textColorDim,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Enable on deck one",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSizes.base,
                            color: one ? LightTheme.blue : LightTheme.textColorDimmer,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                two: IslandButton(
                  smartExpand: true,
                  backgroundColor: two ? LightTheme.blueLighter : LightTheme.base,
                  borderColor: two ? LightTheme.blueLight : LightTheme.baseAccent,
                  onTap: () => onTapTwo.call(),
                  child: SizedBox(
                    width: 180.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      child: Column(children: <Widget>[
                        Text(
                          Deck.two.display,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSizes.huge,
                            fontWeight: FontWeight.bold,
                            color: two ? LightTheme.blue : LightTheme.textColorDim,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Enable on deck two",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSizes.base,
                            color: two ? LightTheme.blue : LightTheme.textColorDimmer,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                three: IslandButton(
                  smartExpand: true,
                  backgroundColor: three ? LightTheme.blueLighter : LightTheme.base,
                  borderColor: three ? LightTheme.blueLight : LightTheme.baseAccent,
                  onTap: () => onTapThree.call(),
                  child: SizedBox(
                    width: 180.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      child: Column(children: <Widget>[
                        Text(
                          Deck.three.display,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSizes.huge,
                            fontWeight: FontWeight.bold,
                            color: three ? LightTheme.blue : LightTheme.textColorDim,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Enable on deck three",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSizes.base,
                            color: three ? LightTheme.blue : LightTheme.textColorDimmer,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final Widget one;
  final Widget two;
  final Widget three;

  const _Scaffold({
    Key? key,
    required this.one,
    required this.two,
    required this.three,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool compact = getAutoRemoveSelectorCompactMode(context);

    return compact
        ? Column(children: <Widget>[
            one,
            const SizedBox(height: 8.0),
            two,
            const SizedBox(height: 8.0),
            three,
          ])
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              this.one,
              this.two,
              this.three,
            ],
          );
  }
}
