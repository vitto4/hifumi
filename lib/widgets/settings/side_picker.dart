import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";
import "package:flutter/material.dart";

const double _CORRECT_SIDE_TILE_VERTICAL_PADDING = 5.0;

/// The [CorrectSidePicker] is made of :
///   * [_TitleAndDescription]
///   * A set of clickable [_CorrectSideTile]
///   * A [_Demonstrator] to illustrate the effects of selecting a side
class CorrectSidePicker extends StatefulWidget {
  final StorageInterface st;
  final Function onDone;

  const CorrectSidePicker({
    Key? key,
    required this.st,
    required this.onDone,
  }) : super(key: key);

  @override
  State<CorrectSidePicker> createState() => _CorrectSidePickerState();
}

class _CorrectSidePickerState extends State<CorrectSidePicker> {
  late final List<CorrectSide> sides;
  late CorrectSide selectedSide;

  @override
  void initState() {
    super.initState();
    sides = [CorrectSide.r, CorrectSide.l];
    selectedSide = widget.st.readCorrectSide();
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
            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
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
                        child: _Demonstrator(selectedSide: selectedSide),
                      ),
                      const Spacer(flex: 1),
                      const _TitleAndDescription(),
                      const SizedBox(height: 30.0),
                      SizedBox(
                        height: 152.0 + 2 * _CORRECT_SIDE_TILE_VERTICAL_PADDING,
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
                                        for (CorrectSide side in sides) ...[
                                          _CorrectSideTile(
                                            isSelected: selectedSide == side,
                                            side: side,
                                            onTap: () => setState(
                                              () => selectedSide = side,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                )
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
                          widget.st.writeCorrectSide(selectedSide);
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
            }),
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
      children: <Widget>[
        Text(
          "Side selection",
          style: TextStyle(
            color: LightTheme.textColorDim,
            fontSize: FontSizes.huge,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.0),
        Text(
          "Select the side to mark flashcards as correct. This is where you should send the card when you know the word.",
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
  const _Demonstrator({
    Key? key,
    required this.selectedSide,
  }) : super(key: key);

  final CorrectSide selectedSide;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Left swipe",
                      style: TextStyle(fontSize: 15.0, color: LightTheme.textColor.withValues(alpha: .5)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
                      decoration: BoxDecoration(
                        color: selectedSide == CorrectSide.l ? LightTheme.green : LightTheme.red,
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(
                        selectedSide == CorrectSide.l ? "Correct" : "Incorrect",
                        style: const TextStyle(
                          color: LightTheme.base,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Transform.scale(
                scale: .8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Right swipe",
                      style: TextStyle(fontSize: 15.0, color: LightTheme.textColor.withValues(alpha: .5)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
                      decoration: BoxDecoration(
                        color: selectedSide == CorrectSide.r ? LightTheme.green : LightTheme.red,
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(
                        selectedSide == CorrectSide.r ? "Correct" : "Incorrect",
                        style: const TextStyle(
                          color: LightTheme.base,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10.0,
          )
        ],
      ),
    );
  }
}

class _CorrectSideTile extends StatelessWidget {
  final bool isSelected;
  final CorrectSide side;
  final Function onTap;

  const _CorrectSideTile({
    Key? key,
    required this.isSelected,
    required this.side,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _CORRECT_SIDE_TILE_VERTICAL_PADDING),
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
                this.side.display,
                style: TextStyle(
                    fontSize: FontSizes.huge, fontWeight: FontWeight.bold, color: this.isSelected ? LightTheme.blue : LightTheme.textColorDimmer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
