/// Mixin that provides a code property for serialization in [shared_preferences].
mixin HippityHoppityANumberYouShallBe {
  /// To be written in [shared_preferences]
  int get code;

  /// Would be great if we were allowed to state that classes using our mixin must declare a [factory] of some kind.
  /// For now just imagine that it's possible.
  ///
  /// All classes using [HippityHoppityANumberYouShallBe] shall also have a [factory] like :
  /// ```dart
  /// factory ___.fromCode(int code)
  /// ```
  ///
  /// See also : https://github.com/dart-lang/language/issues/1803
}
