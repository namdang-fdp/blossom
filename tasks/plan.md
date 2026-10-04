# Kế hoạch thực thi Nở MVP

Ngày lập: 2026-10-04. Task tracker: **Kaneo / Bloom**. Đặc tả sản phẩm bắt đầu ở [docs/README.md](../docs/README.md).

## Đầu ra được yêu cầu hiện tại

Tạo tài liệu và backlog đầy đủ, chưa triển khai app. Mọi task implementation mới tạo ở To Do. Không lấy việc lập kế hoạch làm bằng chứng tính năng đã hoạt động. Repo ban đầu trống, chưa có build/test ứng dụng.

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
