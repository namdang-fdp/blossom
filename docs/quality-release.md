# Chất lượng và phát hành MVP

## Definition of Done của task

Acceptance criteria đạt; kiểm tra phù hợp phạm vi có bằng chứng; docs/contracts không mâu thuẫn; không chứa secret; không làm mất dữ liệu offline. Task chưa đạt không chuyển Done. Command backend hiện được pin ở `api/README.md` và evidence ở `docs/backend-scaffold.md`; mobile chưa scaffold.

Lệnh dự kiến: `flutter analyze`, `flutter test`, `flutter test integration_test`, `flutter build appbundle`, `./mvnw test`, `./mvnw verify`. Backend: chạy wrapper trong `api/`, Java 25; `test` chạy unit/architecture, `verify` thêm integration, Spotless và Checkstyle. Testcontainers có thể cần Docker; không báo test pass nếu môi trường không chạy được.

## Các lớp kiểm chứng

| Lớp | Kiểm tra cần thiết |
|---|---|
| Domain | Chấm mục tiêu, hint mapping, FSRS vectors, session planner, rose state machine, timezone |
| Persistence | Transaction, migration SQLite/Flyway, force-kill, disk full, idempotency, tombstone |
| API | Ownership, schema/version, pagination, partial ack, 401/403/409/429, rate limits |
| UI | Keyboard, screen nhỏ, text scale, TalkBack, reduced motion, offline states |
| Device | Airplane mode, process kill/reboot, notification permission, mic denial, low storage |
| End-to-end | Guest first lesson → link → sync → restore; import → study → error → review |
| Content | Nghĩa/mẫu/biến thể, audio, quyền sử dụng, không sao chép đề thi không được phép |

Ưu tiên test rủi ro dữ liệu/thuật toán. Không viết test chỉ lặp lại literal UI hoặc khóa từng pixel không có giá trị.

## Release gates

1. Không mất/trùng dữ liệu trong offline matrix; mọi P0/P1 được xử lý.
2. Starter 20 mục hoạt động hoàn toàn offline; tổng 160 mục beta được review và tải được với audio.
3. Câu AI không chặn học, có quota/error handling, user có thể report; không dùng AI làm điểm VSTEP.
4. Hoàn tất walkthrough với Tâm trên thiết bị thật; kiểm tra thêm Android màn hình nhỏ và máy cấu hình thấp phù hợp minSdk đã chọn.
5. Privacy policy mô tả dữ liệu local/server/provider thật; Data Safety khớp SDK và hành vi thực tế. Có xóa tài khoản trong app và web entry nếu tạo tài khoản.
6. App ID/keystore thuộc chủ dự án; bản AAB ký số qua secret store, không commit key. Brand/package identity đã kiểm tra trước phát hành.
7. Staging deployment hoạt động, backup có restore test; quan sát crash/sync failure không lộ câu cá nhân.
8. Closed test theo loại tài khoản Play hiện tại; tài khoản cá nhân thuộc diện quy định cần 12 tester liên tục 14 ngày trước khi xin production access. Kiểm tra lại quy định/target API khi phát hành, không đóng băng theo tài liệu hôm nay.

## Nội dung dữ liệu cá nhân

Tên thật tùy chọn; không bật upload recording mặc định. Chỉ gửi câu viết tới AI khi người dùng bật tính năng/đồng ý, giải thích dữ liệu nào rời máy. Log bỏ token/raw writing/audio. Deletion vô hiệu hóa sync cũ để thiết bị lâu ngày không tạo lại account/dữ liệu đã xóa; local wipe khi kết nối lại và phát hiện trạng thái revoked, còn thiết bị offline chỉ xử lý khi nhận được trạng thái.

Không triển khai thanh toán trong MVP, nên không cần thêm billing chỉ để phát hành beta miễn phí.

## Pilot

Tâm dùng starter trước; quan sát hiểu hướng dẫn, gợi ý và thao tác bàn phím. Sau khi đạt offline gate, mở beta 8–12 người để học trong 2–4 tuần; nếu Play cần 12 người đủ điều kiện thì tuyển đủ theo quy định đó. Ghi nhận baseline và sample size; không suy thành công chung từ một người. Dùng feedback để điều chỉnh số từ mới, độ dài phiên, mức hỗ trợ, nhịp nhắc.
