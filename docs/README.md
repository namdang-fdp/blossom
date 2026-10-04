# Nở — bộ nhớ dự án

Ngày lập: 2026-10-04. Tên sản phẩm: **Nở**. Tên project trên Kaneo: **Bloom**.

Đây là đặc tả và kế hoạch triển khai, không phải mô tả chức năng đã được xây dựng. Repo chưa có ứng dụng tại thời điểm lập tài liệu. Nội dung sản phẩm viết bằng tiếng Việt; mã nguồn dùng định danh tiếng Anh.

## Đọc theo thứ tự

1. [Sản phẩm và phạm vi MVP](product.md)
2. [Thiết kế học tập](learning-design.md)
3. [UX, nhận diện và hoa hồng](ux.md)
4. [Kiến trúc và mô hình dữ liệu](architecture.md)
5. [Hợp đồng offline và đồng bộ](offline-sync.md)
6. [Chất lượng, kiểm thử và phát hành](quality-release.md)
7. [Quyết định và vấn đề còn mở](decisions.md)
8. [Nguồn tham khảo](sources.md)
9. [Kế hoạch thực thi](../tasks/plan.md) và [chỉ mục task](backlog.md)
10. [Cách sử dụng Kaneo cho dự án](kaneo.md)

## Nguồn sự thật

- `docs/`: yêu cầu, quyết định và tiêu chí sản phẩm.
- Kaneo / Bloom: trạng thái, người phụ trách và thảo luận của từng task khi kết nối thành công.
- `docs/backlog.json`: snapshot đặc tả task và mã ổn định `NO-xxx`, dùng để khởi tạo/đối chiếu tracker; không duy trì trạng thái công việc thứ hai tại đây.
- `docs/kaneo-map.json`: ánh xạ mã local → task ID/URL thực tế và trạng thái xuất bản. Không được ghi task đã tạo nếu chưa kiểm chứng.
- `tasks/plan.md`: thứ tự thực hiện, dependencies, checkpoints và cách chạy công việc.

## Yêu cầu bất biến của MVP

**Flutter + SQLite/Drift trên thiết bị; Spring Boot + PostgreSQL phía server. Học offline là bắt buộc.** SQLite là kho dữ liệu vận hành cho buổi học, không chỉ là cache màn hình. Không yêu cầu đăng nhập hoặc AI để hoàn thành bài học cốt lõi. Có gói bài/audio mẫu đi kèm app để lần mở đầu tiên không có mạng vẫn học được.

Không bắt đầu triển khai toàn bộ backlog chỉ vì tài liệu tồn tại. Yêu cầu hiện tại là lập tài liệu và tạo task; lấy từng task được chọn cho lần triển khai tiếp theo.

## Backend scaffold

Ngày 2026-10-04: chủ dự án duyệt scaffold theo layout/stack Vey. Xem [cách chạy ở root README](../README.md), [API README](../api/README.md) và [bằng chứng kiểm chứng](backend-scaffold.md). Mobile và domain APIs chưa triển khai; mô tả MVP phía trên vẫn là yêu cầu, không phải toàn bộ tính năng đã có.
