# Nở — sản phẩm và MVP

## Bài toán

Giúp người Việt nền tảng tiếng Anh yếu biến từ đã biết nghĩa thành câu tự dùng được, nhớ lâu và duy trì học dù bận hoặc thường xuyên mất mạng.

Người dùng đầu tiên là **Tâm**: học để giao tiếp và hướng tới **VSTEP B1 khoảng tháng 6–7/2027**; khó nhớ, khó nói/viết và hay quên học. Có thể dành tối đa khoảng một tiếng/ngày, nhưng app phải hữu ích trong phiên 5 phút. Không hard-code tên Tâm vào tài khoản của người dùng khác.

## Định vị

**Nở — Từ quen, câu của bạn.**

Lõi khác biệt đề xuất: học cả nghĩa, collocation, giới từ, mẫu cấu trúc và hoàn cảnh; giảm dần gợi ý; ôn lại đúng phần người học dùng sai. Đây là giả thuyết sản phẩm cần kiểm chứng, không khẳng định thị trường chưa có app tương tự. Xem [nguồn khảo sát](sources.md).

## Vòng giá trị

Chọn bài/từ → hiểu trong ngữ cảnh → nhớ lại → dùng trong câu → nhận phản hồi → ôn sau một khoảng thời gian → thấy tiến bộ và hoa hồng hồi phục/phát triển.

Mỗi mục học là **một nghĩa + một mẫu dùng có mục tiêu**, không phải một từ ôm tất cả nghĩa. Ví dụ `interested`, nghĩa quan tâm/hứng thú, mẫu `be interested in + noun/V-ing`.

## Phạm vi bắt buộc

| ID | Năng lực | Điều kiện sản phẩm |
|---|---|---|
| R01 | Bắt đầu offline | Guest profile; starter pack 20 mục và audio đóng gói; không có login wall |
| R02 | Buổi học tự phối | 5/15/30 phút, được học tiếp; ưu tiên ôn cũ, giới hạn từ mới; lưu từng câu |
| R03 | Cách dùng từ | Nghĩa tiếng Việt, mẫu dùng, cụm, ví dụ, âm thanh, hoàn cảnh và lỗi điển hình |
| R04 | Luyện tập | Recall có gõ, điền giới từ/cụm, hoàn thành câu, câu cá nhân; nghe mẫu và thu âm tự nghe |
| R05 | Nhớ lâu | Lịch ôn chạy local, có gợi ý khác với tự nhớ; theo dõi meaning/pattern; kiểm tra trì hoãn |
| R06 | Sổ lỗi | Lỗi khách quan và phản hồi AI được phân biệt; mở lại bài tập phù hợp với lỗi |
| R07 | Kho từ cá nhân | Thêm/sửa/xóa, tìm kiếm, phân biệt nghĩa; import paste/CSV offline có preview |
| R08 | Hoa hồng | Có biểu cảm, nở khi học đều, rũ khi bỏ lịch; hồi phục khi học lại; không chết/mất tiến bộ |
| R09 | Nhắc và thói quen | Local notifications offline, opt-in, giờ yên lặng, hoãn, ngừng sau khi đã học |
| R10 | Gói nội dung | 150–200 mục/cụm đã biên tập cho beta, 8–10 chủ đề; tải audio/bài để học offline |
| R11 | Đồng bộ | Đăng nhập tùy chọn để backup; gửi lại không trùng; xử lý conflict, xóa và chuyển tài khoản |
| R12 | AI bổ trợ | Sửa câu ngắn bằng tiếng Việt khi có mạng, quota; offline lưu nháp/đợi gửi; không quyết định SRS |
| R13 | Phát hành Android | Build ký số, dữ liệu/tài khoản, crash handling, kiểm thử thiết bị thật, closed test |

## Ranh giới

- MVP hỗ trợ xây nền từ vựng/cách dùng hướng tới B1; **không phải khóa luyện thi VSTEP đầy đủ**, không dự đoán/cam kết đỗ.
- Chưa có thi thử bốn kỹ năng, chấm điểm VSTEP tự động, live voice tutor, chấm phát âm chuyên sâu, OCR/PDF/YouTube import, xã hội/leaderboard, subscription hoặc cửa hàng vật phẩm.
- Import từ không có mẫu dùng vẫn tạo bài học nghĩa; chỉ sinh bài cấu trúc khi có dữ liệu đã kiểm tra. AI không tự xuất bản nội dung chuẩn.
- iOS và web để sau Android. Mascot/icon bên trong app thay đổi theo học tập; launcher icon bên ngoài app cố định trong MVP. Widget/launcher động là mở rộng riêng cần thử nền tảng.
- Offline không bao gồm đăng nhập mới, tải gói chưa có, đồng bộ server hay phản hồi AI mới. Những giới hạn này phải rõ, nhưng không cản học nội dung có sẵn.

## Đo hiệu quả

Không dùng số từ import hoặc streak làm đại diện cho năng lực. Đo:

1. Recall không gợi ý sau ít nhất 7 ngày từ lần đầu học; ghi nhận số mẫu và thời gian kể từ lần ôn gần nhất. Không gọi đây là phép đo "7 ngày không ôn" nếu đã ôn giữa chừng.
2. Tỷ lệ dùng mẫu đúng trong câu mới theo rubric biên tập; báo riêng với điểm AI.
3. Số buổi học có ý nghĩa/tuần; quay lại sau ngày nghỉ; thời gian để bắt đầu phiên đầu.
4. Hoàn thành phiên offline và tỷ lệ đồng bộ không mất/trùng dữ liệu.

Thử với Tâm rồi 8–12 người phù hợp trong 2–4 tuần. Mốc thử ban đầu: ít nhất 70% người thử bắt đầu và hoàn tất bài mẫu không cần người hướng dẫn; không mất dữ liệu trong toàn bộ kịch bản offline bắt buộc; đa số phản hồi hiểu được cách dùng sau bài. Đây là ngưỡng quyết định nội bộ, chưa phải cam kết hiệu quả khoa học. Không tuyên bố causal efficacy từ nhóm nhỏ.
