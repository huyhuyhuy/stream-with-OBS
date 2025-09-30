
    HƯỚNG DẪN LIVE STREAMING NGINX-RTMP
   OBS → nginx-rtmp → Cloudflare Tunnel → Internet

--------------------
OBS Studio → rtmp://localhost:1935/live → nginx-rtmp → http://localhost:8080 → Cloudflare Tunnel → https://xxxxx.trycloudflare.com


BƯỚC 1: KHỞI ĐỘNG SERVER STREAMING
- Chuột phải -> chạy với quyền admin file: start-stream.bat
- Chờ 1 lúc kết quả thu được dạng: 
Your quick Tunnel has been created! Visit it at:
https://jade-theft-swing-relate.trycloudflare.com
-> đây chính là link để mọi người xem được video stream.

BƯỚC 2: CHẠY OBS STUDIO
Lần đầu cần cài đặt server stream:
1. Mở OBS Studio
2. Settings → Stream
3. Service: Custom
4. Server: rtmp://localhost:1935/live
5. Stream Key: live

Từ lần sau chỉ cần mở chọn video/cửa sổ chrome... bạn cần stream
XXong -> Click "Start Streaming"

-> Bây giờ moij người có thể xem bạn stream qua link: https://xxxxx.trycloudflare.com (từ Bước 1)

DỪNG STREAMING
=================
- để dừng hết -> Chuột phải -> chạy với quyền admin file: stop.bat


* CHÚ Ý: mỗi lần chạy mới sẽ tạo 1 link web khác nhau.

Nếu có lỗi
==================
"nginx.exe not found"
- hãy kiểm tra lại và đảm bảo bạn đang chạy từ thư mục nginx-rtmp, và thư mục này đã có nginx.exe
- nếu bị mất hẫy lên mạng tải lại và lưu file nginx.exe vào thư mục nginx-rtmp

"cloudflared.exe not found"
- hãy kiểm tra lại và đảm bảo bạn đang chạy từ thư mục nginx-rtmp, và thư mục này đã có cloudflared.exe 
- nếu k hãy tải về từ: https://github.com/cloudflare/cloudflared/releases/latest
- Lưu cloudflared.exe vào thư mục nginx-rtmp

OBS không thể kết nối
- Kiểm tra cài đặt stream ở OBS đã để server là máy localhost chưa: rtmp://localhost:1935/live
- Đảm bảo nginx đang chạy (phải chạy start-stream.bat (bước 1) trước)

link web k xem dc, hiển thị màn hình trắng
- Đợi 10-15 giây sau khi bắt đầu stream OBS xem sao. có thể bị lag.



==========================================================================================
- HƯỚNG DẪN KHI MUỐN ĐỔI CỔNG STREAM -
- hiện tại chúng ta có 2 cổng là RTMP (1935) và cổng HTTP (8080)
- chúng ta có thể thay thể nó bằng các cổng khác như:

Cổng RTMP (thay thế cho 1935): 1936, 1937
Cổng HTTP (thay thế cho 8080): 8081, 8082

Các file cần sửa khi thay đổi cổng:
* mở file bằng notepade++ sửa và lưu lại theo hướng dẫn sau:

1. nginx-rtmp/conf/nginx.conf (File cấu hình chính)
    Dòng 12: listen 1935; → đổi thành cổng RTMP mới
    Dòng 63: listen 8080; → đổi thành cổng HTTP mới

2. nginx-rtmp/start-stream.bat (Script khởi động)
    Dòng 23: localport=8080 → đổi trong firewall rule
    Dòng 29: localport=1935 → đổi trong firewall rule
    
    Dòng 72: rtmp://localhost:1935/live → đổi trong thông báo
    Dòng 73: http://localhost:8080 → đổi trong thông báo
    Dòng 74: http://localhost:8080/hls/live.m3u8 → đổi trong thông báo
    Dòng 75: http://localhost:8080/stat → đổi trong thông báo
    
    Dòng 95: http://localhost:8080/health → đổi trong health check
    Dòng 107: localhost:8080 → đổi trong cloudflared tunnel

==========================================================================================