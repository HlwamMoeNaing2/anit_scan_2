import 'package:core_common/core_common.dart';

import '../../domain/entities/post.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  Post toEntity() {
    return Post(id: id, userId: userId, title: title, body: body);
  }

  static PostModel fromJson(Map<dynamic, dynamic> json) {
    final id = json['id'];
    final userId = json['userId'];
    final title = json['title'];
    final body = json['body'];
    if (id is! int || userId is! int || title is! String || body is! String) {
      throw const AppException(
        NetworkFailure('The request could not be completed.'),
      );
    }
    return PostModel(id: id, userId: userId, title: title, body: body);
  }

  @override
  bool operator ==(Object other) =>
      other is PostModel &&
      other.id == id &&
      other.userId == userId &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, userId, title, body);
}

List<PostModel> parsePostModels(Object? data) {
  if (data is! List) {
    throw const AppException(
      NetworkFailure('The request could not be completed.'),
    );
  }
  return [
    for (final item in data)
      if (item is Map)
        PostModel.fromJson(item)
      else
        throw const AppException(
          NetworkFailure('The request could not be completed.'),
        ),
  ];
}
