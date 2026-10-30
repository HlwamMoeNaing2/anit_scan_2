import 'package:anit_core/anit_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// MVVM view model. Screens watch [state] and call a method that uses [launch].
///
/// Do not override [build]. A feature view model reads repositories with
/// `ref.read` inside its own methods.
abstract class ViewModel<T> extends Notifier<UiState<T>> {
  int _generation = 0;

  @override
  UiState<T> build() {
    _generation = 0;
    return UiInitial<T>();
  }

  /// Replaces the current state with loading, then success or error.
  /// An older call that finishes after a newer one does not overwrite it.
  Future<void> launch(Future<Result<T>> Function() action) async {
    final generation = ++_generation;
    state = UiLoading<T>();
    final result = await action();
    if (generation != _generation) return;
    state = switch (result) {
      Success(:final data) => UiSuccess<T>(data),
      ResultFailure(:final failure) => UiError<T>(failure.message),
    };
  }
}
