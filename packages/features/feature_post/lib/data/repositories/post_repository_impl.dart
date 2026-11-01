import 'package:core_common/core_common.dart';

import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_database.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required this.remote, required this.local});

  final PostRemoteDataSource remote;
  final PostLocalDataSource local;

  @override
  Future<List<Post>> refresh() async {
    final remotePosts = await remote.fetchPosts();
    try {
      await local.replaceAll(remotePosts);
      final saved = await local.readAll();
      return [for (final post in saved) post.toEntity()];
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(
        const LocalFailure('Saved posts could not be opened.'),
        cause: error,
      );
    }
  }
}
