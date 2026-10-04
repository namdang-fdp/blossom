# Kế hoạch thực thi Nở MVP

Ngày lập: 2026-10-04. Task tracker: **Kaneo / Bloom**. Đặc tả sản phẩm bắt đầu ở [docs/README.md](../docs/README.md).

## Đầu ra được yêu cầu hiện tại

Yêu cầu mới ngày 2026-10-04: kiểm tra readiness và lập kế hoạch NO-007. Đã đọc task/relations/comments live qua MCP Kaneo: NO-007 `in-progress`, dependency duy nhất NO-001 `done`; không có comment bổ sung. Kế hoạch chi tiết và chỉ mục task con ở cuối file. Phiên này chỉ lập kế hoạch, chưa triển khai NO-007; nội dung NO-001 bên dưới là lịch sử.

Backlog MVP đã xuất bản. Yêu cầu ngày 2026-10-04: bắt đầu NO-001 bằng việc đọc task Kaneo, kiểm chứng toolchain trên máy và lập kế hoạch scaffold Android. Chủ dự án đã duyệt plan và yêu cầu init trong repo này; scaffold NO-001 đã có đầu ra để review. Những task còn lại tiếp tục theo DAG hiện có; không lấy việc lập kế hoạch làm bằng chứng tính năng đã hoạt động. Mobile scaffold có build/test tại `apps/mobile/`; backend chưa có scaffold.

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

## Kế hoạch chi tiết NO-007 — Guest profile offline

### Readiness và phạm vi

Kiểm tra trực tiếp ngày 2026-10-04: [NO-007 / BLO-7](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/xc1vmwt6xhgzvirgqyd81r62) đang `in-progress`, high, chưa có assignee. Incoming `blocks` duy nhất là NO-001, đã `done`/`isCompleted=true`; không có comment. **Có thể bắt đầu triển khai**, không có dependency mở. NO-007 đang chặn NO-012, NO-017, NO-027 và NO-064. Các quan hệ cũ được giữ nguyên.

Đã đối chiếu docs/README, product R01/R11, architecture, UX, offline-sync, quality-release và code. Repo có Flutter shell/config/router và tests; chưa có Riverpod/Drift/SQLite, chưa có contracts hoặc backend. NO-007 không phụ thuộc backend, NO-003, theme NO-006, auth provider hay AI.

`adb devices -l` chưa thấy thiết bị ở lúc lập kế hoạch. Đây là điều kiện còn thiếu để hoàn tất device acceptance, không chặn code/unit/widget/migration tests. Không chạy emulator. Thiết bị cần được kết nối lại; device ID phải được khám phá ở lần test.

**Đầu ra:** lần mở đầu không mạng tạo guest UUID, device UUID và profile local; lần mở sau giữ identity; migrations có version, profile scoping và transaction API; test nâng DB không mất dữ liệu. NO-007 chỉ hoàn thành phần guest persistence của R01/R11. Starter/audio ở NO-012; lưu attempt/outbox ở NO-017; login/merge/sync ở các task P2.

### Quyết định kiến trúc

