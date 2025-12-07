# SafeTrek - Trợ lý Giám sát An toàn Cá nhân

## 1. Tổng quan Dự án
[cite_start]"SafeTrek" là một ứng dụng di động được thiết kế như một "người bạn đồng hành ảo" để bảo vệ người dùng khi họ di chuyển một mình trong các tình huống tiềm ẩn rủi ro (ví dụ: đi bộ về nhà ban đêm, sử dụng dịch vụ gọi xe lạ, chạy bộ ở nơi vắng vẻ)[cite: 1].

[cite_start]Ứng dụng hoạt động như một hệ thống giám sát chủ động, không chỉ đơn thuần là chia sẻ vị trí[cite: 2, 3]. [cite_start]Người dùng thiết lập một "hẹn giờ an toàn" cho chuyến đi của mình[cite: 3]. [cite_start]Nếu họ không xác nhận an toàn trước khi hết giờ, ứng dụng sẽ tự động gửi cảnh báo khẩn cấp (bao gồm vị trí cuối cùng và mức pin) đến danh sách liên lạc đã chọn[cite: 4].

## 2. Bối cảnh & Vấn đề

### Hiện trạng
[cite_start]Nỗi sợ hãi khi di chuyển một mình ở những nơi vắng vẻ hoặc vào ban đêm là một vấn đề thực tế, đặc biệt đối với phụ nữ và sinh viên[cite: 5]. Các giải pháp hiện tại có những hạn chế:
* [cite_start]**Gọi điện thoại:** Gây bất tiện, tốn pin và không phải lúc nào người nghe cũng sẵn sàng[cite: 6, 7].
* [cite_start]**Phản ứng trong tình huống khẩn cấp:** Việc thao tác trên điện thoại để gọi hoặc nhắn tin khi gặp nguy hiểm là quá chậm và có thể gây nguy hiểm thêm[cite: 8].
* [cite_start]**Các ứng dụng chia sẻ vị trí:** Các ứng dụng như "Find My" thường bị động, chỉ cho biết vị trí mà không biết tình trạng an toàn của người dùng và không tự động cảnh báo khi có sự cố[cite: 9, 10, 11].

