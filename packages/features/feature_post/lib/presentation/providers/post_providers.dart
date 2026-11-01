import 'package:core_network/core_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/post_database.dart';
import '../../data/datasources/post_remote_data_source.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/refresh_posts.dart';

final postDatabaseProvider = Provider<PostDatabase>((ref) {
  final database = PostDatabase();
  ref.onDispose(database.close);
  return database;
});

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  return JsonPlaceholderPostRemoteDataSource(ref.watch(apiClientProvider));
});

final postLocalDataSourceProvider = Provider<PostLocalDataSource>((ref) {
  return DriftPostLocalDataSource(ref.watch(postDatabaseProvider));
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    remote: ref.watch(postRemoteDataSourceProvider),
    local: ref.watch(postLocalDataSourceProvider),
  );
});

final refreshPostsProvider = Provider<RefreshPosts>((ref) {
  return RefreshPosts(
    repository: ref.watch(postRepositoryProvider),
    logger: ref.watch(appLoggerProvider),
  );
});
