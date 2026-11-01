import 'package:core_common/core_common.dart';

import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_database.dart';
import '../datasources/post_remote_data_source.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required this.remote, required this.local});

  final PostRemoteDataSource remote;
  final PostLocalDataSource local;

  @override
  Future<List<Post>> refresh() async {
    final cached = await _readSaved();
    final List<PostModel> remotePosts;
    try {
      remotePosts = await remote.fetchPosts();
    } on AppException {
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
    try {
      await local.replaceAll(remotePosts);
      return _readSaved();
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(
        const LocalFailure('Saved posts could not be opened.'),
        cause: error,
      );
    }
  }

  Future<List<Post>> _readSaved() async {
    try {
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
