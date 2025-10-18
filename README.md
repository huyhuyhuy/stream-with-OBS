# MULTI RTMP STREAMING SERVER (7 Streams)
* yêu cầu máy tính có cấu hình cao.
* tắt diệt virut
* đảm bảo 14 cổng 1935.. 1941, 8080..8086 đều valid, không bị chiếm dụng...
(Khi chạy mà thấy lỗi có thể chuột phải fix-firewall.bat → "Run as administrator" để tự động tắt tường lửa cho các cổng)

----------------------------------------------------------------------------------
## CẤU HÌNH OBS STUDIO

# Phải sử dụng 7 OBS instances (Portable) chạy riêng nhau.
ví dụ tải và tạo 7 thư mục OBS chạy riêng.
hoặc tìm cách để chạy dc 7 profile OBS riêng nhau.

mỗi cái cấu hình stream như sau:

OBS #1: rtmp://localhost:1935/stream1935 (key: stream1935)
OBS #2: rtmp://localhost:1936/stream1936 (key: stream1936)
OBS #3: rtmp://localhost:1937/stream1937 (key: stream1937)
OBS #4: rtmp://localhost:1938/stream1938 (key: stream1938)
OBS #5: rtmp://localhost:1939/stream1939 (key: stream1939)
OBS #6: rtmp://localhost:1940/stream1940 (key: stream1940)
OBS #7: rtmp://localhost:1941/stream1941 (key: stream1941)


----------------------------------------------------------------------------------
## CHẠY STREAM

# OPTION 1: Chạy TẤT CẢ 7 Streams cùng lúc 
1. Chuột phải start-ALL.bat → "Run as administrator"
2. Đợi 7 cửa sổ mở ra (mỗi stream 1 cửa sổ)
3. Ghi lại 7 Cloudflare URLs từ mỗi cửa sổ
4. Cấu hình 7 OBS instances (hoặc dùng OBS portable)
* Dừng tất cả:
Chuột phải stop-all.bat → "Run as administrator"


# OPTION 2: Chạy từng Stream riêng lẻ

**Khởi động Stream #1:**
1. Vào thư mục: nginx_1935/
2. Chuột phải start_1935.bat → "Run as administrator"
3. Ghi lại Cloudflare URL
4. OBS: rtmp://localhost:1935/stream1935 (key: stream1935)

**Dừng Stream #1:**
Vào nginx_1935/ → Chuột phải stop_1935.bat → "Run as administrator"

**Tương tự cho các streams khác:**
- Stream #2: nginx_1936/start_1936.bat
- Stream #3: nginx_1937/start_1937.bat
- Stream #4: nginx_1938/start_1938.bat
- Stream #5: nginx_1939/start_1939.bat
- Stream #6: nginx_1940/start_1940.bat
- Stream #7: nginx_1941/start_1941.bat

----------------------------------------------------------------------------------

## QUẢN LÝ STREAMS

### Xem thống kê
- Stream #1: http://localhost:8080/stat
- Stream #2: http://localhost:8081/stat
- ... và các streams khác tương tự

### Kiểm tra trạng thái

# Check processes
tasklist | findstr "nginx.exe cloudflared.exe"

# Check ports
netstat -an | findstr ":1935 :1936 :1937 :1938 :1939 :1940 :1941"

----------------------------------------------------------------------------------
