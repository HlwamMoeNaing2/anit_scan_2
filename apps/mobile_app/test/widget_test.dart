import 'package:core_common/core_common.dart';
import 'package:feature_post/feature_post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/app/anit_scan_app.dart';

void main() {
  testWidgets('the home page shows posts saved by the use case', (tester) async {
    const posts = [
      Post(id: 1, userId: 1, title: 'Hello from the database', body: 'Body'),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          refreshPostsProvider.overrideWithValue(
            RefreshPosts(
              repository: _FixedPosts(posts),
              logger: const SilentLogger(),
            ),
          ),
        ],
        child: const AnitScanApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Anit Scan 2'), findsOneWidget);
    expect(find.text('Hello from the database'), findsOneWidget);
    expect(
      find.text('Showing posts saved in the local database.'),
      findsOneWidget,
    );
  });
}

class _FixedPosts implements PostRepository {
  const _FixedPosts(this.posts);

  final List<Post> posts;

  @override
  Future<List<Post>> refresh() async => posts;
}
