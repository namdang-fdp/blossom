# Nở — Android scaffold

NO-001 tạo shell Android với 4 tab: Hôm nay, Kho từ, Luyện câu, Khu vườn. NO-007 bổ sung guest/device identity bền trong SQLite/Drift và bootstrap có retry. Nội dung các tab hiện là placeholder; starter/audio, học và lưu tiến độ còn ở task sau. Chưa đáp ứng toàn bộ offline MVP.

## Toolchain

- Flutter **3.44.8** / Dart **3.12.2**, pin trong `.fvmrc`; FVM đã kiểm chứng **4.3.1**.
- JDK **21**; không dùng Java 25 mặc định của shell cho build mobile.
- Gradle wrapper **9.1.0**, Android Gradle Plugin **9.0.1**, Kotlin Gradle plugin **2.3.20**. Kotlin 2.2.0 trong `gradlew --version` là Kotlin nhúng của Gradle, không phải plugin Android.
- Android compile/target SDK **36**, min SDK **24**, build-tools **36.0.0**, NDK **28.2.13676358**.
- Router `go_router` **18.0.2**; commit `pubspec.lock`, `.fvmrc` và Gradle wrapper. Không commit SDK, `local.properties`, signing keys hay build artifacts.
- Persistence: Drift/drift_dev **2.35.1**, drift_flutter **0.3.1**, sqlite3 **3.5.2**; Riverpod **3.4.3**, path_provider **2.1.6**, UUID **4.6.0**, build_runner **2.15.1**. Direct dependencies và lockfile được pin.

## Chạy từ fresh checkout

Cài FVM, JDK 21, Android SDK/platform 36 và chấp nhận licenses. Đặt `ANDROID_HOME` tới SDK của máy; `JAVA_HOME` trỏ tới JDK 21. Flutter tự ưu tiên JBR của Android Studio nếu đã cài; kiểm tra dòng Java trong doctor và JVM của wrapper trước build.

Từ root repo:

```sh
cd apps/mobile
fvm use 3.44.8
fvm flutter doctor -v
fvm flutter pub get
fvm flutter devices
fvm flutter run --flavor dev -d <device-id>
```

Chạy staging: `fvm flutter run --flavor staging -d <device-id>`. Mỗi flavor có app ID và sandbox riêng:

| Flavor | Android app ID | Tên app |
|---|---|---|
| dev | `com.dorriss.noapp.dev` | Nở Dev |
| staging | `com.dorriss.noapp.staging` | Nở Staging |

