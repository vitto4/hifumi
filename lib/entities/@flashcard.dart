import 'dart:math';
import "package:flutter/material.dart";
import "package:hifumi/widgets/casino/card_element.dart";
import "package:hifumi/entities/@word_id.dart";
import 'package:hifumi/entities/defaults.dart';

/// Represents a flashcard as a set of properties and data.
class Flashcard {
  // (meta-)data shenanigans
  final WordID id;
  final String jishoURL;
  final List<CardElement> frontContent;
  final List<CardElement> backContent;

  const Flashcard({
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

/// Same as a [Flashcard], but with style-related properties added.
class StyledFlashcard {
  final Flashcard flashcard;
  final Color color;
  final double angle;
  final Offset positionOffset;

  static Offset drawOffset() {
    final random = Random();
    return Offset((random.nextInt(D.CARD_OFFSET_MAX - D.CARD_OFFSET_MIN) - D.CARD_OFFSET_MAX).toDouble(),
        (random.nextInt(D.CARD_OFFSET_MAX - D.CARD_OFFSET_MIN) - D.CARD_OFFSET_MAX).toDouble());
  }

  const StyledFlashcard({
    required this.flashcard,
    required this.color,
    required this.angle,
    required this.positionOffset,
  });
}
