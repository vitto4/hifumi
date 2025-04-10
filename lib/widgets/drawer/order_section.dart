import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/archipelago/archipelago_barrel.dart";

/// Used only when the [IslandContainer] isn't in compact mode.
/// Otherwise, because of [smartExpand] and containers forcing tight constraints, this will be disregarded.
const double _ORDER_BUTTON_WIDTH = 190.0;

/// Quick settings section that allows users to configure the order in which words will be drawn in a review.
class DeckOrderSection extends StatefulWidget {
  final StorageInterface st;

  const DeckOrderSection({
    Key? key,
    required this.st,
  }) : super(key: key);

  @override
  State<DeckOrderSection> createState() => _DeckOrderSectionState();
}

class _DeckOrderSectionState extends State<DeckOrderSection> {
  late ReviewOrder _selectedOrder;

  @override
  void initState() {
    super.initState();
    _selectedOrder = widget.st.readReviewOrder();
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
              "Order",
              style: TextStyle(
                color: LightTheme.textColor,
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Order in which words will be drawn from the deck.\nDoes not apply to endless mode.",
              style: TextStyle(
                color: LightTheme.textColor,
                fontSize: FontSizes.base,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            IslandSegmentedSelector(
              leftBackgroundColor: _selectedOrder == ReviewOrder.insertion ? LightTheme.blueLighter : LightTheme.base,
              leftBorderColor: _selectedOrder == ReviewOrder.insertion ? LightTheme.blueLight : LightTheme.baseAccent,
              rightBackgroundColor: _selectedOrder == ReviewOrder.random ? LightTheme.blueLighter : LightTheme.base,
              rightBorderColor: _selectedOrder == ReviewOrder.random ? LightTheme.blueLight : LightTheme.baseAccent,
              compact: getDeckModeSegmentedSelectorCompactMode(context),
              onLeftTapped: () {
                widget.st.writeReviewOrder(ReviewOrder.insertion);
                setState(() {
                  _selectedOrder = ReviewOrder.insertion;
                });
              },
              onRightTapped: () {
                widget.st.writeReviewOrder(ReviewOrder.random);
                setState(() {
                  _selectedOrder = ReviewOrder.random;
                });
              },
              leftChild: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: SizedBox(
                  width: _ORDER_BUTTON_WIDTH,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Insertion",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedOrder == ReviewOrder.insertion ? LightTheme.blue : LightTheme.textColorDim,
                          fontSize: FontSizes.big,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Draw words in insertion order",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedOrder == ReviewOrder.insertion ? LightTheme.blue : LightTheme.textColorDimmer,
                          fontSize: FontSizes.base,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              rightChild: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: SizedBox(
                  width: _ORDER_BUTTON_WIDTH,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Random",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedOrder == ReviewOrder.random ? LightTheme.blue : LightTheme.textColorDim,
                          fontSize: FontSizes.big,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Draw words in random order",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedOrder == ReviewOrder.random ? LightTheme.blue : LightTheme.textColorDimmer,
                          fontSize: FontSizes.base,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
