import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";
import "package:hifumi/widgets/casino/card_element.dart";

const double _BOOK_TILE_VERTICAL_PADDING = 5.0;

/// The [EditionPicker] is made of :
///   * [_TitleAndDescription]
///   * A set of clickable [_BookTile]
///   * A [_Demonstrator] to illustrate the effects of language selection
class EditionPicker extends StatefulWidget {
  final StorageInterface st;
  final Function onDone;

  const EditionPicker({
    Key? key,
    required this.st,
    required this.onDone,
  }) : super(key: key);

  @override
  State<EditionPicker> createState() => _EditionPickerState();
}

class _EditionPickerState extends State<EditionPicker> {
  late Edition selectedBookOne;
  late Edition selectedBookTwo;

  @override
  void initState() {
    super.initState();
    selectedBookOne = widget.st.readEdition(Book.one);
    selectedBookTwo = widget.st.readEdition(Book.two);
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
                      const SizedBox(
                        width: 300.0,
                        child: _Demonstrator(),
                      ),
                      const Spacer(flex: 1),
                      const _TitleAndDescription(),
                      const SizedBox(height: 30.0),
                      SizedBox(
                        height: 152.0 + 2 * _BOOK_TILE_VERTICAL_PADDING,
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
                                        _BookTile(
                                          book: Book.one,
                                          selectedEdition: selectedBookOne,
                                          onTap: () => setState(
                                            () => selectedBookOne = (selectedBookOne == Edition.first) ? Edition.second : Edition.first,
                                          ),
                                        ),
                                        _BookTile(
                                          book: Book.two,
                                          selectedEdition: selectedBookTwo,
                                          onTap: () => setState(
                                            () => selectedBookTwo = (selectedBookTwo == Edition.first) ? Edition.second : Edition.first,
                                          ),
                                        ),
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
                          widget.st.writeEdition(Book.one, selectedBookOne);
                          widget.st.writeEdition(Book.two, selectedBookTwo);
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Text(
            "Edition selection",
            style: TextStyle(
              color: LightTheme.textColorDim,
              fontSize: FontSizes.huge,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 15.0),
        Text(
          "Select your preferred edition for each book. The second edition should be suitable for most users.",
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
                child: const CardElement(
                  title: "First edition (年)",
                  text: "1998",
                  textColor: LightTheme.textColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Transform.scale(
                scale: .8,
                child: const CardElement(
                  title: "Second edition (年)",
                  text: "2012",
                  textColor: LightTheme.textColor,
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

class _BookTile extends StatelessWidget {
  final Book book;
  final Edition selectedEdition;
  final Function onTap;

  const _BookTile({
    Key? key,
    required this.book,
    required this.selectedEdition,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String lessonsCovered = this.book == Book.one ? "Lesson 01 to 25" : "Lesson 26 to 50";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _BOOK_TILE_VERTICAL_PADDING),
      child: IslandButton(
          smartExpand: true,
          onTap: this.onTap,
          backgroundColor: LightTheme.base,
          borderColor: LightTheme.baseAccent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  height: 50.0,
                ),
                Text(
                  this.selectedEdition.display,
                  style: TextStyle(
                      fontSize: FontSizes.huge,
                      fontWeight: FontWeight.bold,
                      color: this.selectedEdition == Edition.first ? LightTheme.brownLight : LightTheme.blue),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Book ${this.book.display}",
                      style: const TextStyle(fontSize: FontSizes.medium, fontWeight: FontWeight.bold, color: LightTheme.textColorDimmer),
                    ),
                    Text(
                      lessonsCovered,
                      style: TextStyle(fontSize: FontSizes.small, fontWeight: FontWeight.bold, color: LightTheme.textColorDimmer.withAlpha(180)),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
