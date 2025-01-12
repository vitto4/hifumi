import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/widgets/archipelago/island_container.dart";
import "package:hifumi/widgets/seasoning/shiny_progressbar.dart";

/// Looks pretty sleek–
/// ̶l̶i̶k̶e̶ ̶t̶h̶i̶s̶ ̶s̶e̶g̶u̶e̶,̶ ̶t̶o̶ ̶o̶u̶r̶ ̶s̶p̶o̶n̶s̶o̶r̶.
class QuizTopBar extends StatelessWidget {
  final double percentage;
  final String source;

  const QuizTopBar({
    Key? key,
    required this.percentage,
    required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 3.0, 16.0, .0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: LightTheme.darkAccent,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ShinyProgressBar(
                color: LightTheme.green,
                completionPercentage: this.percentage,
                height: 16.0,
              ),
            ),
          ),
          FlatIslandContainer(
            backgroundColor: LightTheme.purpleLight,
            borderColor: LightTheme.purple,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 3.0, 12.0, 3.0),
              child: Text(
                this.source,
                style: const TextStyle(
                  fontSize: FontSizes.base,
                  fontWeight: FontWeight.bold,
                  color: LightTheme.purple,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
