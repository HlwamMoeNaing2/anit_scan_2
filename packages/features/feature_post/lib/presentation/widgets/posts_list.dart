import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';

class PostsList extends StatelessWidget {
  const PostsList({required this.posts, required this.onRefresh, super.key});

  final List<Post> posts;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length + 1,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Showing posts saved in the local database.'),
            );
          }
          final post = posts[index - 1];
          return ListTile(
            title: Text(post.title),
            subtitle: Text(
              post.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
