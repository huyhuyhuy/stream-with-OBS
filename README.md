
Phần 1: CẤU HÌNH 2 cái OBS STUDIO (là 2 bản cài hoặc portable chạy riêng nhau)
# Cho Stream #1 (Port 1935)
├── Server: rtmp://localhost:1935/live
└── Stream Key: live


# Cho Stream #2 (Port 1936)
├── Server: rtmp://localhost:1936/live2
└── Stream Key: live2


* CHÚ Ý: máy phải tắt trình diệt virut đi.

Phần 2: Chạy 2 Streams đồng thời (DUAL STREAM)

1. Chuột phải start-stream-both.bat → "Run as administrator"
2, chờ 1 chút sẽ thấy 2 cửa sổ command prompt hiện ra.
3. copy 2 link wweb từ mỗi cửa sổ
4. nhấn nút bắt đầu stream ở 2 cái OBS


**Khi muốn dừng tất cả streams:**
Chuột phải stop-all.bat → "Run as administrator"

