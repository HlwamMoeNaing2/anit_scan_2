import '../entities/post.dart';

/// Returns saved posts. An empty database is filled from the network.
/// When rows already exist, a failed network call returns those rows.
abstract interface class PostRepository {
  Future<List<Post>> refresh();
}
