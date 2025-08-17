import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";
import "package:hifumi/widgets/archipelago/island_container.dart";

/// It's really not all that useful, and what's more it's only shown for a split second (as is the whole loading screen).
/// But it looks cool, and I know it's there :)
///
/// Console-style widget placed on the loading screen to print out updates on the loading progress.
/// Adds a checkmark to completed steps.
class ConsoleWidget extends StatefulWidget {
  final String? initialMessage;

  const ConsoleWidget({
    Key? key,
    this.initialMessage,
  }) : super(key: key);

  @override
  ConsoleWidgetState createState() => ConsoleWidgetState();
}

class ConsoleWidgetState extends State<ConsoleWidget> {
  late final List<String> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      if (widget.initialMessage is String) widget.initialMessage!,
    ];
  }

  void printMessage(String message) {
    setState(() {
      _messages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.0,
      child: FlatIslandContainer(
        backgroundColor: LightTheme.lightAccent,
        borderColor: LightTheme.baseAccent,
        child: Container(
          // I don't know what that was for, but I was definitely cooking something
          // Edit : 10.0 is vertical padding, the rest is four lines of text + padding
          height: 4 * (FontSizes.medium + 5) + 2.0 * 10.0,
          padding: const EdgeInsets.all(10.0),
          // Just to make sure a potential overflow doesn't throw any error
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _messages.length; i++)
                  if (i != _messages.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            _messages[i],
                            style: const TextStyle(
                              color: LightTheme.textColorDim,
                              fontSize: FontSizes.small,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.check,
                            color: LightTheme.green,
                            size: FontSizes.small,
                          ),
                        ],
                      ),
                    )
                  /// If it's the last line and not empty, add trailing `...`.
                  /// If it's empty, then it will not get displayed, but the line before it will still receive its longed-for check mark.
                  else if (_messages[i] != "")
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            _messages[i],
                            style: const TextStyle(
                              color: LightTheme.textColorDim,
                              fontSize: FontSizes.small,
                            ),
                          ),
                          const Text(
                            "...",
                            style: TextStyle(
                              color: LightTheme.textColorDim,
                              fontSize: FontSizes.small,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
