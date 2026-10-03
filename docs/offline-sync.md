# Offline là hợp đồng bắt buộc

## Ma trận hành vi

| Tính năng | Không mạng | Khi có mạng lại |
|---|---|---|
| Lần mở đầu | Guest + starter 20 mục, audio đi kèm | Có thể liên kết account/tải thêm |
| Học và chấm bài đóng | Đủ chức năng local | Đồng bộ attempt, giữ kết quả |
| Lịch ôn qua nhiều ngày | Tính local theo due và clock đã lưu | Reconcile bằng event log |
| Hoa/nhắc học | Tính và nhắc local | Đồng bộ credit, không chăm hoa hai lần |
| Gói đã tải | Đọc và nghe offline | Tải revision mới khi được phép |
| Từ riêng/import CSV | Tạo/sửa/xóa, preview local | Sync operations có version |
| Câu tự do/thu âm | Lưu nháp, checklist; thu âm/nghe local | Gửi AI chỉ khi đã bật/đồng ý; recording không tự upload |
| Đăng nhập mới/AI/tải mới | Giải thích cần mạng; không chặn học | Retry có giới hạn và thao tác thủ công |

## Ghi local

Một SQLite transaction ghi attempt + session progress + review projection + outbox event + daily credit (nếu đủ điều kiện). Chỉ chuyển UI sang “đã lưu” khi transaction commit. Disk full/DB error giữ input để retry. Force-kill sau commit khôi phục không thiếu/nhân đôi câu.

Session chứa prompt/content revision và thứ tự đã chọn. Gói cập nhật không đổi câu đang làm. Audio tải vào file tạm, xác nhận hash rồi đổi tên/commit trạng thái; gói chỉ là `offline_ready` khi đủ nội dung và audio bắt buộc.

## Đồng bộ v1

1. Đọc outbox theo dependency order; guest chưa link thì chỉ giữ local.
2. Push batch với operation UUID, device UUID, local sequence, schema version, occurredAt, timezone/learningDate, base entity revision và payload typed.
3. Server transaction: xác minh ownership + schema, idempotency `(user_id, operation_id)`, áp dụng hoặc ghi conflict; trả ack/status riêng từng operation. Retry operation đã thành công trả cùng kết quả. Batch có lỗi một item không khiến client xóa cả batch.
4. Client lưu ack và trạng thái outbox atomically; chưa ack thì không xóa event. Backoff có jitter; auth fail giữ hàng đợi, yêu cầu login lại khi online.
5. Pull change stream bằng opaque cursor, gồm tombstone và projection revisions. Áp dụng từng page + cursor trong một transaction. Cursor hết hạn dùng snapshot rồi rebase các outbox operation còn pending.
6. UI luôn đọc SQLite. Có last synced/pending/errors và nút sync; connectivity signal chỉ là gợi ý, HTTP thành công mới chứng minh kết nối.

## Xung đột

- Attempts/review events append-only; UUID dedupe. Không dùng last-write-wins cho lịch sử học.
- Mục từ/ghi chú cá nhân dùng optimistic revision; conflict giữ hai phiên bản cho người dùng chọn, không âm thầm ghi đè. Cùng văn bản nhưng khác sense không tự merge.
- Xóa dùng tombstone. Update từ máy cũ không tự phục hồi đối tượng đã xóa; muốn khôi phục là thao tác mới có xác nhận. Tombstone duy trì ít nhất suốt MVP; trước pruning phải có full-resync protocol.
- Preferences lịch học có revision; xung đột yêu cầu chọn lịch, không sửa ngược ngày đã học. Draft câu tự do tạo fork khi hai thiết bị sửa cùng base revision.
- Gói biên tập read-only; người dùng tạo override/note riêng. Không sửa gói chung qua learner API.

## Replay và thời gian

Event lưu thời điểm gốc, device sequence, thời điểm nhận server và effectiveReviewAt đã chuẩn hóa. Client tính local từ cùng adapter clock. Server dùng thứ tự tổng ổn định `(effectiveReviewAt, deviceId, deviceSequence, eventId)`; effectiveReviewAt không lùi trong cùng device sequence, timestamp tương lai quá 5 phút so với receive time bị clamp và gắn cờ. Những event cũ sync muộn vẫn được giữ, kích hoạt replay từ điểm ảnh hưởng.

Khi có nhiều thiết bị offline, lịch ôn sau reconcile có thể đổi; không mất attempt. Client áp dụng projection canonical rồi replay pending events của mình; không ghi đè pending attempts bằng snapshot. Clock skew và timezone cần fixtures thực tế; không dùng receivedAt để gán mọi lượt offline thành học cùng một ngày.

Daily credit dùng learningDate/timezone lúc hoàn thành session, unique theo user và ngày; không cộng lại khi retry hoặc nhập guest. Thay múi giờ áp dụng tương lai; lịch sử vẫn có thông tin gốc. Không dùng hệ thống này để thưởng giá trị tiền tệ hoặc chống gian lận thi.

## Guest, logout và account

Guest học offline vô thời hạn trên thiết bị. Khi link account, preview số mục/lượt học sẽ merge và account đích; xác nhận một lần. Migration có ID chống lặp, giữ UUID cũ, giữ guest snapshot đến khi server ack hoàn tất. Account đã có dữ liệu thì union attempts, merge hoặc conflict mục cá nhân theo quy tắc trên.

Logout không được xóa âm thầm dữ liệu chưa sync: người dùng chọn sync khi online hoặc giữ profile local bị khóa khỏi account khác. Account B không nhìn thấy outbox/private data của A. Token hết hạn không khóa việc học local đã có; chỉ hoãn network operations. Gỡ app làm mất guest chưa backup — giải thích khi bật backup và trước thao tác xóa local, không nhắc cản trở mỗi buổi.

## Acceptance bắt buộc

- Cài mới, airplane mode, mở app, học starter và nghe audio thành công.
- Học/ôn ba ngày mô phỏng offline; force-kill/reboot giữa các bước; không mất lịch sử và lịch ôn tiếp tục chạy.
- Mạng chập chờn sau server commit nhưng trước response: retry không tạo attempt/credit/AI charge thứ hai.
- Hai thiết bị có event trùng/lệch thứ tự; replay hội tụ với cùng tập event.
- Sửa/xóa cùng mục từ offline rồi sync: có conflict rõ, không hồi sinh do update cũ.
- Token hết hạn, cursor hết hạn, thiếu dung lượng, migration SQLite từ version cũ, guest merge bị ngắt đều phục hồi có kiểm chứng.
