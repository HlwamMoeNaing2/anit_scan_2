/// A failure the screen can show. Messages are safe to display.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is Failure &&
      other.runtimeType == runtimeType &&
      other.message == message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

final class SecureStorageFailure extends Failure {
  const SecureStorageFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}
