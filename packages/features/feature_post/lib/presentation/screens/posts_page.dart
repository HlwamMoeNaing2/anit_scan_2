import 'package:core_common/core_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/post.dart';
import '../providers/posts_view_model.dart';
import '../widgets/posts_list.dart';
import '../widgets/posts_message.dart';

class PostsPage extends ConsumerStatefulWidget {
  const PostsPage({super.key});

  @override
  ConsumerState<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends ConsumerState<PostsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(postsViewModelProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Anit Scan 2')),
      body: switch (state) {
        UiInitial<List<Post>>() || UiLoading<List<Post>>() => const Center(
          child: CircularProgressIndicator(),
        ),
        UiError<List<Post>>(:final message) => PostsMessage(
          message: message,
          onRetry: _load,
        ),
        UiSuccess<List<Post>>(:final data) => PostsList(
          posts: data,
          onRefresh: _load,
        ),
      },
    );
  }

  Future<void> _load() {
    return ref.read(postsViewModelProvider.notifier).load();
  }
}
