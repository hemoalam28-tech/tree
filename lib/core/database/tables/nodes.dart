import 'package:drift/drift.dart';

class Nodes extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  RealColumn get positionX => real().withDefault(const Constant(0.0))();
  RealColumn get positionY => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE',
  ];
}
