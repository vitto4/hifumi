import "package:hifumi/abstractions/@data_code.dart";

/// Represents an edition of Minna no Nihongo.
/// So basically just a uselessly complicated [int].
enum Edition with HippityHoppityANumberYouShallBe {
  first(1, "First", "1st"),
  second(2, "Second", "2nd");

  const Edition(this.code, this.display, this.displayShort);

  final String display;
  final String displayShort;

  @override
  final int code;

  factory Edition.fromCode(int code) => switch (code) {
    1 => Edition.first,
    2 => Edition.second,
    _ => Edition.second,
  };
}

/// Represents a book of Minna no Nihongo.
/// TODO : Move to its own file ?
enum Book {
  one("One"),
  two("Two");

  const Book(this.display);

  final String display;
}
