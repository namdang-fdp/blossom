# Nở — Từ quen, câu của bạn.

Ứng dụng học tiếng Anh cho người Việt, Android-first và học offline. Project trên Kaneo: **Bloom**.

- [Ứng dụng Flutter Android và hướng dẫn chạy](apps/mobile/README.md)
- [Đặc tả sản phẩm](docs/README.md)
- [Kế hoạch thực thi](tasks/plan.md)
- [Kaneo / Bloom](docs/kaneo.md)

```sh
cd apps/mobile
fvm use 3.44.8
fvm flutter pub get
fvm flutter run --flavor dev
```

Hiện có scaffold 4 tab và config dev/staging. SQLite/Drift, starter pack/audio và luồng học offline được triển khai ở các task tiếp theo; backend Spring Boot/PostgreSQL chưa được scaffold.
