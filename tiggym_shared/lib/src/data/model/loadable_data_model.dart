class LoadableDataModel<T> {
  final T? data;
  final bool loading;
  final bool success;
  final bool error;
  final String errorMessage;
  LoadableDataModel({
    this.data,
    required this.loading,
    required this.success,
    required this.error,
    required this.errorMessage,
  });

  LoadableDataModel.error({
    required this.errorMessage,
  })  : data = null,
        loading = false,
        success = false,
        error = true;

  LoadableDataModel.success({
    required this.data,
  })  : error = false,
        errorMessage = '',
        loading = false,
        success = true;

  LoadableDataModel.loading()
      : error = false,
        errorMessage = '',
        loading = true,
        success = false,
        data = null;

  LoadableDataModel<T> copyWith({
    T? data,
    bool? loading,
    bool? success,
    bool? error,
    String? errorMessage,
  }) {
    return LoadableDataModel<T>(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'LoadableDataModel(data: $data, loading: $loading, success: $success, error: $error, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoadableDataModel<T> &&
        other.data == data &&
        other.loading == loading &&
        other.success == success &&
        other.error == error &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return data.hashCode ^
        loading.hashCode ^
        success.hashCode ^
        error.hashCode ^
        errorMessage.hashCode;
  }
}
