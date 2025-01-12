import "package:hifumi/entities/defaults.dart";
import "package:hifumi/entities/@data_code.dart";

/// Order in which words will be drawn during a review
enum ReviewOrder with HippityHoppityANumberYouShallBe {
  insertion(1),
  random(2);

  const ReviewOrder(this.code);

  @override
  final int code;

  factory ReviewOrder.fromCode(int code) => switch (code) {
        1 => ReviewOrder.insertion,
        2 => ReviewOrder.random,
        _ => D.REVIEW_ORDER,
      };
}
