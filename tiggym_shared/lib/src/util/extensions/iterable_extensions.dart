import 'dart:math';

extension IterableExtensions<T> on Iterable<T> {
  Iterable<T> addBetween(T element) {
    List<T> list = [];
    for (var item in this) {
      list.add(item);
      list.add(element);
    }
    if (list.isNotEmpty) {
      list.removeLast();
    }
    return list;
  }

  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) => fold(<K, List<T>>{}, (Map<K, List<T>> map, T element) => map..putIfAbsent(keyFunction(element), () => <T>[]).add(element));

  Iterable<T> reordered(int oldIndex, int newIndex) {
    List<T> list = [...this];

    final item = list.removeAt(oldIndex);
    list.insert(min((length - 1), newIndex), item);
    return list;
  }

  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  T? lastWhereOrNull(bool Function(T element) test) {
    return <T?>[...this].lastWhere((element) => false, orElse: () => null);
  }

  T? randomItem() {
    return elementAtOrNull(Random().nextInt(length));
  }

  T getCircular(int index) {
    final i = index % length;
    return elementAt(i);
  }

  Iterable<T> replaceWith(T element, T newElement) {
    final index = toList().indexOf(element);

    if (index < 0) {
      return this;
    }

    return [...this]..replaceRange(index, index + 1, [newElement]);
  }

  Iterable<T> replaceFirstWhere(bool Function(T element) test, T newElement) {
    final cur = firstWhereOrNull(test);
    if (cur != null) {
      return replaceWith(cur, newElement);
    }

    return [...this];
  }

  Iterable<T> getBetween(int startIndex, int endIndex) {
    int quantity = endIndex - startIndex + 1;

    if (startIndex < 0) {
      return take(quantity);
    } else if (endIndex >= length) {
      return skip(max((length - quantity), 0)).take(quantity);
    } else {
      return skip(startIndex).take(quantity);
    }
  }
}
