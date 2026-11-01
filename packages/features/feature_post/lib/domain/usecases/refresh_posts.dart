import 'package:core_common/core_common.dart';

import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case. The view model calls this and receives a [Result].
class RefreshPosts {
  const RefreshPosts({required this.repository, required this.logger});

  final PostRepository repository;
  final AppLogger logger;

  Future<Result<List<Post>>> call() {
    return guardCall(repository.refresh, logger: logger);
  }
}
