extension MapExtensions<T1, T2> on Map<T1, T2> {
  Map<T1, T2> filtered(List<dynamic> keys) => Map.fromEntries(entries.where((element) => keys.contains(element.key)));

  Map<T1, T2> addOrUpdate(Map<T1, T2> map) {
    for (var entry in map.entries) {
      this[entry.key] = entry.value;
    }
    return this;
  }
}
