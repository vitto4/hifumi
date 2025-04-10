import 'dart:collection';
import 'dart:math';

/// Set with a cooldown mechanism for drawing elements.
/// When one draws, a random element that is not present in the [_cooldownBuffer] is returned.
/// Once the buffer reaches its fixed length of [cooldown], the oldest element is removed, so that it may be drawn again.
class CooldownSet<T> extends SetBase<T> {
  /// The complete set of items.
  late final Set<T> _internalSet;

  /// The maximum number of items that can be on cooldown.
  final int cooldown;

  /// Buffer to hold recently drawn items.
  final List<T> _cooldownBuffer = [];

  /// Needed for drawing.
  final Random _random = Random();

  CooldownSet(Iterable<T> items, {this.cooldown = 0}) {
    this._internalSet = items.toSet();
  }

  /* ------------------------------ Set interface ----------------------------- */

  @override
  bool add(T value) => _internalSet.add(value);

  @override
  bool contains(Object? value) => _internalSet.contains(value);

  @override
  T? lookup(Object? object) => _internalSet.lookup(object);

  @override
  bool remove(Object? value) {
    // Also remove from the cooldown buffer, if present
    _cooldownBuffer.remove(value);
    return _internalSet.remove(value);
  }

  @override
  Set<T> toSet() => _internalSet.toSet();

  @override
  Iterator<T> get iterator => _internalSet.iterator;

  @override
  int get length => _internalSet.length;

  /* ------------------------- Cooldown functionality ------------------------- */

  /// Draws a random element from the set that is not on cooldown.
  ///
  /// If the buffer excludes all possible elements (from [_internalSet]), removes the oldest element from the buffer to make room.
  /// May return [null] if the [_internalSet] is empty to begin with.
  T? draw() {
    // Available items, i.e. those not in the buffer
    List<T> available = _internalSet.where((item) => !_cooldownBuffer.contains(item)).toList();

    // If no available item exists, remove the oldest element from the cooldown buffer.
    if (available.isEmpty && _cooldownBuffer.isNotEmpty) {
      _cooldownBuffer.removeAt(0);
      available = _internalSet.where((item) => !_cooldownBuffer.contains(item)).toList();
    }

    // If still no available item, it means the internal set is empty.
    if (available.isEmpty) {
      return null;
    } else {
      // Select a random item from the available pool
      final int index = _random.nextInt(available.length);
      final T drawn = available[index];

      // Add the drawn item to the cooldown buffer
      _cooldownBuffer.add(drawn);

      // If the cooldown buffer exceeds the maximum cooldown value, remove the oldest element to maintain the buffer size
      if (cooldown > 0 && _cooldownBuffer.length > cooldown) {
        _cooldownBuffer.removeAt(0);
      }

      return drawn;
    }
  }

  /// Draws multiple items from the list in a row by repeatedly calling the `draw()`.
  List<T?> drawMultiple(int count) {
    List<T?> results = [];
    for (int i = 0; i < count; i++) {
      results.add(draw());
    }
    return results;
  }

  /// Returns an unmodifiable view of the current cooldown buffer.
  List<T> get cooldownBuffer => List.unmodifiable(_cooldownBuffer);
}
