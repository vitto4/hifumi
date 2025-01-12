import "package:flutter/material.dart";

/// Extension to darken a color by a given strength factor.
/// A strength of `1.0` leaves the color unchanged, while lower values darken it (and `.0` is just black).
///
/// https://github.com/flutter/flutter/issues/160184
extension Darken on Color {
  Color darken(double strength) => switch (this) {
        Colors.transparent => Colors.transparent.withAlpha(15),
        _ => Color.fromARGB(
            (this.a * 255).toInt(),
            ((this.r * 255) * strength).clamp(0, 255).toInt(),
            ((this.g * 255) * strength).clamp(0, 255).toInt(),
            ((this.b * 255) * strength).clamp(0, 255).toInt(),
          ),
      };
}
