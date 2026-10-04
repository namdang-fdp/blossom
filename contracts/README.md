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

## Pull và phục hồi snapshot

`GET /api/v1/sync/pull?cursor=…&pageSize=…`: pageSize 1–200, mặc định 100. Không cursor bắt đầu từ đầu stream còn retained; nếu lịch sử đã prune, trả CURSOR_EXPIRED để tải snapshot. nextCursor luôn có (kể cả empty page); hasMore cho biết còn page tại thời điểm đọc. Sau page cuối tiếp tục poll nextCursor để nhận changes mới. Cursor là token opaque scoped theo account, không dựa UUID/revision để suy thứ tự. INVALID_CURSOR/400 khác CURSOR_EXPIRED/409 và CURSOR_ACCOUNT_MISMATCH/403. Không cursor account A trong request account B.

Changes typed: attempt append-only với original/effective/received time, library_entry có nghĩa/mẫu, tombstone, review_projection tối thiểu (dueAt, scheduler/rules version, sourceEventIds). Fixture dueAt là giá trị wire tổng hợp, không phải kết quả FSRS đã tính. State FSRS đầy đủ thuộc contract revision sau NO-004; không tuyên bố projection mẫu đủ khôi phục scheduler khi chưa chốt parity.

`GET /api/v1/sync/snapshot` không pageToken tạo immutable snapshot tại checkpoint C. Snapshot giữ nguyên snapshotId/checkpoint/capturedAt qua mọi page, gồm canonical attempts, library, tombstones và projections tại C. pageToken ràng buộc account, snapshot, vị trí và pageSize; thay pageSize giữa chừng bị từ chối. Snapshot sống tối thiểu 24 giờ; server không prune stream sau C trong thời hạn snapshot. Nếu không giữ được checkpoint trả SNAPSHOT_EXPIRED/409 và bắt đầu lại, không trộn hai snapshot. CURSOR_EXPIRED không tự cho phép xóa local profile.

- Page chưa cuối: hasMore=true, nextPageToken có giá trị, nextCursor=null.
- Page cuối: hasMore=false, nextPageToken=null, nextCursor=checkpoint.
- Changes sau C không chui vào snapshot page sau; pull(checkpoint) trả đủ chúng, kể cả delete giữa hai page. Fixture snapshot-resume minh họa thay đổi phát sinh khi snapshot đang tải.

Client stage các page theo snapshotId, commit từng page+token atomically để resume sau kill. Khi đủ pages, swap canonical dataset+cursor trong transaction, giữ toàn bộ outbox/pending attempts/conflicts đúng profile rồi replay/rebase pending trên canonical projection. Không reset outbox khi snapshot. Pull cũng áp dụng page+cursor cùng transaction; duplicate page/event UUID không tăng history/credit. Recovery path: CURSOR_EXPIRED → snapshot-first → snapshot-last → pull(checkpoint). Nếu mạng hoặc auth ngắt giữa chừng, giữ stage và pending; snapshot expired mới bắt đầu stage mới.

Fixture/schema chỉ chứng minh wire shape và các kỳ vọng của protocol; identity scope, snapshot isolation, PostgreSQL transactions và replay convergence phải có integration evidence ở task runtime tương ứng.

### Commands tái lập sau implementation

Python tools có dependencies + transitive lock tại `contracts/tools/uv.lock`; `jsonschema[format]` được pin để URI và các format không bị âm thầm bỏ qua do thiếu optional validators. Dùng uv 0.12.19 như CI.

```sh
# Root: OpenAPI, toàn corpus và protocol expectations
uv run --locked --project contracts/tools python contracts/tools/validate_fixtures.py
uv run --locked --project contracts/tools python -m unittest discover -s contracts/tools -p 'test_*.py'
# api/: Maven copy cùng fixtures lên test classpath
./mvnw -B -ntp -Dtest=SyncContractTest test
./mvnw -B -ntp verify
# apps/mobile/: đọc corpus relative tới app root
fvm flutter test test/contracts/sync_contract_test.dart
fvm flutter analyze
fvm flutter test
```

Mỗi case fixture có name/schema/valid/body; negative case thêm errorPath. Response case ghi method/path/status/headers; runner đối chiếu schema đúng endpoint. Push scenario ghi requestCase/acknowledged/pending/replayOf; snapshot ghi previousPage/snapshotPage. Runner kiểm tra expected invariants của dữ liệu mẫu, không mô phỏng handler hoặc giả DB idempotency đã chạy. Java dùng Jackson records + Bean Validation; Dart dùng typed DTO/union + format checks, giữ nguyên timestamp text khi serialize. IANA timezone lookup được runner/Java kiểm chứng; Dart wire DTO giữ tên timezone, domain adapter sẽ kiểm chứng timezone khi feature dùng nó.

Evidence và giới hạn: [NO-003](../docs/evidence/NO-003.md). Java scalar coercion bị tắt để không nhận `"1"`/`1.5` làm integer; Dart kiểm tra calendar date và time components trước DateTime parse để không normalize dữ liệu sai.
