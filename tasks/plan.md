# Kế hoạch thực thi Nở MVP

Ngày lập: 2026-10-04. Task tracker: **Kaneo / Bloom**. Đặc tả sản phẩm bắt đầu ở [docs/README.md](../docs/README.md).

## Đầu ra được yêu cầu hiện tại

Yêu cầu ban đầu là docs/backlog MVP; repo chưa có app tại thời điểm đó. Ngày 2026-10-04 chủ dự án duyệt scaffold backend trong worktree Init-Spring-Backend theo Vey và bật toàn bộ hạ tầng. Phạm vi chi tiết ở phần worktree bên dưới; bằng chứng thực thi ở [backend-scaffold](../docs/backend-scaffold.md). Kaneo vẫn sở hữu trạng thái task; không lấy việc lập kế hoạch hoặc build riêng lẻ làm bằng chứng tính năng đã hoạt động.

## Cách đọc backlog

- [Chỉ mục task](../docs/backlog.md) có link Kaneo, dependency và requirement.
- [Đặc tả máy đọc được](../docs/backlog.json) giữ acceptance criteria, verification, scope/path cho mỗi task.
- [Ánh xạ Kaneo](../docs/kaneo-map.json) chứa ID thực, native dependency IDs và kết quả kiểm chứng export.
- Kaneo giữ trạng thái thực thi. Không tạo `tasks/todo.md` thứ hai để cạnh tranh nguồn sự thật.
- `NO-xxx` là mã đặc tả ổn định; `BLO-n` là số Kaneo cấp. Không coi số NO là thứ tự tuyệt đối: những task bổ sung như NO-119/120/121 có dependency tới mốc trước và được sắp theo DAG.

## Mốc giao hàng

| Mốc | Người dùng/nhóm làm được gì | Checkpoint |
|---|---|---|
| P1 | Cài app mới không mạng, học starter, nghe audio, chấm/lưu/ôn local | NO-025 |
| P2 | Link guest, backup, sync retry và nhiều thiết bị không mất/trùng dữ liệu | NO-040 |
| P3 | Import từ riêng, xử lý conflict/xóa, tải gói học offline | NO-052 |
| P4 | Luyện câu có khung, sửa lỗi, ghi âm, AI optional, đo recall trì hoãn | NO-063 |
| P5 | Hoa hồng theo học tập, lịch tuần, nhắc local, credit sync | NO-072 |
| P6 | 160 mục/cụm cùng audio đã biên tập, duyệt, phát hành manifest | NO-118 |
| P7 | Kiểm chứng thiết bị, privacy, staging/backup, pilot và closed beta | NO-105 |

Mốc là nhóm kết quả, không phải bảy hàng đợi nối cứng. CI (NO-089/090) chạy sớm ngay sau scaffold; preferences (NO-064) có thể làm trước đánh giá onboarding NO-121; backend habit sync NO-119 phải đợi credit rule NO-065. Theo **native blocks dependencies**, không theo vị trí cột/mốc.

## Thứ tự khởi động khuyến nghị

1. NO-001 Flutter scaffold, NO-002 Spring/PostgreSQL scaffold và NO-005 content schema là ba task không có dependency.
2. Chốt sync contract NO-003 và kiểm chứng Dart/Java FSRS NO-004 sớm. Nếu parity không đạt, xử lý ADR trước xây lịch ôn.
3. Theme/guest persistence/content validator (NO-006/007/008); bắt đầu starter authoring/review/audio (NO-009/010/011).
4. Tích hợp starter NO-012 rồi hoàn thành luồng học local tới NO-025. Lưu SQLite đúng trước khi đánh bóng nhiều animation.
5. Mở hai nhánh tính năng sau checkpoint: sync an toàn và kho từ/import. Nội dung/mascot có thể chuẩn bị cùng lúc khi đã ổn schema và brief.
6. Luyện câu/AI, habit/notification, nội dung beta và release preparation theo dependency thực tế; cuối cùng closed test và readiness.

## Quy tắc chạy một task

