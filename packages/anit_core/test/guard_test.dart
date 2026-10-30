import 'package:anit_core/anit_core.dart';
import 'package:test/test.dart';

void main() {
  test('returns success data', () async {
    final result = await guardCall(() async => 3);
    expect(result, const Success<int>(3));
  });

  test('keeps the failure message from AppException', () async {
    final result = await guardCall<int>(() async {
      throw const AppException(NetworkFailure('No internet connection.'));
    });

    expect(
      result,
      const ResultFailure<int>(NetworkFailure('No internet connection.')),
    );
  });

  test('hides unexpected error details', () async {
    final result = await guardCall<int>(() async {
      throw StateError('database password = secret');
    });

    expect(result, isA<ResultFailure<int>>());
    final failure = (result as ResultFailure<int>).failure;
    expect(failure, isA<UnexpectedFailure>());
    expect(failure.message, isNot(contains('secret')));
  });
}
