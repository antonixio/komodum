abstract mixin class OrderableModel<T> {
  int get order;
  T copyWithOrder(int order);
}
