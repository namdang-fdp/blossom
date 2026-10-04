# Nở — Từ quen, câu của bạn.

App học tiếng Anh Android, Flutter + SQLite/Drift để học offline. Backend Spring Boot là modular monolith trong một Maven project.

## Chạy Flutter Android

Flutter 3.44.8 được pin bằng FVM. Build mobile dùng JDK 21; backend dùng JDK 25. Đọc [mobile README](frontend/README.md) trước khi chạy.

```sh
cd frontend
fvm use 3.44.8
fvm flutter pub get
fvm flutter run --flavor dev -d <device-id>
```

Mobile hiện có scaffold 4 tab và config dev/staging. SQLite/Drift, starter pack/audio và luồng học offline thuộc task tiếp theo. Thiết bị test dùng điện thoại thật qua ADB; không launch emulator.

## Chạy backend local

Cần Java 25 và Docker Compose. Đọc [API README](api/README.md) để cấu hình và kiểm chứng.

```sh
make infra
cd api
SPRING_PROFILES_ACTIVE=local ./mvnw spring-boot:run
```

Hoặc chạy cả API bằng Docker:

```sh
make app
```

API: http://localhost:8082/api/v1/health. Readiness: http://localhost:8082/actuator/health/readiness. Swagger local: http://localhost:8082/swagger-ui/index.html.

```sh
make check
```

Lệnh trên chạy format/style, architecture tests và integration tests dùng PostgreSQL, Redis, Kafka, MinIO thật qua Testcontainers; cần Docker. `make test` chỉ chạy unit/architecture tests.

Hạ tầng local dùng port riêng để chạy cùng Vey. `.env.example` chỉ chứa giá trị dev; copy thành `.env` nếu cần override Compose. `.env` không tự cấu hình JVM chạy trên host.

Đặc tả: [docs/README.md](docs/README.md). Kế hoạch: [tasks/plan.md](tasks/plan.md). Bằng chứng scaffold: [docs/backend-scaffold.md](docs/backend-scaffold.md).
