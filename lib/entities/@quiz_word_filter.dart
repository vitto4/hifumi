import "package:hifumi/entities/defaults.dart";
import "package:hifumi/entities/@data_code.dart";

/// Filters (applied when drawing cards)
enum QuizWordFilter with HippityHoppityANumberYouShallBe {
  none(1),
  mastered(2);

  const QuizWordFilter(this.code);

  @override
  final int code;

  factory QuizWordFilter.fromCode(int code) => switch (code) {
        1 => QuizWordFilter.none,
        2 => QuizWordFilter.mastered,
        _ => D.QUIZ_WORD_FILTER,
      };
}
