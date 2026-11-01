import 'package:core_common/core_common.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/post.dart';
import 'post_providers.dart';

final postsViewModelProvider =
    NotifierProvider<PostsViewModel, UiState<List<Post>>>(PostsViewModel.new);

class PostsViewModel extends ViewModel<List<Post>> {
  Future<void> load() {
    return launch(() => ref.read(refreshPostsProvider).call());
  }
}
