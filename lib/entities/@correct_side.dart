import "package:hifumi/entities/defaults.dart";
import "package:hifumi/entities/@data_code.dart";

/// Side which will count as correct when discarding a flashcard.
/// This can be changed by the user.
enum CorrectSide with HippityHoppityANumberYouShallBe {
  r(1, "Right"),
  l(2, "Left");

  const CorrectSide(this.code, this.display);

  final String display;

  @override
  final int code;

  // Bidirectional map at a cheap price ??
  // Satis-
  factory CorrectSide.fromCode(int code) => switch (code) {
        1 => CorrectSide.r,
        2 => CorrectSide.l,
        _ => D.CORRECT_SIDE,
      };
}
