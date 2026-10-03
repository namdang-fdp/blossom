# Thiết kế học tập

## Đơn vị nội dung

Một `learning_item` liên kết `sense` (nghĩa), tối đa một mẫu dùng chính và mục tiêu kiểm tra. Từ nhiều nghĩa có nhiều sense. Các mục có chung một mẫu có thể dùng chung dữ liệu biên tập; trạng thái học thuộc người học và mục tiêu, không thuộc chuỗi ký tự từ.

Trường bắt buộc cho bộ biên tập: lemma/cụm, từ loại, nghĩa tiếng Việt, mẫu có kiểu slot, cụm thường dùng, 2 câu tự biên soạn, giải nghĩa câu, tình huống/register, lỗi điển hình, đáp án/chấp nhận biến thể, audio, topic, mức hỗ trợ, nguồn/quyền sử dụng, revision, người/trạng thái duyệt. Không gom mọi giới từ vào một luật tuyệt đối.

Ví dụ:

```text
lemma: interested
sense_vi: quan tâm, hứng thú
pattern: be interested in + noun/V-ing
example: I am interested in learning English.
context: nói về sở thích hoặc điều muốn tìm hiểu; trung tính
contrast: interested = cảm thấy hứng thú; interesting = gây hứng thú
common_error: I interested in learn English.
feedback: thêm am; sau in trong mẫu này dùng learning.
```

## Vòng dạy một mục

1. Hiểu câu và nghe audio; có giải nghĩa tiếng Việt.
2. Nhận diện mẫu với lựa chọn/gợi ý — hoạt động làm quen, không coi là recall độc lập.
3. Điền giới từ/cụm có đáp án; sau đó che mẫu và tự nhớ lại.
4. Dựng câu có khung; dùng thông tin cá nhân tùy chọn.
5. Tự viết một câu không hiện khung; cho xem gợi ý nếu cần, ghi nhận đã hỗ trợ.
6. Buổi sau gặp câu mới cùng mục tiêu; không chỉ lặp nguyên câu mẫu.

Một phiên nhỏ không buộc làm mọi bước cho mọi từ. Mục chưa giới thiệu không xuất hiện dưới dạng kiểm tra khó. Chọn bài theo phiên bản gói đã lưu để đáp án không đổi giữa phiên.

## Chấm bài

- Bài đóng chấm local, sử dụng đáp án/biến thể được biên tập. Chuẩn hóa khoảng trắng, case và dấu câu khi không phải mục tiêu; không bỏ qua từ phủ định, giới từ hoặc dạng động từ đang kiểm tra.
- Lỗi typo có thể nhận phản hồi "gần đúng" nhưng không tự ghi nhận đúng chính tả. Phân biệt meaning/pattern/spelling; chỉ outcome được thiết kế cho mục tiêu tương ứng mới tác động lịch ôn.
- Hint level: `none`, `semantic`, `first_letter`, `answer_shown`. Gợi ý làm lộ phần mục tiêu => assisted, không độc lập nhớ đúng.
- Câu tự do: local chỉ cung cấp checklist/mẫu tham khảo và lưu bài; không giả vờ hiểu ngữ nghĩa bằng regex. Có thể tự đánh giá, nhưng gắn nhãn self-reported.
- AI khi online trả `meaning_feedback`, `target_pattern_feedback`, `suggested_sentence`, tối đa 2 giải thích chính bằng tiếng Việt. Câu đúng với cách diễn đạt khác được công nhận; thiếu mẫu mục tiêu thì mời thử lại, không gọi câu sai.
- AI timeout/lỗi => giữ nháp, cho retry, không trừ quota hai lần và không chặn buổi học. Người dùng có nút báo chấm sai.

## Lịch ôn

Ưu tiên FSRS, chạy được local không mạng. Task feasibility phải chọn cùng phiên bản thuật toán/parameter set cho Dart và Java, kiểm tra license và conformance vectors trước khi pin thư viện. Nếu không có thư viện phù hợp, viết ADR về phương án; không tự thay lịch khác rồi vẫn ghi FSRS.

- Ban đầu parameter mặc định đã version hóa; chưa tối ưu cá nhân từ quá ít dữ liệu.
- Mỗi mục có tối đa hai review target khởi đầu: `meaning_recall`, `pattern_recall`. Nghe và vận dụng lưu bằng chứng riêng; chưa tạo bốn lịch ôn cho mọi mục.
- Chỉ bài recall khách quan đủ điều kiện cập nhật SRS. Đúng sau khi lộ mục tiêu -> Again/assisted; sai -> Again; đúng độc lập -> Good; Hard chỉ khi thực sự nhớ đúng nhưng khó và người dùng chủ động chọn. Không suy Hard/Easy chỉ từ tốc độ gõ.
- Trong một session, một review target chỉ có một event cập nhật lịch; lần sửa lại là practice event. Card anh em được giãn khỏi nhau, tránh câu trước làm lộ đáp án câu sau.
- Phân biệt review/practice/delayed_probe trong attempt. AI, ghép đáp án, đọc mẫu không tự tăng mastery.
- Lịch local cập nhật ngay và provisional khi còn event chưa sync; sau sync replay theo quy tắc ở [offline-sync](offline-sync.md).

## Chọn phiên và báo tiến bộ

Phiên 5/15/30 phút là ngân sách, không ép đủ thời gian. Mặc định tối đa 3 mục mới/phiên, 5 mục mới/ngày; điều chỉnh sau pilot. Ưu tiên due reviews, tránh dồn backlog; không đổi due date chỉ để giấu lượng ôn còn lại. Có nút tiếp tục học và phiên quay lại ngắn.

Một phiên đủ điều kiện chăm hoa: hoàn thành ít nhất 3 prompt có nỗ lực trả lời, hoặc hết toàn bộ kế hoạch khi chỉ có 1–2 prompt. Không yêu cầu đúng tất cả, không tính mở app hay lật mẫu liên tục. Cùng ngày tối đa một credit thói quen; kiến thức vẫn cập nhật từng câu.

Tiến bộ tách: nhận ra nghĩa / tự nhớ nghĩa / nhớ mẫu / đã thử dùng. "Đã thử dùng" không đồng nghĩa thành thạo; không đặt nhãn "đã thuộc vĩnh viễn".

## Nội dung beta

Starter 20 mục thuộc sinh hoạt/sở thích; mở rộng tổng 160 mục (bao gồm starter) qua 8 chủ đề: bản thân, gia đình, sinh hoạt, học tập, công việc, ăn uống, đi lại, sức khỏe & môi trường. Chủ đề cuối có thể tách thành 2 gói; tổng scope vẫn 160. Mức ưu tiên dựa trên nền tảng và B1, chưa gắn nhãn "danh sách chính thức VSTEP".

Quy trình: soạn → kiểm tra nghĩa/mẫu/đáp án → review sư phạm → audio và quyền sử dụng → validate gói → phát hành revision bất biến. Cần người có chuyên môn kiểm tra trước beta công khai; AI draft không tính là review độc lập.
