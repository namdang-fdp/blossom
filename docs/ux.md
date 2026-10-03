# UX và nhận diện Nở

## Hướng nhìn

Hồng, dịu, rõ, có cảm giác sổ học và vườn nhỏ. Mascot là **hoa hồng có biểu cảm nguyên bản**, lấy cảm hứng cơ chế đồng hành của Duolingo; không sao chép hình/âm thanh/nội dung của họ. Tên gợi ý: "bé Hồng" trong copy, chưa phải tên thương hiệu phụ đã chốt.

| Token ban đầu | Giá trị | Công dụng |
|---|---|---|
| background | #FFF8FA | Nền |
| surface | #FFFFFF | Nội dung |
| primary | #BE185D | CTA |
| primary-soft | #FCE7F3 | Mảng trang trí |
| text | #352331 | Chữ chính |
| leaf | #527A5B | Lá, hỗ trợ trạng thái |

Đây là đề xuất cần đo contrast ở component thực tế. Không dùng màu làm dấu hiệu đúng/sai duy nhất. Font có dấu tiếng Việt rõ; nội dung hỗ trợ text scale 200%, touch target tối thiểu 48dp. Motion ngắn; có reduced motion, không đặt animation trước khi được trả lời câu tiếp theo.

## Điều hướng

4 tab: **Hôm nay · Kho từ · Luyện câu · Khu vườn**. Hồ sơ/cài đặt từ avatar; Sổ lỗi trong Luyện câu. Cấu hình thuật toán không hiện trong luồng học phổ thông.

### Màn hình thiết yếu

1. Onboarding: tên tùy chọn, mục tiêu, mức tự đánh giá và kiểm tra nhẹ, ngày/giờ học; luôn cho skip. Khởi tạo guest offline. Xin notification permission sau khi giải thích ích lợi.
2. Hôm nay: lời chào dùng tên profile, hoa, một CTA, chọn 5/15/30 phút; nhắc tiếp tục session nếu có. Gói chưa tải có biểu tượng tải, không khiến CTA học bị lỗi.
3. Học: một việc mỗi màn, audio rõ, bàn phím không che câu, nút Chưa nhớ/Gợi ý, lời giải ngắn, thoát giữ tiến độ.
4. Kết quả: phân biệt tự nhớ/nhờ gợi ý/cần ôn; animation chăm hoa; không mở quảng cáo/chặn học tiếp.
5. Kho từ: tìm kiếm local, chủ đề, chi tiết nghĩa/mẫu, đánh dấu cá nhân, sửa, import và quản lý tải.
6. Luyện câu/Sổ lỗi: câu có khung, tự viết, bản nháp offline, trạng thái chờ AI rõ ràng, thử lại lỗi.
7. Khu vườn: trạng thái hoa, lịch tuần, bằng chứng tiến bộ; không hiển thị dữ liệu AI như điểm thi.
8. Cài đặt: nhắc/giờ yên lặng/múi giờ, tải dữ liệu, đồng bộ, liên kết tài khoản, dữ liệu cá nhân/xóa.

## Hoa hồng: quy tắc v1

Hai trục riêng: `growth_stage` là tiến bộ tích lũy không mất; `mood` là độ tươi theo lịch học. Credit ngày học được tính local ngay cả offline. Rule version `rose-v1`.

| Mood | Quy tắc khởi đầu | Hình |
|---|---|---|
| bud | Chưa hoàn thành phiên đầu | Nụ tò mò |
| fresh | Vừa hoàn thành phiên hoặc chưa bỏ lỡ ngày học nào | Tươi, lá khỏe |
| blooming | Đạt số ngày mục tiêu trong tuần hiện tại và không đang bỏ lỡ ngày học | Nở rộ |
| sleepy | Bỏ lỡ 1 ngày học theo lịch | Hơi cúi |
| wilted | Bỏ lỡ từ 2 ngày học theo lịch | Lá/cánh rũ nhẹ |
| recovering | Animation tạm sau phiên quay lại | Ngẩng lên rồi về fresh/blooming |

Thứ tự áp dụng: chưa có credit → bud; có missed days → sleepy/wilted; không missed và đạt goal tuần → blooming; còn lại → fresh. Recovering là animation, không phải trạng thái lưu bền.

Tuần bắt đầu thứ Hai theo múi giờ hồ sơ. Chỉ ngày học đã kết thúc mới được tính bỏ lỡ; nghỉ theo lịch/tạm nghỉ không bị tính. Thay lịch có hiệu lực từ ngày tiếp theo, giữ snapshot lịch sử. Mở app không tự hồi phục hoa; hoàn thành phiên có nỗ lực thì có credit. Growth milestones mặc định 1/3/7/14 ngày có credit, không yêu cầu liên tiếp.

MVP thay **mascot và biểu tượng hoa bên trong app**. Launcher icon dùng hoa tươi cố định; ghi rõ tránh ngầm hứa icon điện thoại sẽ đổi. Xem mở rộng ở decisions.

## Thông báo

- Local-first: lịch trên máy, không phụ thuộc push hoặc Internet để nhắc.
- Mặc định tối đa 1 nhắc/ngày học. Người dùng bật thêm khung dự phòng thì tối đa 2; snooze thay thế lần nhắc dự phòng, không cộng vô hạn.
- Hủy những lần còn lại sau khi có credit hôm đó; giữ quiet hours; xử lý reboot/timezone/đổi lịch. OS có thể trì hoãn, không hứa đúng từng giây; không đòi exact alarm cho nhắc học.
- Bấm thông báo mở phiên ngắn/phiên đang dở; vào offline vẫn học được.
- Copy lock screen mặc định trung tính, tùy chọn gọi tên. Ví dụ: "Hoa hồng đang đợi một buổi học nhỏ 🌹"; "Tâm ơi, ôn vài cụm từ cùng mình nhé".
- Không thông báo “chưa học” từ server dựa trên dữ liệu cũ: Tâm có thể đã học offline. FCM chưa cần cho nhắc học cốt lõi.

## Trạng thái phải thiết kế

Không mạng, tải thiếu audio, bộ từ trống, không có due review, trả lời sai, có gợi ý, đang lưu, hết dung lượng, sync chờ/lỗi/xung đột, token hết hạn, AI hết quota/timeout, thu âm bị từ chối, notification bị từ chối, nội dung bị báo sai.

Thông điệp offline: "Bạn vẫn học bình thường. Tiến độ sẽ đồng bộ khi có mạng." Chỉ hiện "Đã lưu" sau SQLite commit thành công; lỗi lưu cho retry và giữ câu hiện tại.
