# Kaneo / Bloom

## Project đích

- Sản phẩm: **Nở**.
- Workspace: `namdang-fdp`, ID `L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN`.
- Project: **Bloom**, ID `i11re6ts0794c06k7o1wbd10`, prefix `BLO`.
- [Board](https://kaneo.dorriss.com/dashboard/workspace/L2xwoDH5loB5xcW8pEwbZ3zmA3uZALpN/project/i11re6ts0794c06k7o1wbd10/board).
- Columns đã đọc từ instance: `to-do`, `in-progress`, `in-review`, `done`.

## Kết nối đã xác minh

Ngày 2026-10-04: phiên agent không expose tool Kaneo. Cấu hình có endpoint `https://kaneo.dorriss.com/api/mcp`, nhưng gửi API key dạng Bearer tới endpoint này nhận 401. Cùng credential trong cấu hình sử dụng header `x-api-key` với REST API của **chính instance Kaneo này** đã đọc được Bloom và tạo task thành công. Không sửa cấu hình MCP toàn cục.

Ưu tiên MCP nếu phiên sau đã có tool và xác thực đúng. Nếu cần REST fallback, đọc credential từ biến môi trường được cấu hình, chỉ gửi tới host Kaneo đích, không in/lưu vào repo. Không yêu cầu người dùng paste key vào chat. Credential có thể được rotate; không giả định key của phiên lập kế hoạch còn dùng được.

## Quy tắc tránh trùng

1. Đọc project và toàn bộ trang task trước khi tạo/sửa; xác nhận ID và tên Bloom.
2. Tra `docs/kaneo-map.json` và mã `[NO-xxx]` đầu title. Không tạo lại khi đã có task cùng mã.
3. Task có title `[NO-xxx] [Pn] ...`, body acceptance/verification/dependencies và tham chiếu docs.
4. Dependency native có `relationType=blocks`, source là prerequisite, target là task bị chặn. Không đảo chiều.
5. Khi thay dependency, cập nhật spec và graph thật có chủ đích; không xóa task/quan hệ của công việc khác.
6. Nếu POST mất response, đọc lại trước retry; server tạo task không nhất thiết có idempotency key riêng.
7. Đọc lại task body và relation sau export; mapping chỉ đánh dấu `verified` khi counts và nội dung khớp.

`backlog.json` là snapshot yêu cầu để khởi tạo/đối chiếu; Kaneo giữ trạng thái thực thi. Khi scope thay đổi, cập nhật snapshot có version/history phù hợp nhưng không tự ghi đè status/assignee người dùng đã đổi.

## API đã dùng

- `GET /api/project/{projectId}`: xác minh đích.
- `GET /api/task/tasks/{projectId}?page=...&limit=...`: phân trang task theo columns.
- `POST /api/task/{projectId}`: title, description, priority, status.
- `GET /api/task/{taskId}`: kiểm chứng body.
- `POST /api/task-relation`: sourceTaskId, targetTaskId, relationType.
- `GET /api/task-relation/{taskId}`: kiểm chứng native dependencies.

Không gán người thực hiện hoặc deadline khi chưa có quyết định. Việc tạo backlog không có nghĩa đã bắt đầu triển khai. Chỉ mục đầy đủ ở [backlog.md](backlog.md).
