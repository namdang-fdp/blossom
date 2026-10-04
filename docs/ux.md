# UX và nhận diện Nở

## Hướng nhìn

**Nền trắng sáng, nội dung học rõ, hồng rose làm điểm nhấn.** Người dùng phải nhìn ra ngay cần học gì và bấm gì tiếp theo. Giao diện nổi bật nhờ hệ thống chữ, khoảng trắng, hoa hồng nguyên bản và điểm nhấn nhất quán. Cảm giác là một sổ học sáng sủa có vườn nhỏ đồng hành.

Chủ dự án chốt hướng này ngày 2026-10-04 sau phản hồi thử trên điện thoại. Bảng màu dưới đây là baseline để làm mockup; sắc độ và component còn cần kiểm chứng trên thiết bị thật. Thay thế palette nền hồng nhạt trước đó.

Mascot là **hoa hồng có biểu cảm nguyên bản**, lấy cảm hứng cơ chế đồng hành của Duolingo; không sao chép hình/âm thanh/nội dung của họ. Tên gợi ý: "bé Hồng" trong copy, chưa phải tên thương hiệu phụ đã chốt.

## Màu và vai trò

| Token | Giá trị | Công dụng |
|---|---|---|
| background | #FFFFFF | Nền chính, gồm màn học và thanh điều hướng |
| surface | #FFFFFF | Nội dung |
| surface-subtle | #F7F8FA | Vùng phụ, ô nhập, nhóm nội dung cần tách nhẹ |
| primary | #C43D68 | CTA chính có chữ trắng, chữ/icon nhấn, trạng thái được chọn |
| on-primary | #FFFFFF | Chữ/icon trên primary |
| rose | #E85D86 | Cánh hoa và điểm nhấn nhận diện |
| primary-soft | #FFF0F4 | Mảng hồng nhẹ cục bộ |
| text | #1F2937 | Chữ chính trung tính |
| text-secondary | #667085 | Giải thích, nhãn phụ |
| leaf | #527A5B | Lá, hỗ trợ trạng thái |

Chữ trắng trên primary có contrast khoảng 4,98:1; text-secondary trên trắng khoảng 4,97:1. Chữ trắng trên rose chỉ khoảng 3,31:1, nên không dùng cặp này cho chữ thường. Mỗi component vẫn phải đo contrast trên nền thực tế, gồm selected/pressed/focus và các mảng hồng nhẹ; chữ thường tối thiểu 4,5:1, icon/chỉ dấu điều khiển mang thông tin tối thiểu 3:1. Surface-subtle chỉ giúp nhóm nội dung, không thay cho đường biên/focus cần thiết để nhận ra ô nhập hoặc điều khiển.

Không phủ hồng toàn màn học hoặc mọi card/tiêu đề. Màu đúng/sai/cảnh báo tách vai trò với màu thương hiệu; phản hồi phải có chữ và dấu hiệu bổ sung, không dùng màu làm dấu hiệu duy nhất. Khi triển khai Flutter, ánh xạ các vai trò qua theme/token dùng chung thay vì hard-code màu ở từng màn.

## Bố cục giúp dễ học

- Một nhiệm vụ và một CTA chính mỗi màn học. Thứ tự đọc: yêu cầu ngắn → câu/ngữ cảnh → vùng trả lời → hành động → phản hồi khi có. Giữ vị trí CTA ổn định, tách các thao tác phụ như nghe lại, gợi ý và thoát.
- Câu tiếng Anh, nghĩa đang học và mẫu dùng là trọng tâm. Phân biệt bằng cỡ/độ đậm và nhãn; chỉ tô điểm phần mẫu mục tiêu khi đang dạy. Bài tự nhớ phải che mẫu và mọi điểm nhấn làm lộ đáp án; chỉ mở theo cơ chế gợi ý đã quy định trong learning-design.
- Chi tiết mục học trình bày nghĩa + mẫu dùng + câu ví dụ + hoàn cảnh; phần giải thích dài có thể mở thêm. Giữ nút audio rõ và gần câu tương ứng, không rút nội dung thành cặp từ/dịch.
- Dùng một họ font sans-serif đọc rõ dấu tiếng Việt; baseline nội dung 16–18sp, tiêu đề 24–28sp, giãn dòng khoảng 1,4–1,6. Dùng ít cấp chữ; tránh font trang trí trong bài tập và tránh chữ phụ quá nhỏ.
- Dùng nhịp khoảng cách 4/8dp, lề ngang baseline 20dp, khoảng cách giữa nhóm 24–32dp; điều chỉnh theo màn nhỏ và text scale. Card bo nhẹ 12–16dp khi thực sự cần nhóm; ưu tiên khoảng trắng, hạn chế khung lồng nhau và bóng đổ.
- Icon cùng một bộ và độ nét nhất quán; tab có nhãn tiếng Việt. Hoa hồng tạo nhận diện ở Hôm nay/Khu vườn/Kết quả; không chiếm vùng trả lời hoặc gây phân tâm trong bài.
- Nội dung hỗ trợ text scale 200%, touch target tối thiểu 48dp, safe area và bàn phím. Màn phải cuộn được khi cần; câu, lỗi và nút tiếp tục không bị che. Motion ngắn; có reduced motion, không đặt animation trước khi được trả lời câu tiếp theo.

