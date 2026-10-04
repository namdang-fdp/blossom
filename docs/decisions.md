# Quyết định và điểm cần xác minh

## Đã được chủ dự án chốt

| Quyết định | Kết quả |
|---|---|
| Tên sản phẩm | Nở; project tracker tên Bloom |
| Đối tượng đầu | Tâm, nền tảng yếu, giao tiếp + VSTEP B1 khoảng giữa 2027 |
| Client | Flutter, Android trước |
| Backend | Spring Boot, PostgreSQL |
| Offline | Bắt buộc; SQLite/Drift trên máy. Thay thế hoàn toàn đề xuất online-first trước đó |
| Nhận diện | Nền trắng sáng, hồng rose làm điểm nhấn, chữ tối trung tính; nội dung học và CTA nổi bật. Mascot hoa hồng; học đều thì nở, nghỉ lâu thì rũ và có nhắc. Palette baseline và quy tắc mockup ở [ux.md](ux.md) |
| Nội dung | Từ, giới từ/cụm, mẫu câu, hoàn cảnh, active recall, nhớ lâu, import |
| Công việc hiện tại | Docs/backlog MVP đã có; scaffold Flutter Android và Spring Boot đã tích hợp. Các tính năng học/offline/sync tiếp tục theo từng task trong Kaneo/Bloom |

## Quyết định triển khai đề xuất để lập kế hoạch

- Guest-first, starter pack/audio đi kèm; AI không phải dependency của buổi học.
- Modular monolith; local database là nơi UI đọc/ghi; outbox và event replay cho sync.
- FSRS có adapter Dart/Java cùng version và conformance test; xác minh thư viện trước.
- Firebase Auth Google sign-in cho backup beta; nhà cung cấp và cấu hình có thể đổi qua ADR trước khi code auth.
- Local notifications cho thói quen; chưa dùng FCM nhắc dựa trên tiến độ server.
- 160 mục/cụm được biên tập cho beta, gồm starter 20; không gọi là giáo trình VSTEP đầy đủ.
- Mascot động trong app, launcher cố định trong MVP. Launcher icon/Android widget động ghi nhận là mở rộng, chưa hứa cùng behavior trên mọi launcher.

## Cần xác minh nhưng không chặn viết docs

| Câu hỏi | Task xử lý |
|---|---|
| Máy Android/phiên bản/dung lượng của Tâm; thời gian offline thường gặp | Thiết bị pilot và offline acceptance |
| Cơ sở nội dung và người review tiếng Anh | Content authoring/review trước beta |
| Tên Nở/package ID có trùng và quyền sử dụng asset/audio | Brand + release checks |
| Dart/Java FSRS parity và license | Feasibility scheduler sớm |
| Nhà cung cấp AI, TTS, ngân sách/region | Adapter/quota và audio pipeline trước tích hợp |
| Play account loại nào, yêu cầu closed test hiện tại | Release preparation |
| Ngày thi cụ thể | Cài đặt mục tiêu; không hard-code tháng thi |

## Cập nhật

2026-10-04: offline-first là yêu cầu bắt buộc theo chỉnh sửa cuối của người dùng; PostgreSQL vẫn giữ phía server. Không còn kế hoạch bỏ SQLite.

2026-10-04: sau phản hồi thử trên điện thoại, chủ dự án chốt cập nhật docs sang nền trắng sáng, đổi hồng theo hướng rose và ưu tiên dễ học. Palette baseline: primary #C43D68, rose #E85D86, primary-soft #FFF0F4. Mockup do chủ dự án làm sau; chưa coi palette/component đã được kiểm chứng trên thiết bị và chưa thay đổi ứng dụng.

2026-10-04 (backend planning): chủ dự án yêu cầu tham khảo Vey, folder tương tự và bật toàn bộ hạ tầng ngay. Layout đích là `api/`, `frontend/` (Flutter), `compose.yml` ở root. Redis/Kafka/MinIO/JobRunr được thêm vào scope setup; đây là mở rộng so với NO-002 gốc. Modular monolith bằng package, một Maven project/JAR và transaction/outbox boundary là đề xuất trong plan; chưa triển khai, chưa cập nhật task live.

2026-10-04 (backend scaffold): chủ dự án duyệt thực thi. Scaffold một Maven project/package modular monolith theo Vey được tạo ở `api/`, cùng stack Compose đầy đủ. Transactional outbox vẫn là boundary cho side effects trong các task domain sau. Xem `docs/backend-scaffold.md` cho evidence; Kaneo đọc bị 403, chưa cập nhật board.

2026-10-04 (chốt lại layout sau merge): chủ dự án giữ Flutter tại `apps/mobile/` cho app Android; `frontend/` dành cho web trong tương lai, chưa chọn stack hay scaffold web. Backend vẫn tại `api/`. Quyết định này thay thế vị trí Flutter trong kế hoạch backend ban đầu.

2026-10-04 (tích hợp nhánh thiết kế): nhập hai PR scaffold từ main, giữ quyết định nền trắng/hồng rose. Theme shell Flutter được chỉnh theo palette baseline ở ux.md; bộ component NO-006 và kiểm chứng mockup trên điện thoại vẫn là công việc tiếp theo.
