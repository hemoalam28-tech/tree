import 'package:drift/drift.dart';

class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get nodeId => text()();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (node_id) REFERENCES nodes (id) ON DELETE CASCADE',
  ];
}
