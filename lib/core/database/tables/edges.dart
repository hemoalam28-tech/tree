import 'package:drift/drift.dart';

class Edges extends Table {
  TextColumn get id => text()();
  TextColumn get sourceNodeId => text()();
  TextColumn get targetNodeId => text()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (source_node_id) REFERENCES nodes (id) ON DELETE CASCADE',
    'FOREIGN KEY (target_node_id) REFERENCES nodes (id) ON DELETE CASCADE',
  ];
}
