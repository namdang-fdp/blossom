# Hợp đồng đồng bộ Nở v1 — NO-003

`openapi.yaml` là canonical OpenAPI 3.0.3, API version 0.1.0, envelope schemaVersion 1. Health đã chạy; sync endpoints **chưa có handler**. DTO mẫu nằm trong test support, chưa gắn vào HTTP client/server. Fixtures dùng dữ liệu tổng hợp.

## Push và ack

`POST /api/v1/sync/push` cần bearer identity đã xác minh. Không có `userId` trong request; trường lạ bị từ chối, kể cả trong payload. Ownership của object/cursor phải kiểm tra theo account của token (NO-026). Account B không đọc/ack outbox của A. Guest chưa link chỉ giữ local.

Body tối đa 256 KiB UTF-8, 1–100 operations. `operationId` UUID lowercase do client cấp một lần sau local commit; không đổi khi retry. `deviceId` UUID ổn định trong profile thiết bị, `deviceSequence` tăng trong thiết bị; số nguyên từ 1 tới 2^53−1 để hai runtime giữ chính xác. ID khác nhau bắt buộc cho ý định khác nhau. ID không lặp trong cùng batch; lỗi cấu trúc hoặc version làm cả request HTTP 422, không áp dụng item nào. Body quá lớn HTTP 413. Domain error từng item trả trong HTTP 200.

| operationType | Payload | baseRevision |
|---|---|---|
| `attempt.record` | Attempt/session/target UUID, contentRevision, targetType meaning/pattern, review/practice/delayed_probe, outcome và hintCount, rulesVersion | Bắt buộc `null`: append-only |
| `library.upsert` | entryId, sense, usagePattern, note | `null` tạo mới; revision đã đọc để sửa |
| `library.delete` | entryId | Revision đã đọc, không null |

Đây là tập typed payload đầu tiên để kiểm chứng envelope, chưa hứa toàn bộ sync features MVP. Preferences, draft fork, guest migration và daily credit mở rộng qua contract version khi task tương ứng chốt domain. Không nhận raw recording, AI grade, scheduler dueAt từ client. Attempt dùng rulesVersion, không tự chọn FSRS parameter/grade mapping của NO-004. UUID attempt giữ nguyên khi import guest; event log canonical không last-write-wins.

Revision là opaque token 1–64 ký tự `[A-Za-z0-9_-]`; không parse hay so sánh lớn/nhỏ trên client. `null` và thiếu field khác nhau: baseRevision và note bắt buộc hiện diện; note null là xóa ghi chú. Tạo mới trùng entity đang có trả conflict; update/delete base cũ trả conflict. Tombstone không cho update cũ hồi sinh; khôi phục cần ý định mới có xác nhận ở feature sau.

Kết quả đủ một item mỗi operationId, cùng thứ tự request. Chỉ `status=applied` cho phép mark ack trong local transaction. `conflict` giữ payload local và serverState để người dùng chọn; `rejected` giữ event cùng problem, không xóa âm thầm. Thiếu/ID lạ/trùng trong response là protocol error: không ack item liên quan và báo lỗi. Không xóa cả batch chỉ vì HTTP 200. Item conflict/permanent error có thể bị chuyển sang hàng chờ xử lý, không retry loop vô hạn; dependent operations chờ prerequisite. Item lỗi không chặn item độc lập trong batch.

Idempotency authoritative là `(verified account, operationId)`, không Redis/Kafka. Compare canonical operation gồm metadata và payload (bỏ key order); cùng ID khác body trả item rejected `OPERATION_ID_REUSED`/422, không thực hiện lại. Claim, domain mutation và stored result atomic trong PostgreSQL (NO-028/029). Khi đang in-flight trả item rejected `OPERATION_IN_PROGRESS`/409 retryable; chưa lưu terminal ack này làm kết quả vĩnh viễn. Sau commit retry trả **nguyên item result gốc**, kể cả effectiveReviewAt/revision/conflict; không đổi sang status duplicate. `requestId` top-level có thể đổi. Applied và terminal conflict/rejection lưu cùng intent; transient rejection chỉ retry, không đóng intent. Giữ dedupe/result và tombstones suốt MVP; không TTL tùy tiện trên đường offline dài ngày.

`occurredAt` có offset, tối đa microseconds; lưu thời điểm gốc. `learningDate` là ngày lúc học và timezone IANA lúc đó (timezone phải kiểm chứng domain, không chỉ regex). Server chuẩn hóa effectiveReviewAt không lùi theo deviceSequence, clamp tương lai quá 5 phút và gắn clockAdjusted; tổng thứ tự `(effectiveReviewAt, deviceId, deviceSequence, eventId)` theo offline-sync. Applied attempt trả effectiveReviewAt; mutation khác trả null. Retry không đổi ngày/credit. Raw offset giữ trong wire DTO để round-trip không mất thông tin.

## Lỗi toàn request

Problem Details dùng `application/problem+json`: type URI (`urn:no:problem:…`), title/detail tiếng Việt, status khớp HTTP, code ổn định, requestId, retryable và fieldErrors path/code. Không echo token, input riêng tư hoặc recording. Machine logic dùng code, không parse title/detail. Problem code mới/version mới phải được contract và hai consumer kiểm chứng.

| HTTP | Code / hành vi |
|---|---|
| 400 | INVALID_CURSOR hoặc VALIDATION_FAILED: query/JSON hỏng |
| 401 | UNAUTHENTICATED / TOKEN_EXPIRED, WWW-Authenticate: Bearer; giữ queue, cần login lại khi online |
| 403 | FORBIDDEN / CURSOR_ACCOUNT_MISMATCH; không lộ dữ liệu account khác |
| 409 | CURSOR_EXPIRED / SNAPSHOT_EXPIRED; full resync, không xóa pending |
| 413 | PAYLOAD_TOO_LARGE; chia batch giữ UUID |
| 422 | VALIDATION_FAILED / UNSUPPORTED_SCHEMA_VERSION / UNSUPPORTED_OPERATION |
| 429 | RATE_LIMITED, Retry-After là số giây dương; jitter/backoff có giới hạn |
| 503 | TEMPORARILY_UNAVAILABLE; retry giữ cùng operationId |

Không response hoặc timeout là kết quả chưa biết: giữ queue và retry cùng intent. 401/403 hoặc lỗi schema không tự retry vô hạn. Client học local vẫn hoạt động khi token hết hạn.

## Compatibility và kiểm chứng

Schema v1 đóng trường để phát hiện userId giả/typo, typed discriminator có oneOf. Thêm operation hoặc trường wire cần schemaVersion mới + fixtures/consumer compatibility; server giữ v1 cho pending intents dài ngày hoặc có migration bảo toàn UUID/payload/result. Không sửa semantics của version đã phát hành hoặc rewrite pending operation cùng ID. URL major thay đổi nếu không thể hỗ trợ version envelope cũ; content revisions độc lập và immutable.

```sh
# Từ root
uvx --from openapi-spec-validator==0.7.2 openapi-spec-validator contracts/openapi.yaml
```

Nguồn thiết kế: [OpenAPI 3.0.3](https://spec.openapis.org/oas/v3.0.3.html), [Problem Details RFC 9457](https://www.rfc-editor.org/rfc/rfc9457.html), [jsonschema format validation](https://python-jsonschema.readthedocs.io/en/stable/validate/). Quy tắc dữ liệu authoritative nằm ở `docs/offline-sync.md`.
