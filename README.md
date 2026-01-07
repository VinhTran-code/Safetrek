<div align="center">

# 🛡️ SafeTrek - Ứng Dụng Giám Sát An Toàn Cá Nhân

### *"An toàn của bạn là ưu tiên hàng đầu của chúng tôi"*

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Google Maps](https://img.shields.io/badge/Google_Maps-4285F4?style=for-the-badge&logo=google-maps&logoColor=white)
</div>

---

## 👥 Tác Giả

 **Đỗ Thanh Tùng**  
 **Trần Ngọc Vinh**
 **Nguyễn Ngọc Quỳnh** 

---

## 📱 Giới Thiệu Dự Án

**SafeTrek** không chỉ là một ứng dụng di động thông thường - đây là **"vệ sĩ ảo"** của bạn, một người bạn đồng hành thông minh luôn sẵn sàng bảo vệ bạn trong mọi chuyến đi. 

Trong thế giới hiện đại đầy rẫy những rủi ro tiềm ẩn, SafeTrek ra đời như một giải pháp công nghệ tiên tiến, kết hợp giữa **AI**, **GPS tracking**, và **hệ thống cảnh báo tự động** để mang đến sự an tâm tuyệt đối cho người dùng.

### 🎯 Điểm Khác Biệt

Khác với các ứng dụng chia sẻ vị trí thông thường (như Find My, Zalo Location), SafeTrek hoạt động theo cơ chế **"Dead Man's Switch"** (Công tắc Người chết) - một hệ thống giám sát chủ động:

- ⏱️ **Giám sát chủ động**: Tự động theo dõi hành trình của bạn
- 🚨 **Cảnh báo tự động**: Gửi cảnh báo khẩn cấp khi phát hiện bất thường
- 🔐 **Bảo mật cao**: Hệ thống mã PIN kép với tính năng ẩn danh
- 🌍 **Theo dõi GPS**: Cập nhật vị trí liên tục với độ chính xác cao

---

## 🌟 Câu Chuyện Đằng Sau Dự Án

### 💔 Vấn Đề Thực Tế

Mỗi ngày, hàng triệu người - đặc biệt là **phụ nữ** và **sinh viên** - phải đối mặt với nỗi lo lắng khi di chuyển một mình:

- 🌙 **Sinh viên nữ** đi bộ từ trạm xe buýt về phòng trọ lúc 10h đêm
- 🚖 **Người đi làm** bắt taxi về nhà sau ca tăng ca khuya
- 🏃 **Người tập thể dục** chạy bộ ở công viên vắng vào sáng sớm
- 👤 **Người dùng dịch vụ**: Sử dụng xe ôm, taxi từ người lạ

### ❌ Giải Pháp Hiện Tại Chưa Đủ

**1. Gọi điện thoại liên tục**
- ❌ Bất tiện cho cả hai bên
- ❌ Tốn pin và dung lượng mạng
- ❌ Không phải lúc nào người nghe cũng rảnh

**2. Phản ứng chậm trong khẩn cấp**
- ❌ Mở điện thoại, tìm danh bạ mất thời gian
- ❌ Có thể gây thêm nguy hiểm

**3. Ứng dụng chia sẻ vị trí bị động**
- ❌ Chỉ hiển thị vị trí, không cảnh báo
- ❌ Không biết người dùng có an toàn hay không
- ❌ Yêu cầu người khác phải liên tục kiểm tra

### ✅ Giải Pháp Của SafeTrek

SafeTrek ra đời để giải quyết triệt để những vấn đề trên bằng cách:

1. ✨ **Tự động giám sát** không cần can thiệp liên tục
2. ⚡ **Phản ứng nhanh** trong tình huống khẩn cấp (chỉ 1 chạm)
3. 🔔 **Cảnh báo chủ động** thay vì bị động chờ đợi
4. 🤝 **Kết nối với người thân** một cách thông minh và hiệu quả

---

## 🎨 Tính Năng Nổi Bật

### 1. ⏱️ Giám Sát Chuyến Đi Thông Minh (Trip Monitoring)

```
Bắt đầu chuyến đi → Nhập điểm đến & thời gian → Hẹn giờ kích hoạt
→ GPS theo dõi nền → Xác nhận an toàn bằng PIN
```

**Chi tiết:**
- 📍 Nhập điểm đến (tùy chọn) và thời gian dự kiến (VD: 15 phút)
- ⏰ Hệ thống đếm ngược và theo dõi GPS trong nền
- 🔐 Xác nhận an toàn bằng mã PIN hoặc sinh trắc học
- 📊 Theo dõi lịch sử các chuyến đi

### 2. 🚨 Cảnh Báo Khẩn Cấp Tự Động (Auto Alert)

**Kịch bản hoạt động:**
- ⏱️ Hẹn giờ về 0 mà không có xác nhận → Kích hoạt cảnh báo
- 📤 Tự động gửi tin nhắn khẩn cấp đến danh sách người bảo vệ
- 📦 Thông tin gửi đi bao gồm:
  - 👤 Tên và thông tin người dùng
  - ⏰ Thời gian bắt đầu chuyến đi
  - 📍 Vị trí GPS cuối cùng
  - 🗺️ Link Google Maps dẫn đường
  - 🔋 Mức pin còn lại của thiết bị
  - 📞 Thông tin liên lạc khẩn cấp

### 3. 🆘 Nút Hoảng Loạn (Panic Button)

**Tình huống sử dụng:**
- 😰 Cảm thấy bị theo dõi
- 🚨 Gặp tình huống nguy hiểm đột xuất
- 🏃 Cần cứu hộ khẩn cấp

**Cơ chế:**
- 🔴 **1 chạm** gửi cảnh báo ngay lập tức
- 🤫 **Cử chỉ ẩn**: Bấm nút nguồn 5 lần liên tiếp
- 🔓 Hoạt động ngay cả khi màn hình khóa

### 4. 🔐 Mã PIN Bị Ép Buộc (Duress PIN)

**Tính năng độc đáo - Bảo vệ kép:**

```
PIN An toàn: 1234  →  Kết thúc chuyến đi bình thường
PIN Ép buộc: 4321  →  Gửi cảnh báo ngầm + Giả vờ tắt
```

**Kịch bản thực tế:**
- 😱 Bị kẻ xấu uy hiếp buộc tắt ứng dụng
- 🎭 Nhập PIN ép buộc → Giao diện giả vờ tắt cảnh báo
- 🤐 Âm thầm gửi tín hiệu SOS đến người bảo vệ
- 🛡️ Kẻ xấu không hề hay biết

### 5. 👥 Quản Lý Người Bảo Vệ (Guardian Management)

**Tính năng:**
- 📝 Thêm 3-5 người thân/bạn bè làm người bảo vệ
- ✉️ Gửi lời mời tham gia hệ thống
- ✅ Xác nhận và quản lý danh sách
- 🔄 Cập nhật, chỉnh sửa linh hoạt

### 6. 📊 Tính Năng Bổ Sung

- 🗺️ **Bản đồ thời gian thực**: Hiển thị vị trí trên Google Maps
- 📍 **Gợi ý địa điểm**: Tự động hoàn thành địa chỉ
- 🔋 **Tối ưu pin**: GPS thông minh tiết kiệm pin
- 📱 **Chạy nền**: Hoạt động ngầm không ảnh hưởng sử dụng
- 🎨 **Giao diện thân thiện**: Dễ sử dụng, trực quan

---

## 🏗️ Kiến Trúc Công Nghệ

### 💻 Technology Stack

| Component | Technology                     |
|-----------|--------------------------------|
| **Frontend** | Flutter (Dart)                 |
| **Backend** | Laravel                        |
| **Database** | MySQL                          |
| **Maps & Location** | Google Maps API, Geocoding API |
| **Authentication** | Stancum Token                  |
| **Build Tool** | Gradle                         |

### 📦 Core Dependencies

```yaml
dependencies:
  flutter: sdk
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  permission_handler: ^11.0.0
  http: ^1.1.0
  shared_preferences: ^2.2.0
```

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Dự Án

### 📋 Yêu Cầu Hệ Thống

- **Flutter SDK**: 3.0.0 trở lên
- **Dart**: 3.0.0 trở lên
- **Android Studio** hoặc **VS Code**
- **Android**: API level 23+ (Android 6.0+)
- **iOS**: iOS 12.0+ (tùy chọn)

### 🔧 Các Bước Cài Đặt

**1. Clone repository:**
```bash
git clone https://github.com/VinhTran-code/Safetrek.git
cd Safetrek
```

**2. Cài đặt dependencies:**
```bash
flutter pub get
```

**3. Cấu hình Google Maps API:**
- Tạo project tại [Google Cloud Console](https://console.cloud.google.com)
- Bật các API: Maps SDK for Android, Places API, Geocoding API
- Lấy API Key và thêm vào file cấu hình

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**4. Chạy ứng dụng:**
```bash
# Chạy trên Android
flutter run

# Chạy trên Web
flutter run -d chrome

# Build APK
flutter build apk --release
```

---

## 📱 Luồng Sử Dụng Ứng Dụng

### 🎬 Kịch Bản Chuẩn

```
1. Đăng ký/Đăng nhập
   ↓
2. Thiết lập ban đầu
   → Tạo PIN an toàn (4 số)
   → Tạo PIN ép buộc (4 số khác)
   → Cấp quyền GPS & chạy nền
   ↓
3. Thêm người bảo vệ (3-5 người)
   ↓
4. Sử dụng chức năng chính:
   
   📍 CHUYẾN ĐI BÌNH THƯỜNG:
   Trang chủ → Bắt đầu chuyến đi → Nhập điểm đến & thời gian
   → Giám sát GPS → Đến nơi an toàn → Nhập PIN → Kết thúc
   
   🚨 TÌNH HUỐNG KHẨN CẤP:
   Nút Panic → Gửi cảnh báo ngay lập tức → Người bảo vệ nhận thông báo
   
   ⏱️ QUÊN XÁC NHẬN:
   Hết giờ → Màn hình nhập PIN (60s) → Không nhập → Tự động cảnh báo
   
   🔐 BỊ ÉP BUỘC:
   Nhập PIN ép buộc → Giao diện tắt → Ngầm gửi SOS
```

---

## 🎯 Đối Tượng Người Dùng

SafeTrek được thiết kế dành cho:

| Đối tượng | Tình huống sử dụng |
|-----------|-------------------|
| 👩‍🎓 **Sinh viên** | Đi học về khuya, di chuyển từ ký túc xá |
| 💼 **Người đi làm** | Tăng ca muộn, về nhà nửa đêm |
| 🏃 **Người tập thể dục** | Chạy bộ sáng sớm, tập nơi vắng |
| 🚖 **Người dùng dịch vụ** | Đi taxi, xe ôm công nghệ |
| 👨‍👩‍👧 **Phụ huynh** | Theo dõi con em khi đi xa |
| 🧳 **Du khách** | Đi du lịch một mình ở nơi xa lạ |

---

## 🔒 Bảo Mật & Quyền Riêng Tư

SafeTrek cam kết bảo vệ quyền riêng tư người dùng:

- 🔐 **Mã hóa dữ liệu**: Tất cả thông tin được mã hóa end-to-end
- 🎯 **Thu thập tối thiểu**: Chỉ lấy dữ liệu cần thiết
- 🗺️ **GPS theo yêu cầu**: Chỉ theo dõi khi người dùng kích hoạt chuyến đi
- 🔑 **Xác thực 2 lớp**: PIN + Sinh trắc học
- 🚫 **Không chia sẻ**: Không bán dữ liệu cho bên thứ ba
- 🗑️ **Xóa dữ liệu**: Người dùng có quyền xóa mọi thông tin

### 📜 Quyền Ứng Dụng Yêu Cầu

```
✅ Vị trí (GPS) - Để theo dõi chuyến đi
✅ Chạy nền - Giám sát liên tục
✅ Thông báo - Cảnh báo khẩn cấp
✅ Internet - Gửi dữ liệu đến server
✅ Liên hệ - Quản lý người bảo vệ (tùy chọn)
```

---

## 📊 Yêu Cầu Kỹ Thuật

### ✅ Yêu Cầu Chức Năng (Functional Requirements)

| ID | Chức năng | Mô tả |
|----|-----------|-------|
| **FR1** | Giám sát chuyến đi | Đếm ngược, tracking GPS, xác nhận PIN |
| **FR2** | Cảnh báo tự động | Gửi alert khi timeout không check-in |
| **FR3** | Nút Panic | Gửi SOS tức thì với 1 chạm |
| **FR4** | Duress PIN | Mã PIN kép: an toàn & ép buộc |
| **FR5** | Quản lý Guardian | Thêm, xóa, mời người bảo vệ |

### ⚡ Yêu Cầu Phi Chức Năng (Non-Functional Requirements)

| ID | Tiêu chí | Yêu cầu |
|----|----------|---------|
| **NFR1** | Độ tin cậy | Hoạt động 24/7, gửi alert kể cả khi mạng yếu |
| **NFR2** | Hiệu năng | GPS nền không được hao pin >5%/giờ |
| **NFR3** | Khả dụng | Giao diện đơn giản, thao tác <3 chạm |
| **NFR4** | Độ chính xác | GPS sai số <10m trong điều kiện tốt |
| **NFR5** | Bảo mật | Mã hóa AES-256, JWT authentication |

---

## 🗺️ Lộ Trình Phát Triển

### ✅ Giai Đoạn 1: MVP (Hoàn thành)
- [x] Đăng ký/Đăng nhập
- [x] Thiết lập PIN kép
- [x] Giám sát chuyến đi cơ bản
- [x] Nút Panic
- [x] Quản lý người bảo vệ
- [x] Cảnh báo tự động

### 🚧 Giai Đoạn 2: Nâng Cao (Đang phát triển)
- [ ] Tích hợp gọi 113 trực tiếp
- [ ] AI phát hiện bất thường (tốc độ, vị trí)
- [ ] Bản đồ nhiệt độ an toàn khu vực
- [ ] Ghi âm cuộc gọi khẩn cấp
- [ ] Hỗ trợ smartwatch

### 🔮 Giai Đoạn 3: Tương Lai
- [ ] Tính năng nhóm (Group Trip)
- [ ] Live streaming vị trí
- [ ] Chatbot tư vấn an toàn
- [ ] Tích hợp với cơ quan chức năng
- [ ] Phát triển phiên bản iOS

---

## 📈 Thống Kê & Thành Tựu

<div align="center">

| Metric | Value |
|--------|-------|
| ⭐ **Lines of Code** | 15,000+ |
| 📁 **Files** | 150+ |
| 🎨 **Screens** | 20+ |
| 🔧 **Features** | 15+ |
| 🌍 **Languages** | 2 (Tiếng Việt, English) |

</div>

---

## 🤝 Đóng Góp & Phát Triển

Chúng tôi hoan nghênh mọi đóng góp từ cộng đồng!



### 🐛 Báo Lỗi

Gặp lỗi? Hãy tạo issue tại: [GitHub Issues](https://github.com/VinhTran-code/Safetrek/issues)

---

## 📞 Liên Hệ & Hỗ Trợ

<div align="center">

### 📧 Email
**support@safetrek.com**

</div>

---

## 📄 Giấy Phép (License)

Dự án này được phát triển cho mục đích **học tập và nghiên cứu**.

```
Copyright © 2026 SafeTrek Team
Đỗ Thanh Tùng | Trần Ngọc Vinh | Nguyễn Ngọc Quỳnh
```

---

## 🙏 Lời Cảm Ơn

Xin gửi lời cảm ơn chân thành đến:

- 👨‍🏫 **Giảng viên hướng dẫn** - Đã định hướng và hỗ trợ nhiệt tình
- 👥 **Người thử nghiệm** - Đã dành thời gian test và góp ý
- 💻 **Cộng đồng Flutter** - Tài liệu và thư viện hữu ích
- 🌍 **Open Source Community** - Những công cụ tuyệt vời

---

## 💭 Triết Lý Dự Án

> *"Công nghệ không chỉ để kết nối con người, mà còn để bảo vệ họ. SafeTrek được sinh ra từ mong muốn đơn giản: Không ai phải cảm thấy bất an khi đi một mình. Chúng tôi tin rằng, mỗi người đều xứng đáng có một 'vệ sĩ' bên cạnh, dù chỉ là một ứng dụng trên điện thoại."*

---

## 🌟 Tầm Nhìn

SafeTrek không chỉ là một ứng dụng - đây là **phong trào an toàn cộng đồng**. Chúng tôi hướng đến tương lai nơi:

- 🌍 Mọi người đều cảm thấy an toàn khi di chuyển
- 🤝 Cộng đồng hỗ trợ lẫn nhau qua công nghệ
- 🚨 Ứng phó khẩn cấp nhanh chóng và hiệu quả
- 🛡️ An toàn cá nhân trở thành ưu tiên hàng đầu

---

<div align="center">

## 🛡️ SafeTrek - Your Virtual Guardian

**Bảo vệ bạn mọi lúc, mọi nơi**

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Status](https://img.shields.io/badge/status-active-success)
![License](https://img.shields.io/badge/license-Educational-orange)

### ⭐ Nếu bạn thấy dự án hữu ích, hãy cho chúng tôi một ngôi sao!

[⬆ Về đầu trang](#️-safetrek---ứng-dụng-giám-sát-an-toàn-cá-nhân)

---

*Made with ❤️ by SafeTrek Team*

</div>

