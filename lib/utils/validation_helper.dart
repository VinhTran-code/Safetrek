/// Validation Helper
/// Chứa các hàm validation theo chuẩn backend API
/// Tham khảo: validation_rules.md

class ValidationHelper {
  // ============ Phone Number Validation ============

  /// Kiểm tra format số điện thoại Việt Nam
  /// Format hợp lệ: 0xxxxxxxxx hoặc +84xxxxxxxxx (9-10 chữ số sau mã vùng)
  static bool isValidPhone(String phone) {
    return RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(phone);
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!isValidPhone(phone)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  // ============ Email Validation ============

  /// Kiểm tra format email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String? validateEmail(String? email, {bool required = false}) {
    // Nếu không bắt buộc và rỗng thì OK
    if (!required && (email == null || email.isEmpty)) {
      return null;
    }

    if (required && (email == null || email.isEmpty)) {
      return 'Vui lòng nhập email';
    }

    if (email != null && email.isNotEmpty && !isValidEmail(email)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  // ============ PIN Validation ============

  /// Kiểm tra PIN (phải là 4 chữ số)
  static bool isValidPin(String pin) {
    return RegExp(r'^[0-9]{4}$').hasMatch(pin);
  }

  static String? validatePin(String? pin) {
    if (pin == null || pin.isEmpty) {
      return 'Vui lòng nhập PIN';
    }
    if (pin.length != 4) {
      return 'PIN phải có đúng 4 số';
    }
    if (!isValidPin(pin)) {
      return 'PIN chỉ được chứa số';
    }
    return null;
  }

  // ============ GPS Coordinates Validation ============

  /// Kiểm tra vĩ độ (latitude: -90 đến 90)
  static bool isValidLatitude(double lat) {
    return lat >= -90 && lat <= 90;
  }

  /// Kiểm tra kinh độ (longitude: -180 đến 180)
  static bool isValidLongitude(double lng) {
    return lng >= -180 && lng <= 180;
  }

  static String? validateLatitude(double? lat) {
    if (lat == null) return null; // Optional
    if (!isValidLatitude(lat)) {
      return 'Vĩ độ phải trong khoảng -90 đến 90';
    }
    return null;
  }

  static String? validateLongitude(double? lng) {
    if (lng == null) return null; // Optional
    if (!isValidLongitude(lng)) {
      return 'Kinh độ phải trong khoảng -180 đến 180';
    }
    return null;
  }

  // ============ Battery Level Validation ============

  /// Kiểm tra mức pin (0-100%)
  static bool isValidBattery(int battery) {
    return battery >= 0 && battery <= 100;
  }

  static String? validateBattery(int? battery) {
    if (battery == null) return null; // Optional
    if (!isValidBattery(battery)) {
      return 'Mức pin phải từ 0-100%';
    }
    return null;
  }

  // ============ Authentication Validation ============

  /// Validate đăng ký
  static String? validateRegister({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
  }) {
    // Full name
    if (fullName.isEmpty) return 'Vui lòng nhập họ tên';
    if (fullName.length > 255) return 'Họ tên tối đa 255 ký tự';

    // Phone number
    String? phoneError = validatePhone(phoneNumber);
    if (phoneError != null) return phoneError;

    // Email (optional)
    String? emailError = validateEmail(email, required: false);
    if (emailError != null) return emailError;

    // Password
    if (password.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (password.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    if (password != passwordConfirmation) return 'Mật khẩu xác nhận không khớp';

    return null; // Valid
  }

  /// Validate đăng nhập
  static String? validateLogin({
    required String phoneNumber,
    required String password,
  }) {
    if (phoneNumber.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (password.isEmpty) return 'Vui lòng nhập mật khẩu';
    return null;
  }

  // ============ PIN Setup Validation ============

  /// Validate thiết lập PIN an toàn và PIN nguy hiểm
  static String? validatePinSetup({
    required String safetyPin,
    required String duressPin,
  }) {
    // Safety PIN
    String? safetyError = validatePin(safetyPin);
    if (safetyError != null) return 'PIN an toàn: $safetyError';

    // Duress PIN
    String? duressError = validatePin(duressPin);
    if (duressError != null) return 'PIN bị ép buộc: $duressError';

    // Must be different
    if (safetyPin == duressPin) {
      return 'PIN an toàn và PIN bị ép buộc phải khác nhau';
    }

    return null;
  }

  // ============ Trip Validation ============

  /// Validate bắt đầu chuyến đi
  static String? validateStartTrip({
    String? destinationName,
    required int durationMinutes,
  }) {
    // Destination (optional)
    if (destinationName != null && destinationName.length > 255) {
      return 'Tên điểm đến tối đa 255 ký tự';
    }

    // Duration
    if (durationMinutes < 1) return 'Thời gian tối thiểu 1 phút';
    if (durationMinutes > 1440) return 'Thời gian tối đa 24 giờ (1440 phút)';

    return null;
  }

  /// Validate nút hoảng loạn
  static String? validatePanicButton({
    double? latitude,
    double? longitude,
    int? batteryLevel,
  }) {
    // Location (optional)
    String? latError = validateLatitude(latitude);
    if (latError != null) return latError;

    String? lngError = validateLongitude(longitude);
    if (lngError != null) return lngError;

    // Battery (optional)
    String? batteryError = validateBattery(batteryLevel);
    if (batteryError != null) return batteryError;

    return null;
  }

  /// Validate cập nhật vị trí
  static String? validateLocationUpdate({
    required int tripId,
    required double latitude,
    required double longitude,
    int? batteryLevel,
  }) {
    if (tripId <= 0) return 'Trip ID không hợp lệ';

    String? latError = validateLatitude(latitude);
    if (latError != null) return latError;

    String? lngError = validateLongitude(longitude);
    if (lngError != null) return lngError;

    String? batteryError = validateBattery(batteryLevel);
    if (batteryError != null) return batteryError;

    return null;
  }

  /// Validate kết thúc chuyến đi
  static String? validateEndTrip({
    required int tripId,
    required String pinCode,
    double? latitude,
    double? longitude,
    int? batteryLevel,
  }) {
    if (tripId <= 0) return 'Trip ID không hợp lệ';

    // PIN validation
    String? pinError = validatePin(pinCode);
    if (pinError != null) return pinError;

    // Location (optional)
    String? latError = validateLatitude(latitude);
    if (latError != null) return latError;

    String? lngError = validateLongitude(longitude);
    if (lngError != null) return lngError;

    // Battery (optional)
    String? batteryError = validateBattery(batteryLevel);
    if (batteryError != null) return batteryError;

    return null;
  }

  // ============ Guardian Validation ============

  /// Validate thêm người bảo vệ
  static String? validateAddGuardian({
    required String contactName,
    required String contactPhoneNumber,
  }) {
    if (contactName.isEmpty) return 'Vui lòng nhập tên người liên hệ';
    if (contactName.length > 255) return 'Tên tối đa 255 ký tự';

    if (contactPhoneNumber.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (contactPhoneNumber.length > 20) return 'Số điện thoại tối đa 20 ký tự';

    // Vietnamese phone format (optional, có thể bỏ nếu muốn linh hoạt hơn)
    if (!isValidPhone(contactPhoneNumber)) {
      return 'Số điện thoại không hợp lệ';
    }

    return null;
  }

  /// Validate trạng thái người bảo vệ
  static String? validateGuardianStatus(String status) {
    const validStatuses = ['pending', 'accepted', 'rejected'];
    if (!validStatuses.contains(status)) {
      return 'Trạng thái không hợp lệ';
    }
    return null;
  }

  // ============ Common Text Validation ============

  /// Validate text field chung
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  /// Validate độ dài tối đa
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName tối đa $maxLength ký tự';
    }
    return null;
  }

  /// Validate độ dài tối thiểu
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName tối thiểu $minLength ký tự';
    }
    return null;
  }
}

