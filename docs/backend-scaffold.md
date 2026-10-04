# Backend scaffold Nở — evidence

Ngày kiểm chứng: 2026-10-04, worktree Init-Spring-Backend. Chủ dự án duyệt layout/stack theo Vey và bật toàn bộ hạ tầng local. Đây là evidence scaffold, không phải evidence toàn bộ MVP.

## Đầu ra

- `api/`: Java 25, Spring Boot 3.5.16, Maven Wrapper 3.9.14; một project/JAR, package `com.dorriss.no`.
- MVC, Validation, JPA, PostgreSQL/Flyway, Redis, Kafka, S3 SDK, JobRunr, Lombok/MapStruct, UUID utilities, Swagger/Actuator.
- `common`, `infrastructure`, vị trí `modules` theo feature; chưa tạo domain modules rỗng. ArchUnit hiện enforce common/infrastructure không phụ thuộc modules; rules liên business module sẽ bổ sung khi có feature thật.
- Compose root: API, PostgreSQL 18.6, Redis 7.4.6, Kafka 3.9.1, MinIO, Kafka UI, Dozzle, bucket initializer. Port local riêng so với Vey; host bindings ở localhost, volumes giữ dữ liệu.
- Flyway V1 tạo schema `jobs`; JobRunr 8.4.2 sở hữu table migrations bên trong schema. JPA chỉ validate schema.
- Makefile, optional pre-commit, Spotless/Checkstyle/JaCoCo, GitHub workflow kiểm tra/build; không có bước publish/deploy.
- `contracts/openapi.yaml`: health scaffold. Swagger local dùng operation/schema tương ứng. Sync/error/private contract thuộc NO-003.
- `frontend/README.md` chỉ xác định vị trí Flutter/Drift theo layout; chưa có mobile app.

## Commands và kết quả đã chạy

| Kiểm tra | Kết quả |
|---|---|
| `./api/mvnw -f api/pom.xml -B -ntp verify` | BUILD SUCCESS; 1 architecture test + 8 integration tests, không fail/error/skip; lần cuối 57.394 giây |
| Spotless/Checkstyle trong verify | Pass, 0 style violations |
| Testcontainers PostgreSQL | DB mới migrate V1; history thành công một lần; JobRunr tables đúng schema jobs |
| Flyway fixture | Migrate lần đầu = 1, lần sau = 0; sửa checksum bị validate/migrate từ chối; history còn nguyên |
| Testcontainers Redis | Set/get, TTL dương, xóa fixture |
| Testcontainers Kafka | Adapter publish và consumer đọc lại key/payload qua broker thật |
| Testcontainers MinIO/S3 | Bucket riêng, put/get đúng bytes UTF-8, delete và xác nhận NoSuchKey; cleanup |
| JobRunr fixture | Dừng worker, enqueue và đọc ENQUEUED từ DB; worker start lại, lần đầu lỗi chủ đích, retry → SUCCEEDED, attempts = 2 |
| `uvx --from openapi-spec-validator==0.7.2 openapi-spec-validator contracts/openapi.yaml` | OK |
| `docker compose config --quiet` | Pass |
| `make infra` | Hạ tầng healthy; one-shot bucket initializer exit 0 |
| `docker compose --profile app up -d --build` | Image build và API start thành công; API healthy |
| `docker compose exec -T api id` | UID/GID 10001, non-root |
| `docker compose exec -T api java -version` | Temurin 25.0.4.1+1-LTS |
| Runtime host JAR/profile local | Health/readiness/liveness 200; Swagger operation getHealth và HealthResponse khớp contract; process smoke ở port 8083 đã dừng |
| HTTP stack local | API health, OpenAPI, Kafka UI, Dozzle, MinIO console trả 200 |
| `pre-commit validate-config`, `bash -n scripts/*.sh`, `git diff --check` | Pass |

Manual DB failure/recovery: tạo schema/table fixture riêng, dừng PostgreSQL, host liveness trả 200/UP, readiness trả 503/DOWN. Start PostgreSQL: readiness về 200/UP; fixture còn 1 row và V1 history còn 1 lần thành công. Fixture được xóa sau kiểm tra. API container sau đó khởi động lại với cùng DB/volume và validate V1; không chạy lại migration.

## Điều chỉnh khi kiểm chứng reference

- YAML khóa `no` phải quote để tránh được parse thành boolean; configuration binding S3 đã kiểm chứng bằng integration/runtime.
- JobRunr 8.4.2 dùng prefix `jobrunr`; prefix `org.jobrunr` trong Vey không bật worker. Scaffold đã dùng namespace đúng, table-prefix `jobs.` và kiểm chứng job thật.
- Giới hạn default workers = 2 qua `NO_JOB_WORKERS`; tránh default theo CPU tạo 256 workers trên máy này. Container log xác nhận 2 workers.
- Loại commons-logging transitive từ AWS SDK để dùng logging bridge của Spring.
- Docker giữ cache Maven, build/package trực tiếp; không prefetch toàn bộ plugin bằng dependency:go-offline. Image build skip tests; verify được chạy riêng trước đó.

## Trạng thái và giới hạn

Kaneo REST trả 403 khi đọc Bloom/NO-002 ngày 2026-10-04; chưa sửa scope/status task live, không đánh dấu Done hoặc đổi publication mapping. Scope mở rộng được lưu trong plan để đối chiếu khi kết nối lại. GitHub CI chỉ mới có workflow; chưa khẳng định đã chạy trên GitHub. Git hooks chỉ mới validate cấu hình, không tự install vào worktree.

Chưa triển khai identity/auth, sync handlers/server outbox, FSRS, content schema hoặc domain APIs. Kafka producer idempotence không thay thế transactional outbox/dedupe theo account. Bộ kiểm chứng này không chứng minh học offline trên thiết bị; đó là gate mobile riêng. JobRunr test chứng minh lưu job và worker stop/start/retry trong test process; chưa phải test crash/restart toàn JVM giữa một domain operation.

Stack Docker local được giữ đang chạy để tiếp tục phát triển; dừng bằng `make stop`, volumes được giữ. Không deploy/public/publish hoặc push. Hướng dẫn đầy đủ ở [API README](../api/README.md).

## Hợp nhất với Flutter scaffold

Sau merge main, code Flutter NO-001 được chuyển từ `apps/mobile/` sang `frontend/` theo layout đã chốt. `frontend/README.md` hiện là hướng dẫn chạy thật, thay cho placeholder ở thời điểm kiểm chứng backend ban đầu. Source Flutter và các yêu cầu dùng điện thoại thật được giữ nguyên.

Backend sau hợp nhất: `cd api && ./mvnw -B -ntp verify` đạt BUILD SUCCESS, 9 tests không fail/error/skip, Spotless/Checkstyle đạt (45.292 giây). Flutter format/analyze, 6 tests và hai APK ARM64 debug dev/staging cũng đạt tại `frontend/`; xem evidence NO-001 cho giới hạn device testing của lượt merge.