### Cơ hội
[cite_start]Xây dựng một hệ thống "Công tắc Người chết" (Dead Man's Switch) cho an toàn cá nhân[cite: 12]. [cite_start]Một ứng dụng tin cậy sẽ tự động gọi cứu hộ thay cho người dùng khi họ không thể tự làm điều đó[cite: 13].

## 3. Đối tượng Người dùng

* [cite_start]**Chân dung:** Những người thường xuyên di chuyển một mình trong các tình huống tiềm ẩn rủi ro, ví dụ: sinh viên đi học về khuya, người đi làm về muộn, người tập thể dục ở nơi vắng vẻ[cite: 15, 16].
* [cite_start]**Nhu cầu:** Cần một lớp bảo vệ tự động, giảm bớt sự lo lắng và muốn có người biết hành trình của mình để hành động khi cần thiết[cite: 17, 18].

## 4. Yêu cầu Chức năng Chính

[cite_start]Hệ thống cần đảm bảo các chức năng sau[cite: 19]:

### Module "Giám sát Chuyến đi" (Trip Monitoring)
* [cite_start]**Bắt đầu Chuyến đi:** Người dùng nhập điểm đến (tùy chọn) và thời gian dự kiến cho chuyến đi (ví dụ: 15 phút)[cite: 20, 21].
* [cite_start]**Kích hoạt Hẹn giờ & Theo dõi:** Ứng dụng bắt đầu đếm ngược và âm thầm theo dõi vị trí GPS của người dùng[cite: 22].
* [cite_start]**Xác nhận An toàn:** Người dùng xác nhận an toàn bằng mã PIN hoặc sinh trắc học trước khi hết giờ để kết thúc chuyến đi[cite: 23, 24].

# Dự án: "Vệ Sĩ Ảo" (SafeTrek) – Trợ lý Giám sát An toàn Cá nhân

## 1. Tổng quan Dự án (Project Overview)

"SafeTrek" là một ứng dụng di động hoạt động như một "người bạn đồng hành ảo" hay "vệ sĩ", được thiết kế để bảo vệ người dùng khi họ đang di chuyển một mình (ví dụ: đi bộ về nhà lúc trời tối, đi xe ôm/taxi lạ, chạy bộ ở nơi vắng vẻ).

Ứng dụng này không chỉ đơn thuần là chia sẻ vị trí (như "Find My"). Nó là một hệ thống giám sát chủ động. Người dùng đặt một "hẹn giờ an toàn" cho chuyến đi của mình. Nếu họ không xác nhận "Tôi đã đến nơi an toàn" trước khi hết giờ, ứng dụng sẽ tự động gửi cảnh báo khẩn cấp (vị trí cuối cùng, mức pin) đến danh sách liên lạc khẩn cấp đã được cài đặt sẵn.

## 2. Bối cảnh & Vấn đề (Business Problem & Context)

**Hiện trạng (Current State):**  
Nỗi sợ hãi khi phải đi một mình ở nơi vắng vẻ hoặc vào ban đêm là có thật, đặc biệt là với phụ nữ và sinh viên.

1. **Sự bất tiện của việc "gọi điện thoại":**  
   Nhiều người (đặc biệt là sinh viên nữ) có thói quen gọi điện thoại cho bạn bè/người thân và giữ máy suốt quãng đường đi bộ về nhà.  
   **Vấn đề:** Việc này bất tiện cho cả hai bên, tốn pin, và không phải lúc nào người nghe cũng rảnh.

2. **Phản ứng chậm trễ khi gặp nguy hiểm:**  
   Trong tình huống khẩn cấp (bị theo dõi, tấn công), việc mở điện thoại, tìm danh bạ, gõ tin nhắn hoặc gọi điện là quá chậm và có thể gây nguy hiểm thêm.

3. **Các ứng dụng "Find My" quá bị động:**  
   Các ứng dụng như Zalo, Find My (Apple) chỉ cho phép người khác xem bạn ở đâu.  
   Chúng không thể biết bạn có an toàn hay không, và cũng không tự động cảnh báo khi có vấn đề.

**Cơ hội (Opportunity):**  
Xây dựng một hệ thống "Công tắc Người chết" (Dead Man's Switch) cho sự an toàn cá nhân.  
Một ứng dụng tin cậy sẽ tự động gọi cứu hộ thay cho bạn nếu bạn không thể.

## 3. Đối tượng Người dùng (Target Audience)

**Persona: "Người di chuyển Một mình"**

- Sinh viên nữ đi bộ từ trạm xe buýt về phòng trọ lúc 10h tối.
- Người đi làm tăng ca bắt taxi về nhà lúc nửa đêm.
- Người chạy bộ buổi sáng sớm ở công viên vắng.

**Nhu cầu:** Một lớp bảo vệ tự động.  
**Tâm lý:** Muốn có ai đó biết hành trình của mình và sẽ hành động nếu có chuyện.

## 4. Yêu cầu Chức năng (Functional Requirements - FRs)

### FR1: Giám sát Chuyến đi (Trip Monitoring)

- **FR1.1: Bắt đầu Chuyến đi:**
    - Đích đến (tùy chọn).
    - Thời gian dự kiến (ví dụ: 15 phút).

- **FR1.2: Kích hoạt Hẹn giờ:**  
  Ứng dụng đếm ngược thời gian và theo dõi vị trí GPS nền.

- **FR1.3: Xác nhận An toàn (Check-in):**  
  Người dùng nhập PIN hoặc dùng sinh trắc học để xác nhận đã đến nơi.

### FR2: Cảnh báo Khẩn cấp Tự động (Auto Alert)

- **FR2.1:** Nếu hẹn giờ về 0 mà không có Check-in, báo động kích hoạt.
- **FR2.2:** Gửi cảnh báo đến danh bạ khẩn cấp.
- **FR2.3:** Nội dung cảnh báo gồm:
    - Tên người dùng
    - Thời gian bắt đầu chuyến đi
    - Vị trí cuối
    - Link Google Maps
    - Mức pin còn lại

### FR3: Nút Hoảng loạn (Panic Button)

- **FR3.1:** Một nút bấm gửi cảnh báo ngay lập tức.
- **FR3.2:** Có thể kích hoạt bằng cử chỉ ẩn, như bấm nút nguồn 5 lần.

### FR4: Mã PIN Bị ép buộc (Duress PIN)

- **FR4.1:** Có 2 mã PIN
    - PIN an toàn
    - PIN bị ép buộc

- **FR4.2:** Khi nhập PIN bị ép buộc:
    - Giao diện giả vờ tắt cảnh báo
    - Ngầm gửi cảnh báo khẩn

### FR5: Quản lý Liên lạc Khẩn cấp (Guardian List)

- **FR5.1:** Chọn 3–5 người làm người bảo vệ.
- **FR5.2:** Các liên lạc này phải chấp nhận lời mời.

## 5. Yêu cầu Phi chức năng (Non-Functional Requirements - NFRs)

- **NFR1: Độ tin cậy:**  
  Ứng dụng phải hoạt động nền, gửi cảnh báo kể cả khi mạng yếu.

- **NFR2: Tối ưu pin:**  
  GPS nền không được gây hao pin mạnh.

- **NFR3: Dễ sử dụng:**  
  Tác vụ như bắt đầu chuyến đi hay bấm panic phải cực nhanh.

- **NFR4: Độ chính xác:**  
  GPS cần đạt độ chính xác cao.

## 6. Ràng buộc & Giả định (Constraints & Assumptions)

- **Ràng buộc 1:** Ứng dụng phụ thuộc quyền OS (GPS, chạy nền, SMS).
- **Ràng buộc 2:** Không thay thế gọi 113.
- **Giả định 1:** Người dùng có smartphone với GPS và internet hoặc SMS.
- **Giả định 2:** Người bảo vệ là người đáng tin và sẽ phản hồi cảnh báo.