1. Đọc body Kaneo, spec tham chiếu và task đang blocks. Nếu chưa xong dependency thì chọn task khác.
2. Giới hạn vào một đầu ra kiểm chứng được. Scope S/M là mục tiêu cho một phiên tập trung, không phải cam kết giờ. Tách tiếp nếu cần hơn khoảng 5 file logic cốt lõi hoặc hai tính năng độc lập; generated files/migration fixtures không dùng để lách scope.
3. Xác định verification trước, triển khai, chạy kiểm tra phù hợp. Ghi command, device/version và kết quả vào task khi hoàn thành.
4. Sau mỗi 2–3 task liên quan, smoke lại luồng bị ảnh hưởng. Không cần tạo task checkpoint cho mọi lần smoke; checkpoints ở bảng trên là gate tích hợp lớn.
5. Chuyển In Review khi có đầu ra, Done khi đủ acceptance/evidence. Không tự skip reviewer nội dung hoặc đánh dấu pilot xong khi chưa có người thử.

Các task pilot/closed test là hoạt động vận hành có thời gian quan sát 2–4 tuần và yêu cầu nền tảng; không thể hoàn thành trong một phiên code. Task review nội dung cần người phù hợp kiểm chứng, không tự nâng AI draft thành giáo trình chuẩn.

## Khi muốn chạy nhiều agent

Không spawn tự động trong lượt lập kế hoạch này. Nếu chủ dự án yêu cầu chạy song song sau đó:

- Một người điều phối chọn tối đa 2–3 task **đã sẵn sàng**, mỗi agent một worktree/branch.
- Có thể song song: mobile component, backend handler theo contract đã chốt, bộ nội dung một chủ đề.
- Chỉ một owner chỉnh OpenAPI/shared schema/migration sequence tại một thời điểm.
- Không chia đơn giản “một agent làm toàn bộ frontend, một agent toàn bộ backend”; chia theo task có input/output cụ thể và integrate thường xuyên.
- Review trên trạng thái tích hợp trước checkpoint; không gộp nhánh làm mất local migration hoặc scheduler parity.

## Rủi ro và xử lý

| Rủi ro | Xử lý trong kế hoạch |
|---|---|
| Học offline nhưng mất tiến độ khi reconnect | Transaction/outbox từ đầu, retry idempotent, replay và matrix bắt buộc |
| FSRS Dart/Java khác kết quả | Spike sớm, pin rules và vectors; không thay thuật toán âm thầm |
| Nhìn đúng nghĩa nhưng vẫn không dùng được | Hai review target, câu mới và scaffold giảm dần |
| AI chấm sai hoặc tốn chi phí | Nội dung curated + rubric, schema, quota, report, không dùng điểm AI cho SRS |
| Thời gian duyệt 160 mục bị đánh giá thấp | Mỗi 20 mục có task soạn và review, audio có batch/reviewer riêng |
| Push nhắc sai do học offline | Local notifications/credit là nguồn trên máy; không suy bỏ học từ server stale |
| Tên/asset/provider chưa đủ điều kiện phát hành | Brand, provenance và release gates trước public release |
| Phụ thuộc Play account/testers | Task xác minh chính sách và closed test riêng, không hứa ngày public trước eligibility |

## Definition of full MVP

Mọi R01–R13 có traceability trong backlog; NO-105 phụ thuộc trực tiếp hoặc gián tiếp toàn bộ task. Full MVP bao gồm offline, nội dung đủ pilot, đồng bộ và các việc cần để có bản Android beta review được. Public production publication chỉ thực hiện khi chủ dự án phê duyệt bản build cụ thể; kế hoạch không tự động cấp quyền publish.

## Plan worktree Init-Spring-Backend — 2026-10-04

Yêu cầu hiện tại: lập kế hoạch init backend Nở và đề xuất Maven/Gradle. Phần này bổ sung kế hoạch MVP, chưa thực hiện scaffold. Task thực thi vẫn theo Kaneo/Bloom; các bước dưới đây là breakdown của NO-002, không phải bảng trạng thái mới. ID/link lấy từ mapping đã xuất bản; chưa đọc lại trạng thái live trong lượt lập kế hoạch này.

### Quyết định đề xuất

