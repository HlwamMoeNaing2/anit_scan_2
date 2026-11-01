import 'package:core_common/core_common.dart';
import 'package:feature_post/feature_post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('load shows the posts returned by the use case', () async {
    const posts = [
      Post(id: 1, userId: 1, title: 'Saved', body: 'From the database'),
    ];
    final container = ProviderContainer(
      overrides: [
        refreshPostsProvider.overrideWithValue(
          RefreshPosts(
            repository: _FixedPosts(posts),
            logger: const SilentLogger(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(postsViewModelProvider.notifier).load();

    expect(
      container.read(postsViewModelProvider),
      const UiSuccess<List<Post>>(posts),
    );
  });
}

class _FixedPosts implements PostRepository {
  const _FixedPosts(this.posts);

  final List<Post> posts;

  @override
  Future<List<Post>> refresh() async => posts;
}
