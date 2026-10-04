# Kế hoạch thực thi Nở MVP

Ngày lập: 2026-10-04. Task tracker: **Kaneo / Bloom**. Đặc tả sản phẩm bắt đầu ở [docs/README.md](../docs/README.md).

## Đầu ra được yêu cầu hiện tại

Backlog MVP đã xuất bản. Chủ dự án duyệt NO-001 Flutter Android và scaffold backend NO-002 theo Vey; cả hai có đầu ra để review. Theo quyết định mới nhất, mobile ở `apps/mobile/`, backend ở `api/`; `frontend/` dành cho web sau này. Bằng chứng: [NO-001](../docs/evidence/NO-001.md) và [backend](../docs/backend-scaffold.md). Kaneo giữ trạng thái task; các task còn lại theo DAG, không suy toàn bộ tính năng đã hoạt động từ scaffold.

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

Lưu ý thiết kế cập nhật 2026-10-04: NO-006 và các màn phụ thuộc phải theo [UX hiện hành](../docs/ux.md): nền trắng sáng, hồng rose làm điểm nhấn, ưu tiên nội dung học. Tên “bộ component nền màu hồng” trong snapshot backlog/ánh xạ export là tên lúc tạo task, không còn là yêu cầu phủ nền hồng. Lượt cập nhật docs này chưa sửa task trên Kaneo hoặc xác nhận implementation; mockup sẽ được chủ dự án làm sau.

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
apps/mobile/                # Flutter Android + Drift
frontend/                   # dành cho web tương lai, chưa scaffold
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

Theo chốt lại của chủ dự án ngày 2026-10-04, `apps/mobile/` giữ app Flutter; `frontend/` dành cho web tương lai, chưa chọn stack web. `docs/` tiếp tục là bộ nhớ Nở; không tạo vault Brain thứ hai. Package `com.dorriss.no` là tên kỹ thuật đề xuất cho backend.

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

## Kế hoạch chi tiết NO-001 — Flutter Android scaffold

### Task List và dependency

Task duy nhất của phiên: [NO-001 / BLO-1](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/s7jc4lmn6wdpv6sc8pjklbt1). Kaneo là nơi ghi trạng thái; không tạo checklist task cạnh tranh trong `tasks/todo.md`. Các bước dưới đây là thứ tự triển khai bên trong task này, không phải task mới hoặc trạng thái Done.

Đã đọc live project Bloom, body và native relations ngày 2026-10-04 qua REST với credential từ môi trường, `x-api-key` và User-Agent. NO-001 đang `in-progress`, priority high; không có incoming dependency. Task chặn NO-004, NO-006, NO-007, NO-015, NO-069 và NO-089. MCP Kaneo không được expose trong phiên này. Request mặc định bị HTTP 403; thêm User-Agent đọc được HTTP 200, không thay credential hay cấu hình toàn cục.

**Đầu ra:** app Android scaffold chạy từ repo, toolchain được pin, hai môi trường dev/staging và router 4 tab tiếng Việt. Scope M: tối đa khoảng 5 file Dart triển khai cốt lõi; Android config, lockfiles, test và tài liệu là phần scaffold bắt buộc, được liệt kê rõ bên dưới.

**Acceptance criteria của task:**

- App Android chạy từ `apps/mobile/` bằng Flutter được pin, có bằng chứng build và khởi chạy emulator.
- Dev/staging phân biệt được khi cài; điều hướng đủ Hôm nay, Kho từ, Luyện câu, Khu vườn; không cần mạng/đăng nhập để mở shell.
- Analyze sạch, test hành vi router/config đạt; README và architecture ghi lệnh/runtime thực tế sau khi chạy.

### Bằng chứng môi trường trước scaffold

