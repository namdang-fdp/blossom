// Sample typed DTOs for contract tests, not a production HTTP client.
abstract interface class WireDto {
  Map<String, Object?> toJson();
}

WireDto decodeContract(String schema, Map<String, dynamic> json) {
  final dto = switch (schema) {
    'PushRequest' => PushRequest.fromJson(json),
    'PushResponse' => PushResponse.fromJson(json),
    'PullResponse' => PullResponse.fromJson(json),
    'SnapshotResponse' => SnapshotResponse.fromJson(json),
    'Problem' => Problem.fromJson(json),
    _ => throw const FormatException('Unknown schema'),
  };
  if (dto is PushRequest) {
    final ids = dto.operations.map((o) => o.operationId).toSet();
    if (ids.length != dto.operations.length) {
      throw const FormatException('Duplicate operation IDs');
    }
  }
  return dto;
}

Map<String, dynamic> _object(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Expected JSON object');
  }
  return value;
}

void _fields(Map<String, dynamic> json, List<String> fields) {
  if (json.length != fields.length || !fields.every(json.containsKey)) {
    throw const FormatException('Missing or unknown field');
  }
}

String? _string(
  Object? value, {
  bool nullable = false,
  bool onlyNull = false,
  List<String>? allowed,
  String? pattern,
  String? format,
  int min = 0,
  int max = 2147483647,
}) {
  if (value == null && nullable) return null;
  if (onlyNull ||
      value is! String ||
      value.length < min ||
      value.length > max) {
    throw const FormatException('Invalid string');
  }
  if ((allowed != null && !allowed.contains(value)) ||
      (pattern != null && !RegExp(pattern).hasMatch(value))) {
    throw const FormatException('Invalid enum or pattern');
  }
  if (format == 'date-time' &&
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T([01]\d|2[0-3]):[0-5]\d:[0-5]\d(\.\d{1,6})?(Z|[+-](0\d|1[0-3]):[0-5]\d|[+-]14:00)$',
      ).hasMatch(value)) {
    throw const FormatException('Invalid timestamp');
  }
  if (format == 'date' && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw const FormatException('Invalid date');
  }
  if (format == 'date' || format == 'date-time') {
    final date = DateTime.tryParse(value);
    final parts = value
        .substring(0, value.length < 10 ? value.length : 10)
        .split('-');
    if (date == null || parts.length != 3) {
      throw const FormatException('Invalid date');
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      throw const FormatException('Invalid date');
    }
    final local = DateTime.utc(year, month, day);
    if (local.year != year || local.month != month || local.day != day) {
      throw const FormatException('Invalid calendar date');
    }
  }
  if (format == 'uri' && !(Uri.tryParse(value)?.hasScheme ?? false)) {
    throw const FormatException('Invalid URI');
  }
  return value;
}

int _integer(Object? value, {required int min, required int max}) {
  if (value is! int || value < min || value > max) {
    throw const FormatException('Invalid integer');
  }
  return value;
}

bool _boolean(Object? value) {
  if (value is! bool) throw const FormatException('Invalid boolean');
  return value;
}

List<T> _list<T>(
  Object? value,
  T Function(Object?) read, {
  int min = 0,
  int max = 2147483647,
  bool unique = false,
}) {
  if (value is! List ||
      value.length < min ||
      value.length > max ||
      (unique && value.toSet().length != value.length)) {
    throw const FormatException('Invalid list');
  }
  return List.unmodifiable(value.map(read));
}

final class FieldError implements WireDto {
  final String path;
  final String code;
  const FieldError({required this.path, required this.code});
  factory FieldError.fromJson(Map<String, dynamic> json) {
    _fields(json, ['path', 'code']);
    return FieldError(
      path: _string(json['path'], min: 1)!,
      code: _string(json['code'], min: 1)!,
    );
  }
  @override
  Map<String, Object?> toJson() => {'path': path, 'code': code};
}