- Maven + Maven Wrapper cho một ứng dụng Spring Boot trong `api/`. Maven có lifecycle chuẩn, phù hợp build/test/package thông thường và giảm nhu cầu viết build logic riêng. Pin Maven và plugin; dùng dependency management của Spring Boot.
- Gradle có incremental build/build cache hữu ích khi build lớn hoặc nhiều module. Backend hiện có một deployable nên chưa có nhu cầu đó; Android dùng Gradle không buộc server dùng cùng công cụ. Đây là lựa chọn phù hợp phạm vi, chưa có benchmark tốc độ để kết luận Maven nhanh hơn.
- Java 25 như Vey làm runtime đề xuất; chọn bản Spring Boot stable tương thích và pin patch cụ thể khi scaffold, sau khi kiểm tra dependencies. Lấy Spring Boot 3.5.16 / Java 25 trong Vey làm bộ phiên bản tham chiếu, cùng PostgreSQL, Flyway và Testcontainers; kiểm tra compatibility khi scaffold. Không dùng SNAPSHOT hoặc tag Docker `latest`.
- Modular monolith, package theo feature khi feature xuất hiện: identity, catalog, learner-library, learning, sync, feedback, privacy. Chưa tạo hàng loạt module rỗng hoặc schema domain trong scaffold.
- Dependencies ban đầu: Spring MVC, Validation, Spring Data JPA, PostgreSQL driver, Flyway hỗ trợ PostgreSQL, Actuator; test dùng Spring Boot Test + Testcontainers PostgreSQL. Dùng JPA như Vey, `open-in-view=false`, `ddl-auto=validate`; Flyway sở hữu schema.
- Auth theo NO-026; scaffold chỉ expose health tối thiểu, không cấu hình `permitAll` cho toàn bộ API tương lai. Health không trả chi tiết DB cho caller công khai. API errors/DTO contract nằm trong NO-003.

