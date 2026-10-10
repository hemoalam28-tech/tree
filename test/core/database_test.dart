import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shagara/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase database;
  const uuid = Uuid();

  setUp(() {
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  Future<String> insertSubject({String title = 'Mathematics'}) async {
    final id = uuid.v4();
    await database
        .into(database.subjects)
        .insert(
          SubjectsCompanion.insert(
            id: id,
            title: title,
            color: '#4F46E5',
            createdAt: DateTime.utc(2026, 10, 10),
          ),
        );
    return id;
  }

  Future<String> insertNode({
    required String subjectId,
    required String title,
    String? content,
    double positionX = 0,
    double positionY = 0,
  }) async {
    final id = uuid.v4();
    await database
        .into(database.nodes)
        .insert(
          NodesCompanion.insert(
            id: id,
            subjectId: subjectId,
            title: title,
            content: Value(content),
            positionX: Value(positionX),
            positionY: Value(positionY),
            createdAt: DateTime.utc(2026, 10, 10),
          ),
        );
    return id;
  }

  test('inserts and retrieves a subject', () async {
    final id = await insertSubject();

    final row = await (database.select(
      database.subjects,
    )..where((t) => t.id.equals(id))).getSingle();

    expect(row.id, id);
    expect(row.title, 'Mathematics');
    expect(row.color, '#4F46E5');
  });

  test('inserts a node linked to a subject', () async {
    final subjectId = await insertSubject();
    final nodeId = await insertNode(
      subjectId: subjectId,
      title: 'Algebra',
      content: 'Linear equations',
      positionX: 12.5,
      positionY: 40,
    );

    final node = await (database.select(
      database.nodes,
    )..where((t) => t.id.equals(nodeId))).getSingle();

    expect(node.subjectId, subjectId);
    expect(node.title, 'Algebra');
    expect(node.content, 'Linear equations');
    expect(node.positionX, 12.5);
    expect(node.positionY, 40);
  });

  test('inserts an edge connecting two nodes', () async {
    final subjectId = await insertSubject();
    final sourceId = await insertNode(subjectId: subjectId, title: 'Parent');
    final targetId = await insertNode(subjectId: subjectId, title: 'Child');
    final edgeId = uuid.v4();

    await database
        .into(database.edges)
        .insert(
          EdgesCompanion.insert(
            id: edgeId,
            sourceNodeId: sourceId,
            targetNodeId: targetId,
            label: const Value('depends on'),
            createdAt: DateTime.utc(2026, 10, 10),
          ),
        );

    final edge = await (database.select(
      database.edges,
    )..where((t) => t.id.equals(edgeId))).getSingle();

    expect(edge.sourceNodeId, sourceId);
    expect(edge.targetNodeId, targetId);
    expect(edge.label, 'depends on');
  });

  test('rejects a node whose subject does not exist', () async {
    expect(
      () => insertNode(subjectId: uuid.v4(), title: 'Orphan'),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'deleting a subject cascades to nodes, edges, and attachments',
    () async {
      final subjectId = await insertSubject();
      final sourceId = await insertNode(subjectId: subjectId, title: 'Source');
      final targetId = await insertNode(subjectId: subjectId, title: 'Target');

      await database
          .into(database.edges)
          .insert(
            EdgesCompanion.insert(
              id: uuid.v4(),
              sourceNodeId: sourceId,
              targetNodeId: targetId,
              createdAt: DateTime.utc(2026, 10, 10),
            ),
          );

      await database
          .into(database.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: uuid.v4(),
              nodeId: sourceId,
              filePath: 'files/notes.pdf',
              fileType: 'application/pdf',
              fileSize: 1024,
              createdAt: DateTime.utc(2026, 10, 10),
            ),
          );

      await (database.delete(
        database.subjects,
      )..where((t) => t.id.equals(subjectId))).go();

      expect(await database.select(database.subjects).get(), isEmpty);
      expect(await database.select(database.nodes).get(), isEmpty);
      expect(await database.select(database.edges).get(), isEmpty);
      expect(await database.select(database.attachments).get(), isEmpty);
    },
  );

  test('deleting a node cascades to its edges and attachments', () async {
    final subjectId = await insertSubject();
    final sourceId = await insertNode(subjectId: subjectId, title: 'Source');
    final targetId = await insertNode(subjectId: subjectId, title: 'Target');

    await database
        .into(database.edges)
        .insert(
          EdgesCompanion.insert(
            id: uuid.v4(),
            sourceNodeId: sourceId,
            targetNodeId: targetId,
            createdAt: DateTime.utc(2026, 10, 10),
          ),
        );

    await database
        .into(database.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: uuid.v4(),
            nodeId: sourceId,
            filePath: 'files/image.png',
            fileType: 'image/png',
            fileSize: 2048,
            createdAt: DateTime.utc(2026, 10, 10),
          ),
        );

    await (database.delete(
      database.nodes,
    )..where((t) => t.id.equals(sourceId))).go();

    expect(await database.select(database.edges).get(), isEmpty);
    expect(await database.select(database.attachments).get(), isEmpty);
    expect(await database.select(database.nodes).get(), hasLength(1));
    expect(await database.select(database.subjects).get(), hasLength(1));
  });
}