| Thành phần | Kết quả kiểm tra trên máy |
|---|---|
| Flutter / Dart | `flutter --version`: stable 3.44.8, Dart 3.12.2; framework `058e0af2c2b57e369d905a03ac9748b0ebf543c6` |
| FVM | `fvm --version`: 4.3.1; Flutter hiện trỏ tới alias `stable`, chưa có pin riêng trong repo |
| Android SDK | `/home/dorriss/Android/Sdk`; platform 35/36/36.1, build-tools 36.0.0, NDK 28.2.13676358 |
| JDK cho Flutter | Doctor chọn JBR Android Studio 21.0.10; Java shell là 25.0.4.1, không dùng thay thế ngầm |
| Template Flutter đang cài | Gradle 9.1.0, AGP 9.0.1, Kotlin plugin 2.3.20; compile/target SDK 36, min SDK 24; đọc từ `flutter_tools/lib/src/android/gradle_utils.dart` |
| Android licenses / network | `flutter doctor -v`: Android toolchain và network đạt, licenses đã chấp nhận |
| ADB / emulator | ADB 37.0.1; emulator 37.1.11; AVD `LiftPing_Phone_ADR`, x86_64, image API 37.1 Play Store 16 KB |
| KVM | `emulator -accel-check`: installed and usable; `/dev/kvm` có quyền đọc/ghi |

Khi kiểm tra ban đầu không có thiết bị kết nối. Lệnh launch AVD qua Flutter trả exit 0 nhưng device chỉ xuất hiện `offline` rồi biến mất. Cold boot với `emulator -avd LiftPing_Phone_ADR -no-window -no-audio -no-snapshot -gpu swiftshader_indirect` thành công: ADB báo `sys.boot_completed=1`, Android 17/API 37 trên `emulator-5554`. KVM hoạt động; đường launch GUI mặc định chưa được xác nhận ổn định. Emulator kiểm tra được tắt sau khi thu bằng chứng để trả tài nguyên máy. Chưa có app nên chưa chạy analyze/test/build ứng dụng. Java/Maven/Docker có trên PATH; PostgreSQL CLI không có trên PATH. Backend thuộc NO-002, chưa kiểm chứng runtime/container ở task này.

### Quyết định triển khai

