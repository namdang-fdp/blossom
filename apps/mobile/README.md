# Nở — Android scaffold

NO-001 tạo shell Android với 4 tab: Hôm nay, Kho từ, Luyện câu, Khu vườn. Nội dung hiện là placeholder. Guest/SQLite, starter pack/audio, học và lưu tiến độ thuộc các task tiếp theo; scaffold chưa đáp ứng toàn bộ offline MVP.

## Toolchain

- Flutter **3.44.8** / Dart **3.12.2**, pin trong `.fvmrc`; FVM đã kiểm chứng **4.3.1**.
- JDK **21**; không dùng Java 25 mặc định của shell cho build mobile.
- Gradle wrapper **9.1.0**, Android Gradle Plugin **9.0.1**, Kotlin Gradle plugin **2.3.20**. Kotlin 2.2.0 trong `gradlew --version` là Kotlin nhúng của Gradle, không phải plugin Android.
- Android compile/target SDK **36**, min SDK **24**, build-tools **36.0.0**, NDK **28.2.13676358**.
- Router `go_router` **18.0.2**; commit `pubspec.lock`, `.fvmrc` và Gradle wrapper. Không commit SDK, `local.properties`, signing keys hay build artifacts.

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
fvm dart format --output=none --set-exit-if-changed lib test integration_test
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug --flavor dev
fvm flutter build apk --debug --flavor staging
fvm flutter test integration_test/scaffold_test.dart --flavor dev -d <device-id>
fvm flutter test integration_test/scaffold_test.dart --flavor staging -d <device-id>
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

Bằng chứng NO-001: [commands và smoke đã chạy](../../docs/evidence/NO-001.md).