final class Problem implements WireDto {
  final String type;
  final String title;
  final int status;
  final String detail;
  final String code;
  final String requestId;
  final bool retryable;
  final List<FieldError> fieldErrors;
  const Problem({
    required this.type,
    required this.title,
    required this.status,
    required this.detail,
    required this.code,
    required this.requestId,
    required this.retryable,
    required this.fieldErrors,
  });
  factory Problem.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'type',
      'title',
      'status',
      'detail',
      'code',
      'requestId',
      'retryable',
      'fieldErrors',
    ]);
    return Problem(
      type: _string(json['type'], format: 'uri')!,
      title: _string(json['title'], min: 1)!,
      status: _integer(json['status'], min: 400, max: 599),
      detail: _string(json['detail'], min: 1)!,
      code: _string(
        json['code'],
        allowed: [
          'UNAUTHENTICATED',
          'TOKEN_EXPIRED',
          'FORBIDDEN',
          'CURSOR_ACCOUNT_MISMATCH',
          'INVALID_CURSOR',
          'CURSOR_EXPIRED',
          'SNAPSHOT_EXPIRED',
          'VALIDATION_FAILED',
          'UNSUPPORTED_SCHEMA_VERSION',
          'UNSUPPORTED_OPERATION',
          'OPERATION_ID_REUSED',
          'OPERATION_IN_PROGRESS',
          'ENTITY_DELETED',
          'RATE_LIMITED',
          'PAYLOAD_TOO_LARGE',
          'TEMPORARILY_UNAVAILABLE',
        ],
      )!,
      requestId: _string(
        json['requestId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      retryable: _boolean(json['retryable']),
      fieldErrors: _list(
        json['fieldErrors'],
        (value) => FieldError.fromJson(_object(value)),
        unique: false,
      ),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'type': type,
    'title': title,
    'status': status,
    'detail': detail,
    'code': code,
    'requestId': requestId,
    'retryable': retryable,
    'fieldErrors': fieldErrors.map((value) => value.toJson()).toList(),
  };
}

final class AttemptPayload implements WireDto {
  final String attemptId;
  final String sessionId;
  final String targetId;
  final String contentRevision;
  final String targetType;
  final String attemptKind;
  final String outcome;
  final int hintCount;
  final String rulesVersion;
  const AttemptPayload({
    required this.attemptId,
    required this.sessionId,
    required this.targetId,
    required this.contentRevision,
    required this.targetType,
    required this.attemptKind,
    required this.outcome,
    required this.hintCount,
    required this.rulesVersion,
  });
  factory AttemptPayload.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'attemptId',
      'sessionId',
      'targetId',
      'contentRevision',
      'targetType',
      'attemptKind',
      'outcome',
      'hintCount',
      'rulesVersion',
    ]);
    return AttemptPayload(
      attemptId: _string(
        json['attemptId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      sessionId: _string(
        json['sessionId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      targetId: _string(
        json['targetId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      contentRevision: _string(
        json['contentRevision'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      targetType: _string(
        json['targetType'],
        allowed: ['meaning_recall', 'pattern_recall'],
      )!,
      attemptKind: _string(
        json['attemptKind'],
        allowed: ['review', 'practice', 'delayed_probe'],
      )!,
      outcome: _string(
        json['outcome'],
        allowed: ['correct', 'incorrect', 'assisted'],
      )!,
      hintCount: _integer(json['hintCount'], min: 0, max: 100),
      rulesVersion: _string(
        json['rulesVersion'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'attemptId': attemptId,
    'sessionId': sessionId,
    'targetId': targetId,
    'contentRevision': contentRevision,
    'targetType': targetType,
    'attemptKind': attemptKind,
    'outcome': outcome,
    'hintCount': hintCount,
    'rulesVersion': rulesVersion,
  };
}

final class LibraryPayload implements WireDto {
  final String entryId;
  final String sense;
  final String usagePattern;
  final String? note;
  const LibraryPayload({
    required this.entryId,
    required this.sense,
    required this.usagePattern,
    required this.note,
  });
  factory LibraryPayload.fromJson(Map<String, dynamic> json) {
    _fields(json, ['entryId', 'sense', 'usagePattern', 'note']);
    return LibraryPayload(
      entryId: _string(
        json['entryId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      sense: _string(json['sense'], min: 1, max: 1000)!,
      usagePattern: _string(json['usagePattern'], min: 1, max: 500)!,
      note: _string(json['note'], nullable: true, max: 2000),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'entryId': entryId,
    'sense': sense,
    'usagePattern': usagePattern,
    'note': note,
  };
}

final class DeletePayload implements WireDto {
  final String entryId;
  const DeletePayload({required this.entryId});
  factory DeletePayload.fromJson(Map<String, dynamic> json) {
    _fields(json, ['entryId']);
    return DeletePayload(
      entryId: _string(
        json['entryId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
    );
  }
  @override
  Map<String, Object?> toJson() => {'entryId': entryId};
}

final class AttemptOperation implements Operation {
  @override
  final String operationId;
  final String deviceId;
  final int deviceSequence;
  final int schemaVersion;
  final String occurredAt;
  final String timezone;
  final String learningDate;
  final String? baseRevision;
  final String operationType;
  final AttemptPayload payload;
  const AttemptOperation({
    required this.operationId,
    required this.deviceId,
    required this.deviceSequence,
    required this.schemaVersion,
    required this.occurredAt,
    required this.timezone,
    required this.learningDate,
    required this.baseRevision,
    required this.operationType,
    required this.payload,
  });
  factory AttemptOperation.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'operationId',
      'deviceId',
      'deviceSequence',
      'schemaVersion',
      'occurredAt',
      'timezone',
      'learningDate',
      'baseRevision',
      'operationType',
      'payload',
    ]);
    return AttemptOperation(
      operationId: _string(
        json['operationId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      deviceId: _string(
        json['deviceId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      deviceSequence: _integer(
        json['deviceSequence'],
        min: 1,
        max: 9007199254740991,
      ),
      schemaVersion: _integer(json['schemaVersion'], min: 1, max: 1),
      occurredAt: _string(
        json['occurredAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
      timezone: _string(json['timezone'], min: 1, max: 64)!,
      learningDate: _string(json['learningDate'], format: 'date')!,
      baseRevision: _string(
        json['baseRevision'],
        nullable: true,
        onlyNull: true,
      ),
      operationType: _string(
        json['operationType'],
        allowed: ['attempt.record'],
      )!,
      payload: AttemptPayload.fromJson(_object(json['payload'])),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'operationId': operationId,
    'deviceId': deviceId,
    'deviceSequence': deviceSequence,
    'schemaVersion': schemaVersion,
    'occurredAt': occurredAt,
    'timezone': timezone,
    'learningDate': learningDate,
    'baseRevision': baseRevision,
    'operationType': operationType,
    'payload': payload.toJson(),
  };
}

final class LibraryOperation implements Operation {
  @override
  final String operationId;
  final String deviceId;
  final int deviceSequence;
  final int schemaVersion;
  final String occurredAt;
  final String timezone;
  final String learningDate;
  final String? baseRevision;
  final String operationType;
  final LibraryPayload payload;
  const LibraryOperation({
    required this.operationId,
    required this.deviceId,
    required this.deviceSequence,
    required this.schemaVersion,
    required this.occurredAt,
    required this.timezone,
    required this.learningDate,
    required this.baseRevision,
    required this.operationType,
    required this.payload,
  });
  factory LibraryOperation.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'operationId',
      'deviceId',
      'deviceSequence',
      'schemaVersion',
      'occurredAt',
      'timezone',
      'learningDate',
      'baseRevision',
      'operationType',
      'payload',
    ]);
    return LibraryOperation(
      operationId: _string(
        json['operationId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      deviceId: _string(
        json['deviceId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      deviceSequence: _integer(
        json['deviceSequence'],
        min: 1,
        max: 9007199254740991,
      ),
      schemaVersion: _integer(json['schemaVersion'], min: 1, max: 1),
      occurredAt: _string(
        json['occurredAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
      timezone: _string(json['timezone'], min: 1, max: 64)!,
      learningDate: _string(json['learningDate'], format: 'date')!,
      baseRevision: _string(
        json['baseRevision'],
        nullable: true,
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      ),
      operationType: _string(
        json['operationType'],
        allowed: ['library.upsert'],
      )!,
      payload: LibraryPayload.fromJson(_object(json['payload'])),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'operationId': operationId,
    'deviceId': deviceId,
    'deviceSequence': deviceSequence,
    'schemaVersion': schemaVersion,
    'occurredAt': occurredAt,
    'timezone': timezone,
    'learningDate': learningDate,
    'baseRevision': baseRevision,
    'operationType': operationType,
    'payload': payload.toJson(),
  };
}

final class DeleteOperation implements Operation {
  @override
  final String operationId;
  final String deviceId;
  final int deviceSequence;
  final int schemaVersion;
  final String occurredAt;
  final String timezone;
  final String learningDate;
  final String baseRevision;
  final String operationType;
  final DeletePayload payload;
  const DeleteOperation({
    required this.operationId,
    required this.deviceId,
    required this.deviceSequence,
    required this.schemaVersion,
    required this.occurredAt,
    required this.timezone,
    required this.learningDate,
    required this.baseRevision,
    required this.operationType,
    required this.payload,
  });
  factory DeleteOperation.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'operationId',
      'deviceId',
      'deviceSequence',
      'schemaVersion',
      'occurredAt',
      'timezone',
      'learningDate',
      'baseRevision',
      'operationType',
      'payload',
    ]);
    return DeleteOperation(
      operationId: _string(
        json['operationId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      deviceId: _string(
        json['deviceId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      deviceSequence: _integer(
        json['deviceSequence'],
        min: 1,
        max: 9007199254740991,
      ),
      schemaVersion: _integer(json['schemaVersion'], min: 1, max: 1),
      occurredAt: _string(
        json['occurredAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
      timezone: _string(json['timezone'], min: 1, max: 64)!,
      learningDate: _string(json['learningDate'], format: 'date')!,
      baseRevision: _string(
        json['baseRevision'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      operationType: _string(
        json['operationType'],
        allowed: ['library.delete'],
      )!,
      payload: DeletePayload.fromJson(_object(json['payload'])),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'operationId': operationId,
    'deviceId': deviceId,
    'deviceSequence': deviceSequence,
    'schemaVersion': schemaVersion,
    'occurredAt': occurredAt,
    'timezone': timezone,
    'learningDate': learningDate,
    'baseRevision': baseRevision,
    'operationType': operationType,
    'payload': payload.toJson(),
  };
}

abstract interface class Operation implements WireDto {
  String get operationId;
  static Operation fromJson(Map<String, dynamic> json) =>
      switch (json['operationType']) {
        'attempt.record' => AttemptOperation.fromJson(json),
        'library.upsert' => LibraryOperation.fromJson(json),
        'library.delete' => DeleteOperation.fromJson(json),
        _ => throw const FormatException('Unknown discriminator'),
      };
}

final class PushRequest implements WireDto {
  final int schemaVersion;
  final List<Operation> operations;
  const PushRequest({required this.schemaVersion, required this.operations});
  factory PushRequest.fromJson(Map<String, dynamic> json) {
    _fields(json, ['schemaVersion', 'operations']);
    return PushRequest(
      schemaVersion: _integer(json['schemaVersion'], min: 1, max: 1),
      operations: _list(
        json['operations'],
        (value) => Operation.fromJson(_object(value)),
        min: 1,
        max: 100,
        unique: false,
      ),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'operations': operations.map((value) => value.toJson()).toList(),
  };
}

final class LibraryState implements ConflictState {
  final String entityType;
  final String revision;
  final LibraryPayload value;
  const LibraryState({
    required this.entityType,
    required this.revision,
    required this.value,
  });
  factory LibraryState.fromJson(Map<String, dynamic> json) {
    _fields(json, ['entityType', 'revision', 'value']);
    return LibraryState(
      entityType: _string(json['entityType'], allowed: ['library_entry'])!,
      revision: _string(
        json['revision'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      value: LibraryPayload.fromJson(_object(json['value'])),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'entityType': entityType,
    'revision': revision,
    'value': value.toJson(),
  };
}

final class Tombstone implements ConflictState {
  final String entityType;
  final String entryId;
  final String revision;
  final String deletedAt;
  const Tombstone({
    required this.entityType,
    required this.entryId,
    required this.revision,
    required this.deletedAt,
  });
  factory Tombstone.fromJson(Map<String, dynamic> json) {
    _fields(json, ['entityType', 'entryId', 'revision', 'deletedAt']);
    return Tombstone(
      entityType: _string(json['entityType'], allowed: ['tombstone'])!,
      entryId: _string(
        json['entryId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      revision: _string(
        json['revision'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      deletedAt: _string(
        json['deletedAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'entityType': entityType,
    'entryId': entryId,
    'revision': revision,
    'deletedAt': deletedAt,
  };
}

abstract interface class ConflictState implements WireDto {
  static ConflictState fromJson(Map<String, dynamic> json) =>
      switch (json['entityType']) {
        'library_entry' => LibraryState.fromJson(json),
        'tombstone' => Tombstone.fromJson(json),
        _ => throw const FormatException('Unknown discriminator'),
      };
}

final class AppliedAck implements Ack {
  final String operationId;
  final String status;
  final String revision;
  final String? effectiveReviewAt;
  final bool clockAdjusted;
  const AppliedAck({
    required this.operationId,
    required this.status,
    required this.revision,
    required this.effectiveReviewAt,
    required this.clockAdjusted,
  });
  factory AppliedAck.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'operationId',
      'status',
      'revision',
      'effectiveReviewAt',
      'clockAdjusted',
    ]);
    return AppliedAck(
      operationId: _string(
        json['operationId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      status: _string(json['status'], allowed: ['applied'])!,
      revision: _string(
        json['revision'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      effectiveReviewAt: _string(
        json['effectiveReviewAt'],
        nullable: true,
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      ),
      clockAdjusted: _boolean(json['clockAdjusted']),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'operationId': operationId,
    'status': status,
    'revision': revision,
    'effectiveReviewAt': effectiveReviewAt,
    'clockAdjusted': clockAdjusted,
  };
}

final class ConflictAck implements Ack {
  final String operationId;
  final String status;
  final ConflictState serverState;
  const ConflictAck({
    required this.operationId,
    required this.status,
    required this.serverState,
  });
  factory ConflictAck.fromJson(Map<String, dynamic> json) {
    _fields(json, ['operationId', 'status', 'serverState']);
    return ConflictAck(
      operationId: _string(
        json['operationId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      status: _string(json['status'], allowed: ['conflict'])!,
      serverState: ConflictState.fromJson(_object(json['serverState'])),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'operationId': operationId,
    'status': status,
    'serverState': serverState.toJson(),
  };
}

final class RejectedAck implements Ack {
  final String operationId;
  final String status;
  final Problem problem;
  const RejectedAck({
    required this.operationId,
    required this.status,
    required this.problem,
  });
  factory RejectedAck.fromJson(Map<String, dynamic> json) {
    _fields(json, ['operationId', 'status', 'problem']);
    return RejectedAck(
      operationId: _string(
        json['operationId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      status: _string(json['status'], allowed: ['rejected'])!,
      problem: Problem.fromJson(_object(json['problem'])),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'operationId': operationId,
    'status': status,
    'problem': problem.toJson(),
  };
}

abstract interface class Ack implements WireDto {
  static Ack fromJson(Map<String, dynamic> json) => switch (json['status']) {
    'applied' => AppliedAck.fromJson(json),
    'conflict' => ConflictAck.fromJson(json),
    'rejected' => RejectedAck.fromJson(json),
    _ => throw const FormatException('Unknown discriminator'),
  };
}

final class PushResponse implements WireDto {
  final int schemaVersion;
  final String requestId;
  final List<Ack> results;
  const PushResponse({
    required this.schemaVersion,
    required this.requestId,
    required this.results,
  });
  factory PushResponse.fromJson(Map<String, dynamic> json) {
    _fields(json, ['schemaVersion', 'requestId', 'results']);
    return PushResponse(
      schemaVersion: _integer(json['schemaVersion'], min: 1, max: 1),
      requestId: _string(
        json['requestId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      results: _list(
        json['results'],
        (value) => Ack.fromJson(_object(value)),
        min: 1,
        max: 100,
        unique: false,
      ),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'requestId': requestId,
    'results': results.map((value) => value.toJson()).toList(),
  };
}

final class AttemptChange implements Change {
  final String changeType;
  final String eventId;
  final String deviceId;
  final int deviceSequence;
  final String revision;
  final String occurredAt;
  final String receivedAt;
  final String effectiveReviewAt;
  final bool clockAdjusted;
  final String timezone;
  final String learningDate;
  final AttemptPayload value;
  const AttemptChange({
    required this.changeType,
    required this.eventId,
    required this.deviceId,
    required this.deviceSequence,
    required this.revision,
    required this.occurredAt,
    required this.receivedAt,
    required this.effectiveReviewAt,
    required this.clockAdjusted,
    required this.timezone,
    required this.learningDate,
    required this.value,
  });
  factory AttemptChange.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'changeType',
      'eventId',
      'deviceId',
      'deviceSequence',
      'revision',
      'occurredAt',
      'receivedAt',
      'effectiveReviewAt',
      'clockAdjusted',
      'timezone',
      'learningDate',
      'value',
    ]);
    return AttemptChange(
      changeType: _string(json['changeType'], allowed: ['attempt'])!,
      eventId: _string(
        json['eventId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      deviceId: _string(
        json['deviceId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      deviceSequence: _integer(
        json['deviceSequence'],
        min: 1,
        max: 9007199254740991,
      ),
      revision: _string(
        json['revision'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      occurredAt: _string(
        json['occurredAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
      receivedAt: _string(
        json['receivedAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
      effectiveReviewAt: _string(
        json['effectiveReviewAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
      clockAdjusted: _boolean(json['clockAdjusted']),
      timezone: _string(json['timezone'], min: 1, max: 64)!,
      learningDate: _string(json['learningDate'], format: 'date')!,
      value: AttemptPayload.fromJson(_object(json['value'])),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'changeType': changeType,
    'eventId': eventId,
    'deviceId': deviceId,
    'deviceSequence': deviceSequence,
    'revision': revision,
    'occurredAt': occurredAt,
    'receivedAt': receivedAt,
    'effectiveReviewAt': effectiveReviewAt,
    'clockAdjusted': clockAdjusted,
    'timezone': timezone,
    'learningDate': learningDate,
    'value': value.toJson(),
  };
}

final class LibraryChange implements Change {
  final String changeType;
  final String revision;
  final LibraryPayload value;
  const LibraryChange({
    required this.changeType,
    required this.revision,
    required this.value,
  });
  factory LibraryChange.fromJson(Map<String, dynamic> json) {
    _fields(json, ['changeType', 'revision', 'value']);
    return LibraryChange(
      changeType: _string(json['changeType'], allowed: ['library_entry'])!,
      revision: _string(
        json['revision'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      value: LibraryPayload.fromJson(_object(json['value'])),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'changeType': changeType,
    'revision': revision,
    'value': value.toJson(),
  };
}

final class TombstoneChange implements Change {
  final String changeType;
  final String entryId;
  final String revision;
  final String deletedAt;
  const TombstoneChange({
    required this.changeType,
    required this.entryId,
    required this.revision,
    required this.deletedAt,
  });
  factory TombstoneChange.fromJson(Map<String, dynamic> json) {
    _fields(json, ['changeType', 'entryId', 'revision', 'deletedAt']);
    return TombstoneChange(
      changeType: _string(json['changeType'], allowed: ['tombstone'])!,
      entryId: _string(
        json['entryId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      revision: _string(
        json['revision'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      deletedAt: _string(
        json['deletedAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'changeType': changeType,
    'entryId': entryId,
    'revision': revision,
    'deletedAt': deletedAt,
  };
}

final class ProjectionChange implements Change {
  final String changeType;
  final String targetId;
  final String revision;
  final String schedulerVersion;
  final String rulesVersion;
  final String dueAt;
  final List<String> sourceEventIds;
  const ProjectionChange({
    required this.changeType,
    required this.targetId,
    required this.revision,
    required this.schedulerVersion,
    required this.rulesVersion,
    required this.dueAt,
    required this.sourceEventIds,
  });
  factory ProjectionChange.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'changeType',
      'targetId',
      'revision',
      'schedulerVersion',
      'rulesVersion',
      'dueAt',
      'sourceEventIds',
    ]);
    return ProjectionChange(
      changeType: _string(json['changeType'], allowed: ['review_projection'])!,
      targetId: _string(
        json['targetId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      revision: _string(
        json['revision'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      schedulerVersion: _string(
        json['schedulerVersion'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      rulesVersion: _string(
        json['rulesVersion'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 64,
      )!,
      dueAt: _string(
        json['dueAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
      sourceEventIds: _list(
        json['sourceEventIds'],
        (value) => _string(
          value,
          pattern:
              r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          format: 'uuid',
        )!,
        min: 1,
        unique: true,
      ),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'changeType': changeType,
    'targetId': targetId,
    'revision': revision,
    'schedulerVersion': schedulerVersion,
    'rulesVersion': rulesVersion,
    'dueAt': dueAt,
    'sourceEventIds': sourceEventIds,
  };
}

abstract interface class Change implements WireDto {
  static Change fromJson(Map<String, dynamic> json) =>
      switch (json['changeType']) {
        'attempt' => AttemptChange.fromJson(json),
        'library_entry' => LibraryChange.fromJson(json),
        'tombstone' => TombstoneChange.fromJson(json),
        'review_projection' => ProjectionChange.fromJson(json),
        _ => throw const FormatException('Unknown discriminator'),
      };
}

final class PullResponse implements WireDto {
  final int schemaVersion;
  final String requestId;
  final List<Change> changes;
  final String nextCursor;
  final bool hasMore;
  const PullResponse({
    required this.schemaVersion,
    required this.requestId,
    required this.changes,
    required this.nextCursor,
    required this.hasMore,
  });
  factory PullResponse.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'schemaVersion',
      'requestId',
      'changes',
      'nextCursor',
      'hasMore',
    ]);
    return PullResponse(
      schemaVersion: _integer(json['schemaVersion'], min: 1, max: 1),
      requestId: _string(
        json['requestId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      changes: _list(
        json['changes'],
        (value) => Change.fromJson(_object(value)),
        max: 200,
        unique: false,
      ),
      nextCursor: _string(
        json['nextCursor'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 512,
      )!,
      hasMore: _boolean(json['hasMore']),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'requestId': requestId,
    'changes': changes.map((value) => value.toJson()).toList(),
    'nextCursor': nextCursor,
    'hasMore': hasMore,
  };
}

final class SnapshotResponse implements WireDto {
  final int schemaVersion;
  final String requestId;
  final String snapshotId;
  final String checkpoint;
  final String capturedAt;
  final List<Change> changes;
  final String? nextPageToken;
  final String? nextCursor;
  final bool hasMore;
  const SnapshotResponse({
    required this.schemaVersion,
    required this.requestId,
    required this.snapshotId,
    required this.checkpoint,
    required this.capturedAt,
    required this.changes,
    required this.nextPageToken,
    required this.nextCursor,
    required this.hasMore,
  });
  factory SnapshotResponse.fromJson(Map<String, dynamic> json) {
    _fields(json, [
      'schemaVersion',
      'requestId',
      'snapshotId',
      'checkpoint',
      'capturedAt',
      'changes',
      'nextPageToken',
      'nextCursor',
      'hasMore',
    ]);
    return SnapshotResponse(
      schemaVersion: _integer(json['schemaVersion'], min: 1, max: 1),
      requestId: _string(
        json['requestId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      snapshotId: _string(
        json['snapshotId'],
        pattern:
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        format: 'uuid',
      )!,
      checkpoint: _string(
        json['checkpoint'],
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 512,
      )!,
      capturedAt: _string(
        json['capturedAt'],
        pattern:
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
        format: 'date-time',
      )!,
      changes: _list(
        json['changes'],
        (value) => Change.fromJson(_object(value)),
        max: 200,
        unique: false,
      ),
      nextPageToken: _string(
        json['nextPageToken'],
        nullable: true,
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 512,
      ),
      nextCursor: _string(
        json['nextCursor'],
        nullable: true,
        pattern: r'^[A-Za-z0-9_-]+$',
        min: 1,
        max: 512,
      ),
      hasMore: _boolean(json['hasMore']),
    );
  }
  @override
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'requestId': requestId,
    'snapshotId': snapshotId,
    'checkpoint': checkpoint,
    'capturedAt': capturedAt,
    'changes': changes.map((value) => value.toJson()).toList(),
    'nextPageToken': nextPageToken,
    'nextCursor': nextCursor,
    'hasMore': hasMore,
  };
}
