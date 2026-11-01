import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('launch publishes success and error', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(_echoProvider), const UiInitial<int>());

    await container.read(_echoProvider.notifier).succeed(4);
    expect(container.read(_echoProvider), const UiSuccess<int>(4));

    await container.read(_echoProvider.notifier).fail('down');
    expect(container.read(_echoProvider), const UiError<int>('down'));
  });

  test('an older launch cannot overwrite a newer one', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final viewModel = container.read(_echoProvider.notifier);

    final first = Completer<Result<int>>();
    final second = Completer<Result<int>>();
    final firstCall = viewModel.launch(() => first.future);
    final secondCall = viewModel.launch(() => second.future);

    first.complete(const Success<int>(1));
    await firstCall;
    expect(container.read(_echoProvider), const UiLoading<int>());

    second.complete(const Success<int>(2));
    await secondCall;
    expect(container.read(_echoProvider), const UiSuccess<int>(2));
  });
}

final _echoProvider = NotifierProvider<_EchoViewModel, UiState<int>>(
  _EchoViewModel.new,
);

class _EchoViewModel extends ViewModel<int> {
  Future<void> succeed(int value) {
    return launch(() async => Success<int>(value));
  }

  Future<void> fail(String message) {
    return launch(() async => ResultFailure<int>(NetworkFailure(message)));
  }
}
