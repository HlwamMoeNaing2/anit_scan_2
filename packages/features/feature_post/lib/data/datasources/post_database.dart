import 'package:core_database/core_database.dart';
import 'package:drift/drift.dart';

import '../models/post_model.dart';

part 'post_database.g.dart';

@DataClassName('PostRow')
class Posts extends Table {
  IntColumn get id => integer()();

  IntColumn get userId => integer()();

  TextColumn get title => text()();

  TextColumn get body => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Posts])
class PostDatabase extends _$PostDatabase {
  PostDatabase([QueryExecutor? executor]) : super(executor ?? openAppDatabase());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.createTable(posts);
      }
    },
    beforeOpen: (details) => configureSqlite(this),
  );
}

abstract interface class PostLocalDataSource {
  Future<void> replaceAll(List<PostModel> posts);

  Future<List<PostModel>> readAll();
}

class DriftPostLocalDataSource implements PostLocalDataSource {
  DriftPostLocalDataSource(this.database);

  final PostDatabase database;

  @override
  Future<void> replaceAll(List<PostModel> posts) {
    return database.transaction(() async {
      await database.delete(database.posts).go();
      await database.batch((batch) {
        batch.insertAll(database.posts, [
          for (final post in posts)
            PostsCompanion.insert(
              id: Value(post.id),
              userId: post.userId,
              title: post.title,
              body: post.body,
            ),
        ]);
      });
    });
  }

  @override
  Future<List<PostModel>> readAll() async {
    final rows =
        await (database.select(database.posts)..orderBy([
              (table) => OrderingTerm.asc(table.id),
            ]))
            .get();
    return [
      for (final row in rows)
        PostModel(
          id: row.id,
          userId: row.userId,
          title: row.title,
          body: row.body,
        ),
    ];
  }
}
