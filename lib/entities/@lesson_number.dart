/// Each lesson is identified by its own [LessonNumber]. (e.g. Lesson 1)
typedef LessonNumber = int;

/// Provide the dev (yes, I'm talking about me in the third person) with tools to materialize [LessonNumber] from ̶t̶h̶i̶n̶ ̶a̶i̶r [String] and also the other way around.
extension LessonNumberToolkit on LessonNumber {
  static List<LessonNumber> fromList(List<String> list) => list.map((e) => int.parse(e)).toList();

  /// We need to be able to do this conversion because [shared_preferences] only allow [String] in lists.
  static List<String> toList(List<LessonNumber> list) => list.map((e) => e.toString()).toList();
}
