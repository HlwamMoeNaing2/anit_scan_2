import 'package:core_network/core_network.dart';

import '../models/post_model.dart';

abstract interface class PostRemoteDataSource {
  Future<List<PostModel>> fetchPosts();
}

class JsonPlaceholderPostRemoteDataSource implements PostRemoteDataSource {
  JsonPlaceholderPostRemoteDataSource(this._client);

  static const postsUrl = 'https://jsonplaceholder.typicode.com/posts';

  final ApiClient _client;

  @override
  Future<List<PostModel>> fetchPosts() async {
    final response = await _client.get<dynamic>(postsUrl, authenticated: false);
    return parsePostModels(response.data);
  }
}
