package com.dorriss.no.contract;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import jakarta.validation.Valid;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Null;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.net.URI;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.HashSet;
import java.util.List;

/** Typed sample DTOs for wire-contract tests; not production sync handlers. */
public final class SyncContractSamples {
  private SyncContractSamples() {}

  private static final ObjectMapper JSON =
      JsonMapper.builder()
          .disable(MapperFeature.ALLOW_COERCION_OF_SCALARS)
          .disable(DeserializationFeature.ACCEPT_FLOAT_AS_INT)
          .enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
          .enable(DeserializationFeature.FAIL_ON_TRAILING_TOKENS)
          .build();
  private static final Validator VALIDATOR =
      Validation.buildDefaultValidatorFactory().getValidator();

  static Object decode(String schema, String wire) throws Exception {
    Class<?> type =
        switch (schema) {
          case "PushRequest" -> PushRequest.class;
          case "PushResponse" -> PushResponse.class;
          case "PullResponse" -> PullResponse.class;
          case "SnapshotResponse" -> SnapshotResponse.class;
          case "Problem" -> Problem.class;
          default -> throw new IllegalArgumentException("Unknown fixture schema");
        };
    Object dto = JSON.readValue(wire, type);
    if (!VALIDATOR.validate(dto).isEmpty()) {
      throw new IllegalArgumentException("Invalid contract fields");
    }
    validateFormats(JSON.readTree(wire));
    if (dto instanceof PushRequest request) {
      var ids = new HashSet<String>();
      for (Operation operation : request.operations()) {
        if (!ids.add(operation.operationId())) {
          throw new IllegalArgumentException("Duplicate operation IDs");
        }
      }
    }
    return dto;
  }

  private static void validateFormats(JsonNode node) {
    if (node.isObject()) {
      node.properties()
          .forEach(
              entry -> {
                JsonNode value = entry.getValue();
                if (!value.isNull()) {
                  switch (entry.getKey()) {
                    case "occurredAt",
                        "receivedAt",
                        "effectiveReviewAt",
                        "deletedAt",
                        "dueAt",
                        "capturedAt" ->
                        OffsetDateTime.parse(value.asText());
                    case "learningDate" -> LocalDate.parse(value.asText());
                    case "timezone" -> ZoneId.of(value.asText());
                    case "type" -> {
                      if (!URI.create(value.asText()).isAbsolute()) {
                        throw new IllegalArgumentException("Invalid problem URI");
                      }
                    }
                    default -> {
                      /* Fields without temporal semantics. */
                    }
                  }
                }
                validateFormats(value);
              });
    } else if (node.isArray()) {
      node.forEach(SyncContractSamples::validateFormats);
    }
  }

  public record FieldError(
      @JsonProperty(value = "path", required = true) @NotNull @Size(min = 1) String path,
      @JsonProperty(value = "code", required = true) @NotNull @Size(min = 1) String code) {}

