import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:feature_post/data/datasources/post_database.dart';
import 'package:feature_post/data/datasources/post_remote_data_source.dart';
import 'package:feature_post/data/models/post_model.dart';
import 'package:feature_post/data/repositories/post_repository_impl.dart';
import 'package:feature_post/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the posts response and does not send the access token', () async {
    final session = _MemorySession();
    await session.saveAccessToken('secret-token');
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'));
    late RequestOptions captured;
    dio.interceptors.add(AuthInterceptor(session));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<List<Map<String, Object>>>(
              requestOptions: options,
              data: const [
                {'userId': 1, 'id': 7, 'title': 'A title', 'body': 'A body'},
              ],
            ),
          );
        },
      ),
    );
    final api = JsonPlaceholderPostRemoteDataSource(
      ApiClient(
        config: const ApiConfig(baseUrl: 'https://api.example.com/'),
        sessionStore: session,
        logger: const SilentLogger(),
        dio: dio,
      ),
    );

    final posts = await api.fetchPosts();

    expect(captured.uri.toString(), JsonPlaceholderPostRemoteDataSource.postsUrl);
    expect(captured.headers.containsKey('Authorization'), isFalse);
    expect(posts, const [
      PostModel(id: 7, userId: 1, title: 'A title', body: 'A body'),
    ]);
  });

  test('a failed request leaves posts already saved in the database', () async {
    final database = PostDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final api = _ScriptedRemote([
      const [PostModel(id: 2, userId: 1, title: 'Second', body: 'Body 2')],
    ]);
    final repository = PostRepositoryImpl(
      remote: api,
      local: DriftPostLocalDataSource(database),
    );

    final saved = await repository.refresh();
    expect(saved, const [
      Post(id: 2, userId: 1, title: 'Second', body: 'Body 2'),
    ]);

    api.failNext = true;
    final shown = await repository.refresh();

    expect(shown, const [
      Post(id: 2, userId: 1, title: 'Second', body: 'Body 2'),
    ]);
    final rows = await database.select(database.posts).get();
    expect(rows.map((row) => row.id), [2]);
  });

  test('an empty database still reports a failed request', () async {
    final database = PostDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PostRepositoryImpl(
      remote: _ScriptedRemote([])..failNext = true,
      local: DriftPostLocalDataSource(database),
    );

    await expectLater(
      repository.refresh(),
      throwsA(
        isA<AppException>().having(
          (error) => error.failure,
          'failure',
          const NetworkFailure('No internet connection.'),
        ),
      ),
    );
  });

  test('refresh stores the response and returns the database rows in id order', () async {
    final database = PostDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PostRepositoryImpl(
      remote: _ScriptedRemote([
        const [
          PostModel(id: 3, userId: 2, title: 'Later', body: 'B'),
          PostModel(id: 1, userId: 1, title: 'Earlier', body: 'A'),
        ],
      ]),
      local: DriftPostLocalDataSource(database),
    );

    final posts = await repository.refresh();

    expect(posts.map((post) => post.id), [1, 3]);
    final rows = await database.select(database.posts).get();
    expect(rows.map((row) => row.title).toSet(), {'Earlier', 'Later'});
  });
}

class _ScriptedRemote implements PostRemoteDataSource {
  _ScriptedRemote(this._pages);

  final List<List<PostModel>> _pages;
  var failNext = false;

  @override
  Future<List<PostModel>> fetchPosts() async {
    if (failNext) {
      throw const AppException(NetworkFailure('No internet connection.'));
    }
    return _pages.removeAt(0);
  }
}

class _MemorySession implements SessionStore {
  String? _token;

  @override
  Future<void> clearSession() async => _token = null;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> saveAccessToken(String token) async => _token = token;
}
