// lib/screens/pin_setup_mode.dart

enum PinSetupMode {
  /// Dùng cho luồng thiết lập lần đầu, yêu cầu cả 2 PIN.
  initialSetup,

  /// Dùng để cập nhật một PIN duy nhất từ màn hình Cài đặt.
  update,
}