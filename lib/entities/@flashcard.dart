import "package:flutter/material.dart";
import "package:hifumi/widgets/casino/card_element.dart";
import "package:hifumi/entities/@word_id.dart";

/// Represents a flashcard as a set of properties and data.
class Flashcard {
  // These are display-related
  final Color color;
  final double angle;
  final Offset positionOffset;

  // And these (meta-)data shenanigans
  final WordID id;
  final String jishoURL;
  final List<CardElement> frontContent;
  final List<CardElement> backContent;

  const Flashcard({
    required this.color,
    required this.angle,
    required this.positionOffset,
    required this.id,
    required this.jishoURL,
    required this.frontContent,
    required this.backContent,
  });

  /// Useful when debugging
  @override
  String toString() {
    return "Flashcard{id: $id, jisho: $jishoURL}";
  }
}
