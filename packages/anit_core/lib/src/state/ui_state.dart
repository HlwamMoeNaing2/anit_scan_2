sealed class UiState<T> {
  const UiState();
}

class UiInitial<T> extends UiState<T> {
  const UiInitial();

  @override
  bool operator ==(Object other) => other is UiInitial<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

class UiLoading<T> extends UiState<T> {
  const UiLoading();

  @override
  bool operator ==(Object other) => other is UiLoading<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

class UiSuccess<T> extends UiState<T> {
  const UiSuccess(this.data);

  final T data;

  @override
  bool operator ==(Object other) => other is UiSuccess<T> && other.data == data;

  @override
  int get hashCode => Object.hash(runtimeType, data);
}

class UiError<T> extends UiState<T> {
  const UiError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is UiError<T> && other.message == message;

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

extension UiStateWhen<T> on UiState<T> {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message) error,
  }) {
    return switch (this) {
      UiInitial<T>() => initial(),
      UiLoading<T>() => loading(),
      UiSuccess<T>(:final data) => success(data),
      UiError<T>(:final message) => error(message),
    };
  }
}
