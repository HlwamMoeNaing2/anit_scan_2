import 'package:anit_core/anit_core.dart';
import 'package:test/test.dart';

void main() {
  test('when visits each state', () {
    const states = <UiState<int>>[
      UiInitial<int>(),
      UiLoading<int>(),
      UiSuccess<int>(7),
      UiError<int>('down'),
    ];

    final labels = states
        .map(
          (state) => state.when(
            initial: () => 'initial',
            loading: () => 'loading',
            success: (data) => 'success:$data',
            error: (message) => 'error:$message',
          ),
        )
        .toList();

    expect(labels, ['initial', 'loading', 'success:7', 'error:down']);
  });

  test('equal states compare equal', () {
    expect(const UiSuccess<String>('a'), const UiSuccess<String>('a'));
    expect(const UiError<String>('a'), isNot(const UiError<String>('b')));
    expect(const UiInitial<int>(), isNot(const UiLoading<int>()));
  });
}