Namespace này là identity dev tạm, chưa chốt package phát hành. Bắt buộc chọn flavor; config từ `appFlavor` không fallback ngầm nếu thiếu/sai. Chưa có API client hay staging endpoint; mở app không gọi mạng hoặc yêu cầu đăng nhập. Android flavors theo [Flutter docs](https://docs.flutter.dev/deployment/flavors).

## Kiểm chứng

Chạy tại `apps/mobile/`:

```sh
fvm dart format --output=none --set-exit-if-changed lib test integration_test test_driver
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug --flavor dev
fvm flutter build apk --debug --flavor staging
fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/scaffold_test.dart --flavor dev --no-dds --keep-app-running -d <device-id>
fvm flutter test integration_test/scaffold_test.dart --flavor staging -d <device-id>
fvm flutter test integration_test/guest_profile_test.dart --flavor dev -d <device-id>
fvm flutter test integration_test/guest_profile_test.dart --flavor staging -d <device-id>
```

APK: `build/app/outputs/flutter-apk/app-dev-debug.apk` và `app-staging-debug.apk`. Chỉ dùng debug signing cho scaffold; chưa cấu hình release key hay xuất bản.

Thiết bị kiểm chứng từ giờ là **điện thoại Android thật qua ADB**. Không khởi chạy emulator trên workstation vì gây lag. Tests chạy entrypoint thật và kiểm tra flavor, bốn tab và Back; widget tests kiểm chứng giữ branch stack và màn hình 320×568 với text scale 200%. Shell giữ stack khi đổi tab; Back pop trang con trước, từ tab gốc khác trở về Hôm nay, từ Hôm nay cho Android thoát app. Chưa có lưu bền tab/stack sau process kill.

### ADB qua Wi-Fi

Máy tính và điện thoại cùng Wi-Fi, bật Wireless debugging. Lần đầu ghép nối, lấy IP/cổng trong hộp thoại ghép nối và nhập mã trực tiếp tại prompt:

```sh
adb pair <phone-ip>:<pairing-port>
adb connect <phone-ip>:<connection-port>
adb devices -l
fvm flutter run --flavor dev -d <device-id>
```

Cổng pairing khác cổng connection. IP/cổng có thể đổi; không hard-code endpoint của phiên cũ. Thiết bị cần trạng thái `device`. Trên ColorOS, mở khóa máy và xác nhận cài app khi hộp thoại xuất hiện; nếu bị từ chối cài thì test chưa chạy. Chỉ kiểm tra model/Android runtime và app Nở; không đọc dữ liệu riêng của điện thoại. Để wireless ADB hoạt động, giữ Wi-Fi trên điện thoại trong lúc chạy tests. Offline airplane-mode trên máy thật cần USB ADB hoặc bước thao tác thủ công được phối hợp riêng; không coi integration smoke online là bằng chứng offline.

## Cấu trúc

- `lib/app/`: app root, lifecycle router và shell 4 nhánh theo [StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html).
- `lib/core/config/`: môi trường dev/staging immutable.
- `lib/features/scaffold/`: placeholder dùng chung; feature thực sẽ tách theo task.
- `test/`: config, điều hướng/Back/stack, text scale.
- `integration_test/`: smoke shell Android từ entrypoint thật.

UI dùng locale tiếng Việt; không có tên pilot hard-code. Kiến trúc tiếp theo vẫn Flutter + Riverpod + Drift local-first, Spring Boot + PostgreSQL server. Theo dõi công việc ở Kaneo/Bloom, không tạo `tasks/todo.md` song song.

Theme shell theo [UX hiện hành](../../docs/ux.md): nền, AppBar và thanh điều hướng trắng; primary rose #C43D68, điểm chọn #FFF0F4, chữ tối trung tính. Đây là baseline sau khi tích hợp main vào nhánh thiết kế, chưa phải bộ component hoàn chỉnh NO-006 hoặc mockup đã được duyệt trên điện thoại.

Kiểm chứng tích hợp ngày 2026-10-04, Flutter 3.44.8 / Dart 3.12.2: format sạch, `fvm flutter analyze` không có vấn đề, `fvm flutter test --no-pub` đạt 6 tests (config, bốn tab, stack/Back, màn nhỏ với chữ 200%). Đây là evidence tại thời điểm đổi palette; NO-007 bên dưới đã build và smoke hai flavor trên điện thoại thật với palette này.

Bằng chứng NO-001: [commands và smoke đã chạy](../../docs/evidence/NO-001.md).

## Guest local — NO-007

App mở SQLite `no_local.sqlite` trong application support directory (Android: app-private `files/`), trên background isolate qua drift_flutter. Một transaction tạo profile UUID, device UUID và active-profile reference; shell chỉ hiện sau commit. Mở lại đọc identity đã lưu. Bootstrap lỗi hiện hướng dẫn tiếng Việt và “Thử lại”, không tự xóa DB hoặc tạo hồ sơ tạm trong RAM.

Riverpod sở hữu DB/repository trong ProviderScope của app. Các truy cập profile cần ID tường minh; `withProfile` cung cấp scope để ghi atomically, scope hết hiệu lực sau callback. API này chưa phải authorization cho tài khoản server; account linking/logout/locked profiles thuộc P2.

Schema hiện tại v2. Snapshot v1 là baseline phát triển chưa phát hành; v2 thêm displayName nullable. Test upgrade dùng dữ liệu thật, giữ profile/device UUID và active reference. Thay schema theo [Drift migrations](https://drift.simonbinder.eu/migrations/):

```sh
fvm dart run build_runner build
fvm dart run drift_dev make-migrations
fvm flutter test test/data/local/
```

Commit snapshots và generated Dart; không sửa snapshot cũ. Test integrity do dự án viết ở `test/data/local/migration_test.dart`; generated helpers ở `test/data/local/generated/`. Tool có thể tạo thêm template `migration_test.dart` trong generated directory: chuyển các case có giá trị sang test của dự án, không giữ test integrity với danh sách dữ liệu rỗng.

Android cloud backup được tắt; extraction rules loại DB và journal khỏi device transfer để không clone installation identity. Backup có opt-in của Nở sẽ được xây ở P2. Chưa kiểm chứng OEM device transfer thực tế.

Offline trên wireless ADB: chủ dự án chọn bản Dev release **không có quyền INTERNET**, được ký bằng debug key tạm theo scaffold, thay cho airplane mode. Kiểm tra permission trước cài; giữ Wi-Fi để ADB hoạt động. Không coi debug integration test online là phép thử offline.

```sh
fvm flutter build apk --release --flavor dev --target-platform android-arm64
<android-sdk>/build-tools/36.0.0/aapt dump permissions build/app/outputs/flutter-apk/app-dev-release.apk
adb -s <device-id> install -r build/app/outputs/flutter-apk/app-dev-release.apk
adb -s <device-id> shell am force-stop com.dorriss.noapp.dev
adb -s <device-id> shell am start -W -n com.dorriss.noapp.dev/com.dorriss.noapp.MainActivity
```

Chạy các lệnh Flutter tuần tự: build và test đồng thời có thể tranh chấp generated plugin registrant. Driver dùng `--keep-app-running` để tránh cleanup uninstall của Flutter; integration tests chỉ chạy trên flavor/sandbox dành cho test, vì runner có thể dọn app khi kết thúc. Không clear-data/uninstall app đang dùng để tạo fresh sandbox. Evidence NO-007 ghi rõ cách kiểm tra identity trước/sau cold launch và các lệnh đã chạy: [NO-007](../../docs/evidence/NO-007.md).
