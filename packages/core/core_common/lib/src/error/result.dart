import 'failure.dart';

/// Data-layer result. View models map this onto [UiState].
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  bool operator ==(Object other) => other is Success<T> && other.data == data;

  @override
  int get hashCode => Object.hash(runtimeType, data);
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is ResultFailure<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);
}