## Tham khảo thiết kế

Khảo sát ngày 2026-10-04 dựa trên ảnh giao diện chính thức/ảnh giới thiệu của nhà phát triển, chưa phải kiểm thử trực tiếp các app. Những nhận xét dưới đây là định hướng áp dụng cho Nở, không phải bằng chứng hiệu quả học tập.

| Tham khảo | Học điều gì | Áp dụng |
|---|---|---|
| [Busuu](https://www.busuu.com/) | Vùng bài tập sáng, chữ tối rõ, màu tập trung vào lựa chọn và phản hồi | Tham khảo chính cho Học/Luyện câu |
| [Babbel](https://apps.apple.com/us/app/babbel-language-learning/id829587759) | Câu, nghe/nói và hành động chính nổi bật trên nền sáng | Câu mẫu, audio, thứ bậc nội dung |
| [Quizlet](https://apps.apple.com/us/app/quizlet-more-than-flashcards/id546473125) | Nội dung học ưu tiên trên vùng trắng/xám nhạt | Kho từ và chi tiết mục học |
| [Duolingo — core tabs redesign](https://blog.duolingo.com/core-tabs-redesign/) | Mascot có cá tính, chữ/khoảng cách nhất quán, giảm khung chứa thừa | Hoa hồng, kết quả và tính nhất quán giữa tab |

Giữ nhận diện và nội dung nguyên bản của Nở. Không sao chép màn hình, mascot hoặc kéo leaderboard/tính năng xã hội vào MVP chỉ vì app tham khảo có chúng.

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

### Áp dụng thị giác theo màn

| Màn | Ưu tiên |
|---|---|
| Hôm nay | Nền trắng; hoa nhỏ tạo điểm nhận diện; CTA “Bắt đầu học” hoặc “Tiếp tục học” nổi bật; 5/15/30 phút là lựa chọn phụ. Tránh banner lớn đẩy CTA khỏi màn đầu. |
| Học / Luyện câu | Nền trắng, câu và vùng trả lời chiếm ưu tiên; màu rose ít, phản hồi ngắn chỉ rõ phần cần sửa và cách dùng. |
| Kho từ | Tìm kiếm dễ thấy, danh sách gọn với nghĩa/mẫu phân biệt được; tránh mỗi mục một card trang trí lớn. |
| Kết quả | Báo rõ tự nhớ/nhờ gợi ý/cần ôn; hoa và màu tạo niềm vui sau nỗ lực, CTA học tiếp rõ. |
| Khu vườn | Có thể dùng mảng hồng nhẹ và minh họa nhiều hơn; lịch, trạng thái hoa và bằng chứng tiến bộ vẫn đọc rõ. |

### Checklist cho mockup tiếp theo

- Có Hôm nay, một màn giới thiệu nghĩa/mẫu, một màn tự nhớ, phản hồi sai/có gợi ý, Kết quả, Kho từ và Khu vườn; dùng nội dung tiếng Việt thực tế.
- Nhìn vào màn học thấy ngay yêu cầu, chỗ trả lời và hành động tiếp theo; CTA không cạnh tranh với mascot hoặc nhiều nút cùng độ nổi bật.
- So sánh nền trắng và các vai trò màu trên cùng nội dung; kiểm tra màn Android nhỏ, text scale 200% và bàn phím mở. Đo contrast từng cặp chữ/nền thực tế.
- Có trạng thái offline, đang lưu, lỗi lưu và AI đang chờ; tiến độ và câu hiện tại được giữ đúng hợp đồng offline. Chỉ hiện “Đã lưu” sau commit local thành công.
- Khi có prototype, kiểm chứng với người học mục tiêu: họ hiểu yêu cầu, tìm được audio/gợi ý, trả lời và sửa lỗi mà không cần hướng dẫn. Mockup chưa phải bằng chứng các tiêu chí này đã đạt.

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
