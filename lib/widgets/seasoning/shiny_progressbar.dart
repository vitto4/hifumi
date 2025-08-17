import "package:flutter/material.dart";
import "package:hifumi/abstractions/ui/themes.dart";

const double _PROGRESS_BAR_LR_PADDING = 15.0;

/// Shiny, yet deadly progress bar ! (with animated fill and rounded corners)
/// (yup you guessed it the design is also from the green owl website)
class ShinyProgressBar extends StatelessWidget {
  late final double _PROGRESS_BAR_RADIUS;
  late final double _PROGRESS_BAR_SHINE_PADDING;

  final double completionPercentage;
  final Color color;
  final double height;

  ShinyProgressBar({
    Key? key,
    required this.color,
    required this.completionPercentage,
    this.height = 10.0,
  }) : super(key: key) {
    this._PROGRESS_BAR_RADIUS = this.height / 2;
    this._PROGRESS_BAR_SHINE_PADDING = this.height / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_PROGRESS_BAR_LR_PADDING, .0, _PROGRESS_BAR_LR_PADDING, .0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: LightTheme.baseAccent,
              borderRadius: BorderRadius.circular(_PROGRESS_BAR_RADIUS),
            ),
            height: this.height,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                // Prevent weird constraint issues, I don't know why they occur, but hey, here's a fix
                width: (completionPercentage * width).isNaN ? null : completionPercentage * width,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(_PROGRESS_BAR_RADIUS),
                ),
                // Give it that shine !
                child: Align(
                  alignment: const Alignment(.0, -.3),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(_PROGRESS_BAR_SHINE_PADDING, .0, _PROGRESS_BAR_SHINE_PADDING, .0),
                    child: FractionallySizedBox(
                      heightFactor: .3,
                      child: Container(
                        decoration: BoxDecoration(
                          // .2 percent cooler !
                          color: Colors.white.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(_PROGRESS_BAR_RADIUS),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
