import '../entities/post.dart';

/// Loads posts from the network, stores them, and returns the saved rows.
abstract interface class PostRepository {
  Future<List<Post>> refresh();
}
