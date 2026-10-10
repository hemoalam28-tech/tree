import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/attachments.dart';
import 'tables/edges.dart';
import 'tables/nodes.dart';
import 'tables/subjects.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Subjects, Nodes, Edges, Attachments])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.memory() : super(NativeDatabase.memory());

  factory AppDatabase.persistent({String name = 'shagara'}) {
    return AppDatabase(driftDatabase(name: name));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
