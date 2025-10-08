
    HƯỚNG DẪN LIVE STREAMING NGINX-RTMP #2
   OBS → nginx-rtmp → Cloudflare Tunnel → Internet

--------------------
OBS Studio → rtmp://localhost:1936/live2 → nginx-rtmp → http://localhost:8081 → Cloudflare Tunnel → https://xxxxx.trycloudflare.com


BƯỚC 1: KHỞI ĐỘNG SERVER STREAMING #2
- Chuột phải -> chạy với quyền admin file: start-stream.bat
- Chờ 1 lút kết quả thu được dạng: 
Your quick Tunnel has been created! Visit it at:
https://jade-theft-swing-relate.trycloudflare.com
-> đây chính là link để mọi người xem được video stream #2.

BƯỚC 2: CHẠY OBS STUDIO #2
Lần đầu cần cài đặt server stream:
1. Mở OBS Studio (instance thứ 2)
2. Settings → Stream
3. Service: Custom
4. Server: rtmp://localhost:1936/live2
5. Stream Key: live2

Từ lần sau chỉ cần mở chọn video/cửa sổ chrome... bạn cần stream
Xong -> Click "Start Streaming"

-> Bây giờ mọi người có thể xem bạn stream qua link: https://xxxxx.trycloudflare.com (từ Bước 1)

DỪNG STREAMING
=================
- để dừng hết -> Chuột phải -> chạy với quyền admin file: stop.bat
- hoặc dùng stop-all.bat ở thư mục cha để tắt cả 2 streams


* CHÚ Ý: 
- Mỗi lần chạy mới sẽ tạo 1 link web khác nhau.
- ĐÂY LÀ STREAM #2 với cổng 1936 (RTMP) và 8081 (HTTP)
- Stream #1 chạy ở thư mục nginx-rtmp với cổng 1935 và 8080

Nếu có lỗi
==================
"nginx.exe not found"
- hãy kiểm tra lại và đảm bảo bạn đang chạy từ thư mục nginx-rtmp-2, và thư mục này đã có nginx.exe
- nếu bị mất hãy lên mạng tải lại và lưu file nginx.exe vào thư mục nginx-rtmp-2

"cloudflared.exe not found"
- hãy kiểm tra lại và đảm bảo bạn đang chạy từ thư mục nginx-rtmp-2, và thư mục này đã có cloudflared.exe 
- nếu k hãy tải về từ: https://github.com/cloudflare/cloudflared/releases/latest
- Lưu cloudflared.exe vào thư mục nginx-rtmp-2

OBS không thể kết nối
- Kiểm tra cài đặt stream ở OBS đã để server là máy localhost chưa: rtmp://localhost:1936/live2
- Đảm bảo nginx đang chạy (phải chạy start-stream.bat (bước 1) trước)
- ĐẢM BẢO stream key là "live2" không phải "live"

link web k xem dc, hiển thị màn hình trắng
- Đợi 10-15 giây sau khi bắt đầu stream OBS xem sao. có thể bị lag.

Port đã được sử dụng
- Nếu báo port 1936 hoặc 8081 đã được dùng, kiểm tra xem có nginx khác đang chạy không
- Dùng: netstat -an | findstr ":1936" hoặc netstat -an | findstr ":8081"
- Tắt process đang dùng port hoặc đổi sang port khác

==========================================================================================
HƯỚNG DẪN DUAL STREAM
- Để chạy cả 2 streams đồng thời, xem file README-DUAL-STREAM.md ở thư mục cha
- Hoặc dùng start-stream-both.bat để tự động khởi động cả 2

==========================================================================================