Nguồn kiểm tra: [Spring Boot compatibility](https://docs.spring.io/spring-boot/system-requirements.html), [Maven lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html), [Maven Wrapper](https://maven.apache.org/tools/wrapper/), [Gradle build cache](https://docs.gradle.org/current/userguide/build_cache.html). Phiên bản patch phải xác minh lại lúc implementation.

### Thứ tự thực thi NO-002

Task [BLO-2 / NO-002](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/kwc73d9ip5ecvkvhuqwrpzn7), không có dependency. Thực hiện tuần tự trong một task; checkpoint cuối mới là bằng chứng nghiệm thu.

| Bước | Đầu ra | Tiêu chí kiểm chứng | Phụ thuộc |
|---|---|---|---|
| 1. Scaffold | `api/`: pom, wrapper, application, cấu hình runtime/version | Wrapper dùng đúng Maven/Java đã pin; package thành executable JAR | Không |
| 2. PostgreSQL dev | `compose.yml`, mẫu env, volume, DB healthcheck, profile dev | DB chỉ bind localhost ở dev; dữ liệu còn sau restart; credential thật không nằm trong repo | 1 |
| 3. Migration | Flyway version đầu trên DB trống, schema nền tối thiểu, Hibernate không tự tạo schema nếu thêm JPA sau này | Flyway apply thành công; restart không chạy lại migration; không dùng baseline-on-migrate để che DB sai lịch sử | 2 |
| 4. API chạy cùng DB | API service trong Compose và Actuator health/readiness tối thiểu | API+DB khởi động; DB down khiến readiness không ready; liveness vẫn phản ánh tiến trình | 3 |
| 5. Integration evidence | Testcontainers dùng PostgreSQL thật, README backend và command đã chạy | Test context+Flyway trên DB mới; kiểm tra history/checksum và startup lại; `verify` thực sự chạy integration tests | 4 |

Đường dẫn dự kiến: `api/pom.xml`, `api/.mvn/`, `api/src/`, `api/README.md`, `compose.yml`, mẫu env dev và `.gitignore`. Generated wrapper/scaffold là phần cơ học; scope logic giới hạn ở cấu hình, migration nền và health/integration test.

Lệnh **dự kiến**, chạy từ root trừ khi ghi khác; chỉ ghi là đã kiểm chứng sau khi scaffold tồn tại:

```sh
make app
cd api
./mvnw test
./mvnw verify
SPRING_PROFILES_ACTIVE=local ./mvnw spring-boot:run
```

Phải cấu hình Surefire/Failsafe phù hợp để `verify` không bỏ sót integration tests. README chỉ rõ cách cấp env cho host run; Compose `.env` không tự trở thành biến môi trường của JVM chạy trên host. Nếu thiếu Docker hoặc không chạy được Testcontainers, báo blocker và phần chưa kiểm chứng, không coi build JAR là đủ để Done.

Checkpoint NO-002: từ DB trống chạy API+PostgreSQL, migration đúng một lần, readiness phản ánh DB, restart giữ dữ liệu, integration tests pass và build ra JAR. Ghi versions/commands/kết quả vào task khi có quyền cập nhật; không chuyển Done trong lượt chỉ lập kế hoạch.

### Task tiếp theo và giới hạn phạm vi

1. [BLO-90 / NO-090](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/zkynlgonql3oupmr217lxzld), phụ thuộc NO-002: CI chạy wrapper verify + PostgreSQL integration; test/migration sai phải đỏ, build sạch ra artifact. Kiểm tra contract được bổ sung khi NO-003 có đầu ra.
2. [BLO-3 / NO-003](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/vc6ayvbzrm6urudrfoij7pjx), phụ thuộc NO-002: chốt OpenAPI `/api/v1`, problem response và sync envelope; validate schema/round-trip fixtures duplicate, conflict, partial ack, expired token.
3. NO-026, phụ thuộc NO-002 + NO-003: xác minh provider token, map internal identity và kiểm thử ownership/account A-B trước private endpoints.

NO-004 FSRS spike chỉ bắt đầu khi NO-001 và NO-002 sẵn sàng. Guest merge, sync handlers, content domain schema, AI, tính năng upload/download object storage và deployment thuộc task riêng. Redis, Kafka, MinIO và JobRunr được bổ sung vào phạm vi init theo xác nhận của chủ dự án; microservices, password/OTP server và public deployment vẫn ngoài scope.

Nền này phục vụ backup/catalog/sync cho app offline: việc học, chấm và lưu progress vẫn chạy trong Flutter + SQLite/Drift. Schema/domain tiếp theo phải giữ content revision bất biến, operation dedupe theo account và event append-only theo `docs/offline-sync.md`; không biến scaffold thành API bắt buộc cho mỗi lượt trả lời.

### Điều chỉnh theo Vey và xác nhận bật toàn bộ hạ tầng

Đã đọc reference `/home/dorriss/Projects/work/vey`: `api/pom.xml`, wrapper, Dockerfile, Compose, application profiles, CI, ArchUnit tests và ADR modular monolith. Chủ dự án yêu cầu folder tương tự Vey và bật toàn bộ hạ tầng ngay. Điều này thay thế đề xuất init tối giản phía trên; chưa triển khai code hoặc cập nhật trạng thái Kaneo.

Cấu trúc đích:

```text
api/
  pom.xml
  mvnw, mvnw.cmd, .mvn/wrapper/
  Dockerfile, .dockerignore
  checkstyle/checkstyle.xml
  src/main/java/com/dorriss/no/
    NoApplication.java
    common/                 # lỗi, cấu hình và kiểu dùng chung
    infrastructure/         # persistence, Redis, Kafka, S3, jobs
    modules/                # tạo module khi triển khai feature thật
  src/main/resources/
    application.yaml
    application-local.yaml
    db/migration/
  src/test/java/com/dorriss/no/
    arch/
frontend/                   # Flutter + Drift khi NO-001 triển khai
contracts/
content/
infra/                      # script/cấu hình vận hành bổ sung
scripts/
.github/workflows/
compose.yml
.env.example
Makefile
docs/
tasks/plan.md
```

`frontend/` giữ vai trò client giống Vey nhưng là Flutter, không chuyển thành Next.js. `docs/` tiếp tục là bộ nhớ Nở; không tạo vault Brain thứ hai. Package `com.dorriss.no` là tên kỹ thuật đề xuất cho backend.

Stack từ Vey:

| Thành phần | Phạm vi init / vai trò |
|---|---|
| Maven Wrapper, Java 25, Spring Boot 3.5.x | Một Maven project, một executable JAR; bộ patch trong Vey làm tham chiếu |
| JPA, PostgreSQL, Flyway | Persistence, migration; pin cùng image PostgreSQL cho dev và tests |
| Lombok, MapStruct, uuid-creator | Cùng công cụ Vey; UUID từ client vẫn được giữ, không đổi ID event khi sync |
| springdoc / Swagger UI, Actuator | Docs và health; OpenAPI trong `contracts/` vẫn là contract canonical |
| Redis | Khởi tạo connection/config; cache có thể rebuild, không giữ ack/idempotency authoritative |
| Kafka + Kafka UI | Broker local, event publisher abstraction; consumer/business event thuộc feature sau |
| MinIO + AWS SDK S3 | Bucket dev và adapter; smoke put/get/delete bằng fixture, không upload recording riêng tư |
| JobRunr trên PostgreSQL | Durable jobs; dashboard chỉ local; smoke job hoàn tất và retry, không gắn nhắc học vào server |
| Dozzle | Công cụ đọc log local, bind localhost; không log token/private writing |
| Spotless, Checkstyle, JaCoCo, ArchUnit, Testcontainers | Quality gates như Vey; enforcement boundaries và integration hạ tầng |
| Docker multi-stage, Makefile, pre-commit scripts | Developer workflow; JRE runtime non-root, local setup rõ ràng |

Đề xuất kiến trúc: modular monolith bằng package, chưa tách Maven modules và chưa cần Spring Modulith. `common`/`infrastructure` không phụ thuộc business modules; module chỉ truy cập module khác qua interface công khai, không import repository/entity nội bộ. ArchUnit enforce rule này khi modules có code thật; tránh test boundary pass chỉ vì chưa có class.

Điểm khác Vey được đề xuất có chủ đích: không bắt buộc mọi giao tiếp liên module qua Kafka. Transaction nhận sync operation phải ghi thay đổi, dedupe và kết quả ack cùng PostgreSQL transaction. Event cho side effects đi qua server transactional outbox rồi publish Kafka, consumer idempotent. Outbox server này khác outbox SQLite của mobile; implementation thuộc sync/event task sau. JobRunr xử lý jobs, không thay thế event bus hoặc event log học tập.

Đây là mở rộng đáng kể so với AC gốc NO-002 chỉ yêu cầu Spring/PostgreSQL. Giữ checkpoint nền NO-002, rồi thực hiện các slice mở rộng tuần tự; cần phản ánh scope/AC này vào Kaneo trước khi triển khai, không coi snapshot hiện tại đã chứa các yêu cầu mới:

| Slice sau nền | Acceptance / verification | Dependency |
|---|---|---|
| Compose đầy đủ | PostgreSQL, Redis, Kafka, Kafka UI, MinIO, Dozzle lên được; local ports không trùng Vey; Kafka advertised listeners đúng host/container; volumes giữ dữ liệu sau restart | NO-002 nền |
| Adapter hạ tầng | Redis set/get, Kafka publish/consume fixture, S3 put/get/hash/delete fixture; mỗi bài có timeout và cleanup | Compose đầy đủ |
| JobRunr | Schema jobs được tạo theo một cơ chế có owner rõ; job chạy, retry sau lỗi; restart không mất pending job | PostgreSQL + config jobs |
| Quality + Docker | Spotless/Checkstyle/ArchUnit/tests qua; Java 25 ở compiler/CI/runtime đồng nhất; build image non-root và smoke health | Adapter + jobs |

Tách smoke tests mở rộng khỏi test chỉ PostgreSQL để tìm lỗi rõ; nếu thiếu hạ tầng thì báo skipped/blocked, không báo đã kiểm chứng toàn stack. Schema domain vẫn do task feature quản lý. JobRunr cần ghi rõ schema lifecycle riêng, không ngầm cho Hibernate tạo bảng.

CI NO-090 học theo Vey nhưng không copy bước tự push image lên GHCR: chỉ chạy checks/build, chưa publish. Không copy credential, IAM tables, sample account, Clerk, Next.js hoặc prefix Vey sang Nở. Các đường dẫn trong backlog snapshot cũ sẽ được sửa có lịch sử cùng tracker khi cập nhật task; không dùng chúng để scaffold nhầm vào `services/api/`.

### Thực thi scaffold

Chủ dự án đã duyệt triển khai trong lượt tiếp theo. Layout `api/`, Compose root và stack Vey đang được scaffold. Các command canonical là `make infra`, `make app`, `cd api && ./mvnw -B -ntp verify`; evidence và giới hạn kiểm chứng ở `docs/backend-scaffold.md`. Kaneo REST trả 403 ngày 2026-10-04 nên chưa cập nhật scope/status task live; không đánh dấu Done trong snapshot/mapping. CI được tạo trong repo, chưa có bằng chứng workflow GitHub đã chạy.