- Tạo Android-only app Dart package `no_mobile` tại `apps/mobile/`, Kotlin Android, namespace dev tạm `com.dorriss.noapp`; chưa chốt package phát hành. Dùng suffix `.dev` và `.staging`, nhãn `Nở Dev` / `Nở Staging` để cài song song và tách sandbox dữ liệu.
- Pin FVM numeric `3.44.8` tại app, commit `.fvmrc`, `pubspec.lock` và Gradle wrapper/config; ignore `.fvm/`, SDK paths, build artifacts. Không chạy upgrade Flutter hay thay default SDK toàn máy.
- Dùng JBR 21 cho build mobile; Gradle wrapper của app thay cho `gradle` trên PATH. Ghi version Gradle/AGP/Kotlin thực tế sau generate; nếu template khác số đã đọc thì kiểm chứng và cập nhật tài liệu trước tiếp tục. Min SDK dự kiến 24 từ template; khả năng hỗ trợ máy pilot cần kiểm chứng ở task thiết bị.
- Android product flavors `dev`/`staging`, một entrypoint, config immutable đọc `appFlavor`. API endpoint chỉ nhận qua cấu hình khi cần, không bịa staging URL và không gọi API lúc bootstrap. Không chứa secret trong Dart defines. Tên app dùng resource `strings.xml`, tránh custom resource value mặc định bị tắt trên AGP 9 theo [Flutter flavors](https://docs.flutter.dev/deployment/flavors).
- Router chọn `go_router` theo [Flutter navigation](https://docs.flutter.dev/ui/navigation); shell 4 nhánh giữ navigation stack từng tab, Android Back có hành vi xác định. Pin package tương thích Dart 3.12.2 khi resolve ở implementation; chưa khẳng định package version trước khi kiểm tra.
- Chia `app/`, `core/config/`, `features/`; placeholder 4 tab ghi rõ tính năng đang xây dựng, không giả dữ liệu tiến độ. Chưa thêm Riverpod/Drift/HTTP nếu không có use case ở scaffold. Giữ hướng Riverpod + Drift của kiến trúc để NO-007 và các task tiếp theo triển khai.
- NO-001 không hoàn tất R01: guest persistence NO-007, content/audio NO-009–012, học/grade/save là các task tiếp theo. Shell không có login wall; không hiển thị “Đã lưu” khi chưa có SQLite transaction. Theme/component hoàn chỉnh thuộc NO-006; CI thuộc NO-089.

### Thứ tự thực hiện bên trong NO-001

**Bước 1 — Khởi chạy scaffold dev (M).** Dependency: không có. Tạo Android template, pin toolchain, dev flavor và shell tối thiểu để phát hiện lỗi Gradle/JDK sớm.

- Điều kiện: FVM dùng đúng Flutter 3.44.8; APK dev build được; emulator chạy app vào shell khi không mạng.
- Kiểm chứng: doctor, `fvm flutter build apk --debug --flavor dev`, `fvm flutter run --flavor dev -d <device-id>`; lưu phiên bản JDK/wrapper và kết quả boot/install thực tế.
- Files: `.fvmrc`, `.gitignore`, `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, Android scaffold + wrapper. Chỉ một file Dart logic ở bước này; generated Android files được review.

**Bước 2 — Shell 4 tab với hai môi trường (M).** Dependency: bước 1. Hoàn thiện staging flavor, typed config, feature shell và router.

- Điều kiện: dev/staging có app ID/nhãn riêng; vào đúng 4 route `/today`, `/library`, `/practice`, `/garden`; chuyển tab/quay lại không mất navigation stack hay mắc vòng lặp Back.
- Kiểm chứng: widget test chuyển tab, stack và Back; config test cho dev/staging/thiếu hoặc sai flavor; build staging debug; manual smoke hai app không mạng, text scale 200%.
- Files Dart dự kiến toàn task: `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart`, `lib/core/config/app_config.dart`, `lib/features/scaffold/scaffold_page.dart`. Placeholder dùng chung trong feature scaffold; tách feature thật khi task tương ứng bắt đầu. Thêm Android flavor config/resources, `test/app_config_test.dart`, `test/navigation_test.dart`.

**Checkpoint sau bước 1–2:**

- [x] Numeric Flutter pin, wrapper và JDK đã xác nhận; dev/staging APK build thành công.
- [x] Hai bản cài chạy được trên emulator; bốn tab, Back và khởi chạy không mạng hoạt động qua integration smoke.
- [x] Analyze sạch; tests config/router đạt; giới hạn scaffold không lấn guest/study/theme/CI.

**Bước 3 — Ghi bằng chứng để review (S).** Dependency: checkpoint trên. Cập nhật `apps/mobile/README.md`, `docs/architecture.md`, `docs/quality-release.md` với lệnh thực tế và giới hạn của scaffold; review diff, secrets/artifacts và coherence offline. Chuyển In Review trên Kaneo khi có đầy đủ đầu ra theo quy tắc task, chỉ Done khi acceptance có bằng chứng. Không dùng build thành công thay cho smoke router/emulator.

- Điều kiện: fresh checkout có hướng dẫn pin/restore/build; evidence chứa commands, runtime, emulator và kết quả; chưa chạy hoặc thất bại phải ghi rõ.
- Kiểm chứng: chạy chuỗi bên dưới trên scaffold, `git diff --check` và review file tracked trước bàn giao.
- Files: `apps/mobile/README.md`, `docs/architecture.md`, `docs/quality-release.md`.

### Lệnh kiểm chứng theo plan — kết quả thực tế ở evidence

Chạy tại `apps/mobile/` sau scaffold, `<device-id>` lấy từ `flutter devices`, không giả định cố định. Bootstrap `fvm use 3.44.8` trước các lệnh FVM. JDK ở máy hiện tại: `/home/dorriss/.local/share/JetBrains/Toolbox/apps/android-studio/jbr`; hướng dẫn fresh checkout dùng JDK 21 tương đương, không commit đường dẫn riêng.

```sh
fvm flutter --version
fvm flutter doctor -v
fvm flutter pub get
fvm dart format --output=none --set-exit-if-changed lib test
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug --flavor dev
fvm flutter build apk --debug --flavor staging
fvm flutter run --flavor dev -d <device-id>
fvm flutter run --flavor staging -d <device-id>
```

Manual: cài hai flavor song song, bật airplane mode trước mở app, đi đủ bốn tab, thử chuyển tab/back, đóng/mở lại, kiểm tra tiếng Việt và text scale. Đây là smoke scaffold, chưa là offline acceptance của buổi học/starter. Không cần build AAB hay ký release để đạt NO-001.

### Rủi ro và câu hỏi còn mở

| Rủi ro | Ảnh hưởng | Cách xử lý |
|---|---|---|
| Alias FVM stable thay đổi | Build không tái lập | Numeric pin trước scaffold; ghi lockfiles/wrapper |
| JDK shell 25 khác Flutter JBR 21 | Build CLI khác IDE/CI | Ghi và kiểm tra JVM của wrapper, dùng JDK 21 nhất quán |
| AVD hiện có launch rồi biến mất | Không thể chứng minh run acceptance | Kiểm tra cold boot/software rendering; nếu vẫn lỗi tạo AVD dev riêng, giữ AVD hiện có |
| System image 37.1 và cảnh báo RAM | Smoke dev nặng, chưa đại diện pilot | Dùng AVD API 36 riêng nếu cần; không thay minSdk để né verification |
| AGP 9/template mới | Flavor/resources hoặc plugin không tương thích | Build dev sớm, dựa template pin và docs chính thức, không downgrade âm thầm |
| Package dev tạm chưa được kiểm tra quyền sở hữu | Không phù hợp release identity | Ghi rõ tạm thời, giải quyết ở task brand/release trước ký beta |

Không có câu hỏi sản phẩm chặn kế hoạch scaffold. Chủ dự án đã review và duyệt plan trước code ngày 2026-10-04; vẫn giữ toàn bộ kế hoạch MVP và task tracker hiện có. Không spawn agent hoặc bắt đầu task khác trong phiên này.

### Kết quả triển khai NO-001

Plan đã được duyệt và scaffold được tạo ngay trong repo tại `apps/mobile/`. Bằng chứng: [NO-001](../docs/evidence/NO-001.md). Format/analyze sạch, 6 tests đạt, dev/staging debug APK build và run thành công, mỗi flavor đạt 1 integration smoke trong airplane mode. Đã xem screenshot chữ 200%, cold launch và phím Back thật trên emulator. Các bước task đã có đầu ra để review; trạng thái thực thi vẫn lấy từ Kaneo.

### Thiết bị kiểm chứng từ phiên tiếp theo

Chủ dự án yêu cầu ngừng dùng emulator vì gây lag máy. Không khởi chạy AVD nữa; dùng điện thoại Android thật qua ADB (USB hoặc Wireless debugging). Bằng chứng emulator NO-001 là lịch sử, không phải chỉ dẫn launch cho các phiên sau. Lấy device ID bằng `adb devices -l`; chỉ chạy app/integration khi điện thoại đã cấp quyền và có trạng thái `device`. Giữ nguyên các acceptance offline, kiểm chứng trên điện thoại thật thay cho emulator.

Kiểm chứng bổ sung sau khi chủ dự án yêu cầu commit: OPPO Reno8, Android 14/API 34, ARM64 qua wireless ADB; 6 tests local và 1 integration smoke cho mỗi flavor đạt. Staging có lượt bị chặn cài/runner timeout trước khi fresh build chạy đạt; xem evidence. Smoke điện thoại chạy online, không làm mất wireless ADB. Không khởi chạy emulator. Chia history thành 4 atomic Conventional Commits: plan, scaffold, tests, tài liệu/evidence.

## Sửa blocker CI NO-002 — 2026-10-04

PR #2 không pull được MinIO trên runner mới; local trước dùng cached image. Giữ nguyên release MinIO/mc, build image từ official GitHub binaries + pinned checksums, dùng chung Dockerfile cho Compose/Testcontainers và mở rộng CI path filters. Evidence và giới hạn tại `docs/backend-scaffold.md`; chưa thay đổi trạng thái Kaneo hoặc bắt đầu NO-003/090.

## Kế hoạch chi tiết NO-003 — Hợp đồng đồng bộ và lỗi API

Ngày lập: 2026-10-04. Nhánh `feature/common-contract` đã fetch và fast-forward `origin/main` từ `1b6725d` tới `957b2a1`, không conflict. Đây là phần mở rộng kế hoạch MVP hiện có; giữ nguyên các phần NO-001/NO-002. Chỉ lập kế hoạch, chưa triển khai contract/DTO hoặc duyệt implementation.

### Điều tra task và dependency

Đã đọc live Bloom bằng MCP: project ID `i11re6ts0794c06k7o1wbd10`, toàn bộ 124 task trước khi tạo breakdown, body/relations/comments NO-003 và columns. [NO-003 / BLO-3](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/vc6ayvbzrm6urudrfoij7pjx) đang `in-progress`, priority high, chưa có comment/subtask trước lượt này. Dependency NO-002 cũng đang `in-progress`; code scaffold đã có trên main nhưng không dùng sự hiện diện code làm bằng chứng task Done. Giữ nguyên trạng thái, assignee và deadline của parent/dependency.

Hai acceptance criteria gốc:
1. OpenAPI định nghĩa operation UUID, revision, per-item ack, cursor, snapshot và problem response.
2. Có fixture duplicate, conflict, partial success, token expiry; không tin userId trong payload.

Verification gốc: validate OpenAPI và round-trip cùng fixtures bằng DTO client/server mẫu. NO-003 chặn NO-026 (identity), NO-028 (sync persistence), NO-031 (mobile push); giữ nguyên các quan hệ này. Implementation chỉ bắt đầu sau NO-002 hoàn tất và chủ dự án review plan.

Hiện `contracts/openapi.yaml` là OpenAPI 3.0.3/version 0.0.1, chỉ có health; backend Java 25/Spring Boot 3.5.16 dùng Jackson, mobile Flutter 3.44.8/Dart 3.12.2 chưa có sync client. Đã đọc `docs/README.md`, `docs/architecture.md`, `docs/offline-sync.md`, `docs/quality-release.md`, `api/README.md` và kế hoạch hiện có.

### Quyết định kiến trúc và phạm vi

- OpenAPI trong `contracts/` là canonical; giữ namespace `/api/v1` và health hiện có. Tiếp tục 3.0.3 để tránh đổi toolchain không cần thiết; chọn version contract mới khi chốt schema.
- Đầu ra là contract, shared synthetic fixtures, schema validator và DTO mẫu trong test support Java/Dart. Không tạo HTTP sync handler, migration, authentication provider, network worker hoặc UI trong NO-003. Catalog/AI/guest migration/deletion API hoàn chỉnh thuộc task feature tương ứng; chỉ định nghĩa shared primitives khi cần.
- Mỗi operation giữ UUID client và device sequence; ownership từ verified identity, không từ userId trong payload. Document idempotency theo account+operationId, xử lý ID trùng khác payload và ack riêng từng item.
- Chốt typed payload cho tập operation MVP cần envelope; không dùng map tùy ý thay cho schema. Liệt kê operation/revision semantics trước khi viết fixture; domain scheduler/content chưa chốt dùng version/reference, không tự bịa thuật toán FSRS hoặc content schema.
- Cursor opaque scoped theo account; snapshot có checkpoint ổn định qua nhiều page và continuation cursor. Rebase pending local operations là nghĩa vụ client; snapshot không cho phép mất attempts/pending data.
- Problem JSON có code ổn định, field errors, requestId, retryability; text giải thích tiếng Việt. Tách lỗi toàn request khỏi conflict từng item trong mixed batch; fixture ghi HTTP status/headers/schema và expected outcome.
- Round-trip compare JSON theo cấu trúc; không phụ thuộc key order. Làm rõ UTC offset/instant, integer range Dart/Java, nullable/absent và discriminator; mọi fixture dùng dữ liệu tổng hợp, không private learner sentences.
- Runner schema không thay integration test ownership/idempotency/transaction/replay thật: các gate runtime thuộc NO-026/028/029/031 và task sync tiếp theo.

### Task List — Kaneo / Bloom

Kaneo là task list target, không tạo `tasks/todo.md` hoặc checklist trạng thái thứ hai. Đã tạo và đọc lại body/status/relations của bốn subtask; tất cả `to-do`, không assignee/deadline.

| Thứ tự | Task | Đầu ra | Dependency | Scope |
|---|---|---|---|---|
| 1 | [NO-003.1 / BLO-125](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/qvfgd7p772agus9ahicb70un) | Chốt push envelope và ack từng operation | NO-002 (đang in-progress; gate trước implementation). | M · 3–5 file |
| 2 | [NO-003.2 / BLO-126](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/pwkm8w608nsojybiy8071swl) | Chốt pull cursor và snapshot phục hồi | NO-003.1. | M · 4 file |
| 3 | [NO-003.3 / BLO-127](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/suep06ysc10a2pjnsp9fz8u1) | Kiểm chứng fixture bằng schema và DTO Java | NO-003.2; yêu cầu NO-002 hoàn tất trước implementation. | M · 5 file |
| 4 | [NO-003.4 / BLO-128](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/ojzsah3ncqu6k64unoq3ufoq) | Kiểm chứng DTO Dart và bàn giao contract | NO-003.3 và NO-001 (đã done). | M · 4 file |

Native relations: NO-003 là parent của cả bốn qua `subtask`; `NO-002 → NO-003.1 → NO-003.2 → NO-003.3 → NO-003.4` qua `blocks`; thêm `NO-001 → NO-003.4` (NO-001 đã Done). Parent giữ native blocks tới NO-026/028/031; subtask không được coi là thay thế acceptance của parent.

Mỗi task trên Kaneo chứa mô tả, tối đa ba acceptance criteria, verification commands/manual check, dependency và 3–5 files dự kiến. Slice 1–2 định nghĩa đường sync cùng fixture; slice 3–4 chứng minh hai runtime đọc cùng contract. DTO test support chưa phải production client sinh tự động.

### Checkpoint sau NO-003.1–NO-003.2

- [ ] Validate OpenAPI đạt; reviewer đối chiếu operation fields/revision/limits/problem với offline-sync.
- [ ] Walkthrough duplicate, conflict, partial success và 401: chỉ item có ack thành công được xác nhận; pending khác giữ nguyên.
- [ ] Walkthrough cursor expiry → snapshot nhiều page → resume dưới concurrent changes: không thiếu tombstone/projection hoặc ghi đè outbox pending.
- [ ] Review contract trước khi tạo DTO; nếu schema/payload chưa rõ, giải quyết trong slice tương ứng rồi tiếp tục.

### Checkpoint sau NO-003.3–NO-003.4

- [ ] Mọi fixture hợp lệ qua schema và DTO Java/Dart; fixture invalid bị từ chối tại trường/điều kiện dự kiến.
- [ ] Focused tests, analyze, mobile regression và backend verify đạt; Docker IT chưa chạy phải ghi rõ, không báo pass.
- [ ] Traceability cả hai AC NO-003 đầy đủ, README và evidence ghi command/version/kết quả thật; giữ offline guarantees.
- [ ] Parent chỉ chuyển In Review khi có evidence của cả bốn subtask; Done sau acceptance/review theo quality-release.

### Lệnh kiểm chứng dự kiến

Lệnh hiện có: từ root `uvx --from openapi-spec-validator==0.7.2 openapi-spec-validator contracts/openapi.yaml`; từ `api/`: `./mvnw -B -ntp test`, `./mvnw -B -ntp verify`; từ `apps/mobile/`: `fvm flutter analyze`, `fvm flutter test`.

Đầu ra mới phải tạo/pin ở NO-003.3–4, chưa tồn tại hoặc chạy trong lượt planning:

```sh
# Root: validator đọc $ref/schema/format và expected outcomes trong shared fixtures
uv run --project contracts/tools python contracts/tools/validate_fixtures.py
# api/
./mvnw -B -ntp -Dtest=SyncContractTest test
./mvnw -B -ntp verify
# apps/mobile/
fvm flutter test test/contracts/sync_contract_test.dart
fvm flutter analyze
fvm flutter test
# Root
git diff --check
```

Maven verify bao gồm Docker/Testcontainers IT; thiếu hạ tầng phải báo chưa kiểm chứng. Slice contract/test-only không cần launch Android. Nếu implementation phát sinh kiểm chứng thiết bị, dùng phone qua `adb devices -l`, không emulator và không tắt Wi-Fi/airplane mode khi wireless ADB.

### Rủi ro, quyết định còn mở và phối hợp

| Rủi ro | Ảnh hưởng | Xử lý |
|---|---|---|
| NO-002 chưa Done dù đã merge scaffold | High: chạy task khi prerequisite chưa đạt | Gate implementation theo Kaneo; không tự đổi NO-002 |
| Snapshot nhiều page dùng dữ liệu đang đổi | High: bỏ sót changes | Chốt snapshot identity/checkpoint/continuation ngay slice 2 |
| Validation chỉ parse JSON, DTO bỏ field | High: contract pass giả | Resolve schemas/formats, negative corpus, compare đầy đủ hai runtime |
| Ack duplicate/conflict bị hiểu là xóa cả batch | High: mất pending events | Expected outcomes theo operationId và walkthrough mixed batch |
| Domain schema chưa chốt | Medium: bịa payload rồi sửa consumer | Tập operation/revision được review; tham chiếu content/scheduler version |
| Cross-runtime timestamp/integer/null khác nhau | Medium: sai replay/revision | Vectors round-trip có offset, integer boundaries và absent/null |

Cần chốt trong slice 1: danh sách operationType/payload v1, revision representation, batch/body limits, stable error codes và compatibility/version policy. Trong slice 2: cursor expiry HTTP/code, snapshot lifetime/checkpoint và page limits. Đây là quyết định kỹ thuật đề xuất để review, chưa phải endpoint hoạt động.

Thực hiện tuần tự vì chia sẻ OpenAPI và fixture corpus. Java/Dart có thể làm song song sau contract freeze nếu chủ dự án yêu cầu; lượt này không spawn/delegate agents. Kế hoạch đã được lập để review; chưa có xác nhận duyệt implementation.

### Duyệt implementation NO-003 — 2026-10-04

Chủ dự án đã hiểu phạm vi contract và yêu cầu bắt đầu triển khai. Đọc lại MCP xác nhận NO-002 hiện `done`; gate dependency được đáp ứng. Các trạng thái NO-002 `in-progress` phía trên là bằng chứng lúc lập plan, không phải blocker hiện tại. Triển khai bốn slice theo thứ tự, không mở rộng sang sync runtime.
