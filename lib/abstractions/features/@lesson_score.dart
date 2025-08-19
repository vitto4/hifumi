/// Each lesson has a completion score [LessonScore] in the format `[int masteredWords, int totalWords, double scorePoints]`
/// `scorePoints` is the sum of the scores of all words from the lesson. (it's only used for the progress bar on lesson tiles)
typedef LessonScore = List<double>;