- Một DB app-private trong sandbox mỗi flavor. Guest/device UUID ngẫu nhiên tạo local, không lấy hardware ID. Device identity thuộc installation/sandbox và không thay khi đổi profile. Profile UUID độc lập, không thay khi mở lại app.
- Schema tối thiểu: profiles, installation/device identity và active-profile reference có foreign key. Mọi truy cập dữ liệu profile cần explicit profile ID; bootstrap không thay một active profile đã tồn tại bằng guest mới. Unknown/missing reference phải thành lỗi phục hồi, không tự xóa DB.
- Repository `ensureGuestProfile` chạy trong transaction, trả committed identity; constraint singleton/uniqueness và serialized initialization ngăn tạo trùng khi nhiều caller cùng gọi. API transaction cho future writes yêu cầu profile context; test A/B scope dùng profile fixtures, chưa triển khai account switching.
- Drift versioned schema: baseline phát triển v1 có identity/active profile; v2 thêm tên hiển thị nullable theo UX tên tùy chọn. Xuất snapshot v1 trước khi thay schema, viết migration v1→v2 và fixture có dữ liệu thực. v1 chưa từng phát hành; không mô tả fixture này như người dùng đang có DB cũ. Fresh v2 và migrated v2 phải cùng schema, IDs/dữ liệu cũ phải giữ nguyên.
- Dùng hướng dẫn chính thức [Drift migrations](https://drift.simonbinder.eu/migrations/) cho schema snapshots/test integrity và [transactions](https://drift.simonbinder.eu/dart_api/transactions/) cho atomic writes. Pin phiên bản packages phù hợp Flutter 3.44.8/Dart 3.12.2 tại implementation, kiểm tra setup Android/native SQLite chính thức lúc chọn package; không tự nâng Flutter/AGP.
- Riverpod quản lý/inject DB và repository theo kiến trúc đích; DB mở lazy, không block UI thread. Bootstrap hiển thị loading/error/retry tiếng Việt; shell chỉ được dùng sau commit. Không fallback profile trong RAM, không chạy HTTP/auth khi bootstrap. Lỗi lưu giữ dữ liệu và cho retry; không log nội dung cá nhân.
- Tên mặc định nullable, copy dùng lời chào trung tính; không hard-code Tâm. Chưa thêm UI chỉnh profile hoặc toàn bộ onboarding. Không cần API/server contract mới cho task local này.

### Task List — tracker Kaneo / Bloom

Đã đọc đủ 2 trang/121 task và metadata liên quan trước tạo; không có task con NO-007 trùng. Ba task con dưới đây đã được tạo, đọc lại body và xác minh quan hệ. Kaneo giữ checklist acceptance/verification và trạng thái; không tạo tasks/todo.md hay ghi trạng thái vào backlog.json.

| Thứ tự | Task | Dependency | Scope và files dự kiến |
|---|---|---|---|
| 1 | [NO-007/A · BLO-122 — Lưu guest identity bền bằng Drift](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/q3u6vynfx3sravivsjw5jjh3) | NO-001 Done | M: app_database.dart, identity_tables.dart, guest_profile_repository.dart, repository test, migration test |
| 2 | [NO-007/B · BLO-123 — Bootstrap app từ guest local với retry](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/o2pukry6j0wraw984wklr8g9) | A | M: main.dart, app.dart, profile_bootstrap.dart, bootstrap widget test, scaffold integration harness |
| 3 | [NO-007/C · BLO-124 — Kiểm chứng guest offline trên Android thật](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/task/iq6feh8o2mxknm91u1jsq9s4) | B | M: guest integration test, NO-007 evidence, mobile README, architecture, quality-release |

Native graph: NO-001 → A → B → C (`blocks`); NO-007 là parent qua `subtask` cho A/B/C. Task con đang To Do; không đổi trạng thái/assignee/deadline parent. Acceptance chi tiết, verification, path và phạm vi nằm trong body từng task. Config/lockfiles/build.yaml/generated Drift/schema snapshots của A phải được liệt kê và review riêng; nếu logic vượt khoảng 5 files hoặc thêm đầu ra độc lập thì tách tiếp trước code.

### Checkpoints

Sau A/B:

- [ ] SQLite file reopen giữ IDs; concurrent bootstrap không tạo trùng; injected failure rollback toàn bộ.
- [ ] Profile A/B không truy cập chéo; migration fixture có dữ liệu v1→v2 giữ IDs/fields và schema validation đạt.
- [ ] Widget delayed/failing/retry startup đạt; bốn tab/Back vẫn hoạt động; analyze và dev build sạch.

Sau C, trước chuyển NO-007 In Review/Done:

- [ ] Fresh sandbox offline trên Android thật tạo identity; force-stop/cold launch giữ đúng identity.
- [ ] Dev/staging tách sandbox, cả hai build/smoke đạt; toàn bộ local tests và format/analyze đạt.
- [ ] Evidence ghi rõ commands, runtime, flavor, cách chứng minh offline, upgrade results và giới hạn; không suy build pass thành acceptance pass.

### Lệnh verification dự kiến

Chạy tại apps/mobile/; tên file test mới là đường dẫn dự kiến, chưa tồn tại/chưa chạy trong phiên lập kế hoạch. Analyze/build hiện có được pin từ scaffold.

```sh
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm dart run drift_dev make-migrations
fvm flutter test test/data/local/
fvm flutter test test/profile_bootstrap_test.dart test/navigation_test.dart test/app_config_test.dart
fvm dart format --output=none --set-exit-if-changed lib test integration_test
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug --flavor dev
fvm flutter build apk --debug --flavor staging
adb devices -l
fvm flutter test integration_test/guest_profile_test.dart --flavor dev -d <device-id>
fvm flutter test integration_test/guest_profile_test.dart --flavor staging -d <device-id>
```

Migration tooling chạy lúc tạo/chỉnh schema, không tự regenerate lịch sử bất biến mỗi lần test. Test persistence dùng SQLite thật trên file tạm thay vì mock DB; unit/widget fixture không đọc dữ liệu điện thoại riêng tư. Device smoke dùng fresh test sandbox/harness, kiểm tra identity qua repository trong test, tránh lộ UUID/dữ liệu người dùng trong UI/log. Manual force-stop rồi cold launch bằng harness không xóa DB để so sánh identity trước/sau.

Acceptance body gốc yêu cầu fresh install airplane mode. Đường ưu tiên là USB ADB với thao tác offline được phối hợp; nếu chỉ có wireless ADB, giữ Wi-Fi và chưa tuyên bố đạt airplane-mode acceptance. Có thể bổ sung test-app network isolation được chứng minh để kiểm tra sớm, nhưng cần ghi phương pháp rõ và thống nhất thay thế gate gốc trước khi dùng nó làm evidence hoàn tất. Không tự clear-data/uninstall app đang dùng, không tắt Wi-Fi phone khi wireless ADB.

### Rủi ro và câu hỏi mở

| Rủi ro | Ảnh hưởng | Giảm thiểu |
|---|---|---|
| SQLite/native plugin không tương thích toolchain pin | Build/test bị chặn | Resolve/pin packages và dev build ở A trước UI |
| Concurrent bootstrap hoặc retry sau lỗi tạo identity mới | Mất scope dữ liệu | Transaction + constraints + reopen/concurrency/rollback tests |
| Migration phá dữ liệu hoặc code dùng schema mới khi upgrade | Mất profile | Snapshots versioned + fixture có dữ liệu + validation fresh/upgraded |
| Active profile và queries dùng mặc định ngầm | Trộn dữ liệu tài khoản sau này | Explicit profile context + FK + A/B negative tests |
| Phone chưa kết nối hoặc wireless mất khi airplane mode | Thiếu acceptance thiết bị | Kết nối phone, ưu tiên USB; giữ Wi-Fi wireless; không emulator |

Không có câu hỏi sản phẩm chặn A/B. Chưa kiểm chứng tương thích package/runtime mới; giải quyết sớm ở A. Điều kiện test offline thật còn phụ thuộc phone/USB hoặc phương pháp tương đương được thống nhất. Plan đã được viết để review; chưa được chủ dự án duyệt triển khai, chưa viết code hoặc chạy application checks NO-007. Không spawn agents.
