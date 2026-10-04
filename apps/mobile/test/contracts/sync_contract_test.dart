import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sync_contract_samples.dart';

void main() {
  final directory = Directory('../../contracts/fixtures/sync');
  final files = directory.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final cases = files
      .where((file) => file.path.endsWith('.json'))
      .expand((file) => jsonDecode(file.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>()
      .toList();

  for (final fixture in cases) {
    test('shared fixture: ${fixture['name']}', () {
      final body = fixture['body'] as Map<String, dynamic>;
      final schema = fixture['schema'] as String;
      if (fixture['valid'] == false) {
        expect(() => decodeContract(schema, body), throwsFormatException);
      } else {
        final dto = decodeContract(schema, body);
        expect(dto.toJson(), body);
      }
    });
  }

  test(
    'partial success confirms only applied operations and retry keeps ack',
    () {
      final mixed = cases.firstWhere((c) => c['name'] == 'mixed-response');
      final retry = cases.firstWhere((c) => c['name'] == 'duplicate-response');
      final dto = decodeContract('PushResponse', mixed['body']) as PushResponse;
      expect(dto.results.whereType<AppliedAck>(), hasLength(1));
      expect(dto.results, hasLength(3));
      expect(retry['body']['results'], mixed['body']['results']);
    },
  );

  test('duplicate operation IDs in a batch are rejected', () {
    final request = cases.firstWhere((c) => c['name'] == 'mixed-request');
    final body =
        jsonDecode(jsonEncode(request['body'])) as Map<String, dynamic>;
    final operations = body['operations'] as List;
    operations.add(operations.first);
    expect(() => decodeContract('PushRequest', body), throwsFormatException);
  });
}
