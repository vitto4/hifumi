import "package:flutter/material.dart";

/// ̶B̶l̶a̶c̶k gray magic from Wikipedia — judge for yourself :
/// https://en.wikipedia.org/wiki/Grayscale#Luma_coding_in_video_systems
extension GrayScale on Color {
  double get luminance => (.299 * (this.r * 255) + .587 * (this.g * 255) + .144 * (this.b * 255));

  Color get grayScale => Color.fromARGB(
        (this.a * 255).toInt(),
        this.luminance.round(),
        this.luminance.round(),
        this.luminance.round(),
      );
}
