# Kế hoạch thực thi Nở MVP

Ngày lập: 2026-10-04. Task tracker: **Kaneo / Bloom**. Đặc tả sản phẩm bắt đầu ở [docs/README.md](../docs/README.md).

## Đầu ra được yêu cầu hiện tại

Backlog MVP đã xuất bản. Yêu cầu ngày 2026-10-04: bắt đầu NO-001 bằng việc đọc task Kaneo, kiểm chứng toolchain trên máy và lập kế hoạch scaffold Android. Chủ dự án đã duyệt plan và yêu cầu init trong repo này; bước tiếp theo là triển khai scaffold NO-001. Những task còn lại tiếp tục theo DAG hiện có; không lấy việc lập kế hoạch làm bằng chứng tính năng đã hoạt động. Trước implementation, repo chưa có build/test ứng dụng.

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

- [ ] Numeric Flutter pin, wrapper và JDK đã xác nhận; dev/staging APK build thành công.
- [ ] Hai bản cài chạy được trên emulator; bốn tab, Back và khởi chạy không mạng hoạt động.
- [ ] Analyze sạch; tests config/router đạt; giới hạn scaffold không lấn guest/study/theme/CI.

**Bước 3 — Ghi bằng chứng để review (S).** Dependency: checkpoint trên. Cập nhật `apps/mobile/README.md`, `docs/architecture.md`, `docs/quality-release.md` với lệnh thực tế và giới hạn của scaffold; review diff, secrets/artifacts và coherence offline. Chuyển In Review trên Kaneo khi có đầy đủ đầu ra theo quy tắc task, chỉ Done khi acceptance có bằng chứng. Không dùng build thành công thay cho smoke router/emulator.

- Điều kiện: fresh checkout có hướng dẫn pin/restore/build; evidence chứa commands, runtime, emulator và kết quả; chưa chạy hoặc thất bại phải ghi rõ.
- Kiểm chứng: chạy chuỗi bên dưới trên scaffold, `git diff --check` và review file tracked trước bàn giao.
- Files: `apps/mobile/README.md`, `docs/architecture.md`, `docs/quality-release.md`.

### Lệnh kiểm chứng dự kiến — chưa chạy trên app

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