  public record Problem(
      @JsonProperty(value = "type", required = true) @NotNull String type,
      @JsonProperty(value = "title", required = true) @NotNull @Size(min = 1) String title,
      @JsonProperty(value = "status", required = true) @NotNull @Min(400L) @Max(599L) Long status,
      @JsonProperty(value = "detail", required = true) @NotNull @Size(min = 1) String detail,
      @JsonProperty(value = "code", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "(UNAUTHENTICATED|TOKEN_EXPIRED|FORBIDDEN|"
                      + "CURSOR_ACCOUNT_MISMATCH|INVALID_CURSOR|CURSOR_EXPIRED|"
                      + "SNAPSHOT_EXPIRED|VALIDATION_FAILED|UNSUPPORTED_SCHEMA_VERSION|"
                      + "UNSUPPORTED_OPERATION|OPERATION_ID_REUSED|OPERATION_IN_PROGRESS|"
                      + "ENTITY_DELETED|RATE_LIMITED|PAYLOAD_TOO_LARGE|"
                      + "TEMPORARILY_UNAVAILABLE)")
          String code,
      @JsonProperty(value = "requestId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String requestId,
      @JsonProperty(value = "retryable", required = true) @NotNull Boolean retryable,
      @JsonProperty(value = "fieldErrors", required = true) @NotNull @Valid
          List<FieldError> fieldErrors) {}

  public record AttemptPayload(
      @JsonProperty(value = "attemptId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String attemptId,
      @JsonProperty(value = "sessionId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String sessionId,
      @JsonProperty(value = "targetId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String targetId,
      @JsonProperty(value = "contentRevision", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String contentRevision,
      @JsonProperty(value = "targetType", required = true)
          @NotNull
          @Pattern(regexp = "(meaning_recall|pattern_recall)")
          String targetType,
      @JsonProperty(value = "attemptKind", required = true)
          @NotNull
          @Pattern(regexp = "(review|practice|delayed_probe)")
          String attemptKind,
      @JsonProperty(value = "outcome", required = true)
          @NotNull
          @Pattern(regexp = "(correct|incorrect|assisted)")
          String outcome,
      @JsonProperty(value = "hintCount", required = true) @NotNull @Min(0L) @Max(100L)
          Long hintCount,
      @JsonProperty(value = "rulesVersion", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String rulesVersion) {}

  public record LibraryPayload(
      @JsonProperty(value = "entryId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String entryId,
      @JsonProperty(value = "sense", required = true) @NotNull @Size(min = 1, max = 1000)
          String sense,
      @JsonProperty(value = "usagePattern", required = true) @NotNull @Size(min = 1, max = 500)
          String usagePattern,
      @JsonProperty(value = "note", required = true) @Size(max = 2000) String note) {}

  public record DeletePayload(
      @JsonProperty(value = "entryId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String entryId) {}

  public record AttemptOperation(
      @JsonProperty(value = "operationId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String operationId,
      @JsonProperty(value = "deviceId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String deviceId,
      @JsonProperty(value = "deviceSequence", required = true)
          @NotNull
          @Min(1L)
          @Max(9007199254740991L)
          Long deviceSequence,
      @JsonProperty(value = "schemaVersion", required = true) @NotNull @Min(1) @Max(1)
          Long schemaVersion,
      @JsonProperty(value = "occurredAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String occurredAt,
      @JsonProperty(value = "timezone", required = true) @NotNull @Size(min = 1, max = 64)
          String timezone,
      @JsonProperty(value = "learningDate", required = true) @NotNull String learningDate,
      @JsonProperty(value = "baseRevision", required = true) @Null String baseRevision,
      @JsonProperty(value = "operationType", required = true)
          @NotNull
          @Pattern(regexp = "(attempt.record)")
          String operationType,
      @JsonProperty(value = "payload", required = true) @NotNull @Valid AttemptPayload payload)
      implements Operation {}

  public record LibraryOperation(
      @JsonProperty(value = "operationId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String operationId,
      @JsonProperty(value = "deviceId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String deviceId,
      @JsonProperty(value = "deviceSequence", required = true)
          @NotNull
          @Min(1L)
          @Max(9007199254740991L)
          Long deviceSequence,
      @JsonProperty(value = "schemaVersion", required = true) @NotNull @Min(1) @Max(1)
          Long schemaVersion,
      @JsonProperty(value = "occurredAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String occurredAt,
      @JsonProperty(value = "timezone", required = true) @NotNull @Size(min = 1, max = 64)
          String timezone,
      @JsonProperty(value = "learningDate", required = true) @NotNull String learningDate,
      @JsonProperty(value = "baseRevision", required = true)
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String baseRevision,
      @JsonProperty(value = "operationType", required = true)
          @NotNull
          @Pattern(regexp = "(library.upsert)")
          String operationType,
      @JsonProperty(value = "payload", required = true) @NotNull @Valid LibraryPayload payload)
      implements Operation {}

  public record DeleteOperation(
      @JsonProperty(value = "operationId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String operationId,
      @JsonProperty(value = "deviceId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String deviceId,
      @JsonProperty(value = "deviceSequence", required = true)
          @NotNull
          @Min(1L)
          @Max(9007199254740991L)
          Long deviceSequence,
      @JsonProperty(value = "schemaVersion", required = true) @NotNull @Min(1) @Max(1)
          Long schemaVersion,
      @JsonProperty(value = "occurredAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String occurredAt,
      @JsonProperty(value = "timezone", required = true) @NotNull @Size(min = 1, max = 64)
          String timezone,
      @JsonProperty(value = "learningDate", required = true) @NotNull String learningDate,
      @JsonProperty(value = "baseRevision", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String baseRevision,
      @JsonProperty(value = "operationType", required = true)
          @NotNull
          @Pattern(regexp = "(library.delete)")
          String operationType,
      @JsonProperty(value = "payload", required = true) @NotNull @Valid DeletePayload payload)
      implements Operation {}

  @JsonTypeInfo(
      use = JsonTypeInfo.Id.NAME,
      include = JsonTypeInfo.As.EXISTING_PROPERTY,
      property = "operationType",
      visible = true)
  @JsonSubTypes({
    @JsonSubTypes.Type(value = AttemptOperation.class, name = "attempt.record"),
    @JsonSubTypes.Type(value = LibraryOperation.class, name = "library.upsert"),
    @JsonSubTypes.Type(value = DeleteOperation.class, name = "library.delete")
  })
  public sealed interface Operation permits AttemptOperation, LibraryOperation, DeleteOperation {
    String operationId();
  }

  public record PushRequest(
      @JsonProperty(value = "schemaVersion", required = true) @NotNull @Min(1) @Max(1)
          Long schemaVersion,
      @JsonProperty(value = "operations", required = true) @NotNull @Valid @Size(min = 1, max = 100)
          List<Operation> operations) {}

  public record LibraryState(
      @JsonProperty(value = "entityType", required = true)
          @NotNull
          @Pattern(regexp = "(library_entry)")
          String entityType,
      @JsonProperty(value = "revision", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String revision,
      @JsonProperty(value = "value", required = true) @NotNull @Valid LibraryPayload value)
      implements ConflictState {}

  public record Tombstone(
      @JsonProperty(value = "entityType", required = true) @NotNull @Pattern(regexp = "(tombstone)")
          String entityType,
      @JsonProperty(value = "entryId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String entryId,
      @JsonProperty(value = "revision", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String revision,
      @JsonProperty(value = "deletedAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String deletedAt)
      implements ConflictState {}

  @JsonTypeInfo(
      use = JsonTypeInfo.Id.NAME,
      include = JsonTypeInfo.As.EXISTING_PROPERTY,
      property = "entityType",
      visible = true)
  @JsonSubTypes({
    @JsonSubTypes.Type(value = LibraryState.class, name = "library_entry"),
    @JsonSubTypes.Type(value = Tombstone.class, name = "tombstone")
  })
  public sealed interface ConflictState permits LibraryState, Tombstone {}

  public record AppliedAck(
      @JsonProperty(value = "operationId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String operationId,
      @JsonProperty(value = "status", required = true) @NotNull @Pattern(regexp = "(applied)")
          String status,
      @JsonProperty(value = "revision", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String revision,
      @JsonProperty(value = "effectiveReviewAt", required = true)
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String effectiveReviewAt,
      @JsonProperty(value = "clockAdjusted", required = true) @NotNull Boolean clockAdjusted)
      implements Ack {}

  public record ConflictAck(
      @JsonProperty(value = "operationId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String operationId,
      @JsonProperty(value = "status", required = true) @NotNull @Pattern(regexp = "(conflict)")
          String status,
      @JsonProperty(value = "serverState", required = true) @NotNull @Valid
          ConflictState serverState)
      implements Ack {}

  public record RejectedAck(
      @JsonProperty(value = "operationId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String operationId,
      @JsonProperty(value = "status", required = true) @NotNull @Pattern(regexp = "(rejected)")
          String status,
      @JsonProperty(value = "problem", required = true) @NotNull @Valid Problem problem)
      implements Ack {}

  @JsonTypeInfo(
      use = JsonTypeInfo.Id.NAME,
      include = JsonTypeInfo.As.EXISTING_PROPERTY,
      property = "status",
      visible = true)
  @JsonSubTypes({
    @JsonSubTypes.Type(value = AppliedAck.class, name = "applied"),
    @JsonSubTypes.Type(value = ConflictAck.class, name = "conflict"),
    @JsonSubTypes.Type(value = RejectedAck.class, name = "rejected")
  })
  public sealed interface Ack permits AppliedAck, ConflictAck, RejectedAck {}

  public record PushResponse(
      @JsonProperty(value = "schemaVersion", required = true) @NotNull @Min(1) @Max(1)
          Long schemaVersion,
      @JsonProperty(value = "requestId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String requestId,
      @JsonProperty(value = "results", required = true) @NotNull @Valid @Size(min = 1, max = 100)
          List<Ack> results) {}

  public record AttemptChange(
      @JsonProperty(value = "changeType", required = true) @NotNull @Pattern(regexp = "(attempt)")
          String changeType,
      @JsonProperty(value = "eventId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String eventId,
      @JsonProperty(value = "deviceId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String deviceId,
      @JsonProperty(value = "deviceSequence", required = true)
          @NotNull
          @Min(1L)
          @Max(9007199254740991L)
          Long deviceSequence,
      @JsonProperty(value = "revision", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String revision,
      @JsonProperty(value = "occurredAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String occurredAt,
      @JsonProperty(value = "receivedAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String receivedAt,
      @JsonProperty(value = "effectiveReviewAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String effectiveReviewAt,
      @JsonProperty(value = "clockAdjusted", required = true) @NotNull Boolean clockAdjusted,
      @JsonProperty(value = "timezone", required = true) @NotNull @Size(min = 1, max = 64)
          String timezone,
      @JsonProperty(value = "learningDate", required = true) @NotNull String learningDate,
      @JsonProperty(value = "value", required = true) @NotNull @Valid AttemptPayload value)
      implements Change {}

  public record LibraryChange(
      @JsonProperty(value = "changeType", required = true)
          @NotNull
          @Pattern(regexp = "(library_entry)")
          String changeType,
      @JsonProperty(value = "revision", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String revision,
      @JsonProperty(value = "value", required = true) @NotNull @Valid LibraryPayload value)
      implements Change {}

  public record TombstoneChange(
      @JsonProperty(value = "changeType", required = true) @NotNull @Pattern(regexp = "(tombstone)")
          String changeType,
      @JsonProperty(value = "entryId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String entryId,
      @JsonProperty(value = "revision", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String revision,
      @JsonProperty(value = "deletedAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String deletedAt)
      implements Change {}

  public record ProjectionChange(
      @JsonProperty(value = "changeType", required = true)
          @NotNull
          @Pattern(regexp = "(review_projection)")
          String changeType,
      @JsonProperty(value = "targetId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String targetId,
      @JsonProperty(value = "revision", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String revision,
      @JsonProperty(value = "schedulerVersion", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String schedulerVersion,
      @JsonProperty(value = "rulesVersion", required = true)
          @NotNull
          @Size(min = 1, max = 64)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String rulesVersion,
      @JsonProperty(value = "dueAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String dueAt,
      @JsonProperty(value = "sourceEventIds", required = true) @NotNull @Valid @Size(min = 1)
          List<String> sourceEventIds)
      implements Change {}

  @JsonTypeInfo(
      use = JsonTypeInfo.Id.NAME,
      include = JsonTypeInfo.As.EXISTING_PROPERTY,
      property = "changeType",
      visible = true)
  @JsonSubTypes({
    @JsonSubTypes.Type(value = AttemptChange.class, name = "attempt"),
    @JsonSubTypes.Type(value = LibraryChange.class, name = "library_entry"),
    @JsonSubTypes.Type(value = TombstoneChange.class, name = "tombstone"),
    @JsonSubTypes.Type(value = ProjectionChange.class, name = "review_projection")
  })
  public sealed interface Change
      permits AttemptChange, LibraryChange, TombstoneChange, ProjectionChange {}

  public record PullResponse(
      @JsonProperty(value = "schemaVersion", required = true) @NotNull @Min(1) @Max(1)
          Long schemaVersion,
      @JsonProperty(value = "requestId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String requestId,
      @JsonProperty(value = "changes", required = true) @NotNull @Valid @Size(max = 200)
          List<Change> changes,
      @JsonProperty(value = "nextCursor", required = true)
          @NotNull
          @Size(min = 1, max = 512)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String nextCursor,
      @JsonProperty(value = "hasMore", required = true) @NotNull Boolean hasMore) {}

  public record SnapshotResponse(
      @JsonProperty(value = "schemaVersion", required = true) @NotNull @Min(1) @Max(1)
          Long schemaVersion,
      @JsonProperty(value = "requestId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String requestId,
      @JsonProperty(value = "snapshotId", required = true)
          @NotNull
          @Pattern(regexp = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
          String snapshotId,
      @JsonProperty(value = "checkpoint", required = true)
          @NotNull
          @Size(min = 1, max = 512)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String checkpoint,
      @JsonProperty(value = "capturedAt", required = true)
          @NotNull
          @Pattern(
              regexp =
                  "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?(Z|[+-]\\d{2}:\\d{2})$")
          String capturedAt,
      @JsonProperty(value = "changes", required = true) @NotNull @Valid @Size(max = 200)
          List<Change> changes,
      @JsonProperty(value = "nextPageToken", required = true)
          @Size(min = 1, max = 512)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String nextPageToken,
      @JsonProperty(value = "nextCursor", required = true)
          @Size(min = 1, max = 512)
          @Pattern(regexp = "^[A-Za-z0-9_-]+$")
          String nextCursor,
      @JsonProperty(value = "hasMore", required = true) @NotNull Boolean hasMore) {}
}
