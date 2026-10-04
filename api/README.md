# Nở API

Java 25, Spring Boot 3.5.16, Maven 3.9.14 qua wrapper. Một Maven project/JAR, package root `com.dorriss.no`. Layout và tooling theo Vey.

## Local

Từ root chạy `make infra`; sau đó từ `api/`:

```sh
SPRING_PROFILES_ACTIVE=local ./mvnw spring-boot:run
```

Profile `local` có credential dev và Swagger. Default profile yêu cầu env rõ ràng cho datasource, Redis, Kafka, S3; không chứa fallback credential production. JobRunr dashboard tắt. Default 2 workers, chỉnh qua `NO_JOB_WORKERS`. Các env chính được liệt kê trong `application.yaml`.

| Service | Port trên host |
|---|---|
| API | 8082 |
| PostgreSQL | 56432 |
| Redis | 57379 |
| Kafka | 60092 |
| Kafka UI | 61080 |
| MinIO API / console | 60000 / 60001 |
| Dozzle | 61081 |

`.env` ở root chỉ được Compose đọc. Nếu đổi port hoặc credential trong Compose, hãy export các biến `SPRING_DATASOURCE_*`, `SPRING_DATA_REDIS_*`, `SPRING_KAFKA_BOOTSTRAP_SERVERS`, `NO_STORAGE_*` tương ứng trước khi chạy JVM. API trong Compose đã nhận env qua service configuration.

`make app` chạy API và hạ tầng trong Docker; bucket `no-media` được tạo bởi one-shot `minio-init`. Chờ health API trong `docker compose ps`. `make stop` dừng stack, giữ volumes. Không chạy `down -v` nếu muốn giữ dữ liệu. Dozzle chỉ local và đọc Docker socket để xem log.

MinIO và `mc` được đóng image local từ binary GitHub Releases chính thức, giữ phiên bản đã pin và xác minh SHA-256 cho AMD64/ARM64. Compose và Testcontainers cùng dùng `infra/minio/Dockerfile`; lần build đầu cần mạng tới Docker Hub (Alpine), Alpine packages và GitHub Releases. Không còn pull `minio/minio` hoặc `minio/mc` từ registry đã ngừng phục vụ các image này.

## Build/test

```sh
./mvnw -B -ntp test
./mvnw -B -ntp verify
./mvnw -B -ntp spotless:apply
```

`test`: ArchUnit. `verify`: thêm Failsafe `*IT`, PostgreSQL/Flyway/health, Redis expiry, Kafka publisher, S3 bytes/delete và JobRunr job retry. Testcontainers dùng ports ngẫu nhiên và fixtures riêng; không dùng credential hay dữ liệu cá nhân. JaCoCo report ở `target/site/jacoco`. Không bỏ qua tests khi xác nhận task hoàn tất. Dockerfile package bỏ tests vì CI đã chạy `verify`; image build không thay thế verification.

Validate OpenAPI từ root (cần `uv`, hoặc CLI tương ứng đã cài):

```sh
uvx --from openapi-spec-validator==0.7.2 openapi-spec-validator contracts/openapi.yaml
```

## Boundaries và migration

- `common` và `infrastructure` không phụ thuộc `modules`; ArchUnit kiểm tra production classes thực.
- Business modules được tạo khi có feature thật. Gọi module khác qua public interface; không import entity/repository nội bộ. Khi có modules, bổ sung ArchUnit rules cụ thể cho public interfaces.
- JPA `ddl-auto=validate`, `open-in-view=false`. Flyway sở hữu schema domain. V1 tạo schema `jobs`; JobRunr 8.4.2 tự quản lý tables/version trong schema đó. Khi nâng JobRunr phải kiểm tra migration trên DB cũ; không dùng Hibernate để tạo bảng.
- Kafka publisher là transport adapter, chưa có business events/outbox. Side effects từ transaction domain phải qua transactional outbox trong task feature; producer idempotence không đảm bảo atomic PostgreSQL/Kafka.
- Redis là cache, không phải nguồn ack/idempotency. Event IDs do client cấp phải giữ nguyên.
- Health `/api/v1/health` chỉ phản ánh tiến trình; readiness phản ánh PostgreSQL. Global Actuator health gồm Redis, không trả chi tiết connection. Swagger chỉ local. Đây chưa có auth/private APIs.

Contract canonical: `contracts/openapi.yaml`; sync/error/identity thuộc NO-003/NO-026. Scaffold không triển khai học, grading, reminders hoặc upload recordings; các luồng học cốt lõi vẫn offline trên Flutter/Drift.
