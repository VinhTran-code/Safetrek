// lib/models/guardian.dart

class Guardian {
  final int id;
  final String contactName;
  final String contactPhoneNumber;
  final String status; // 'pending', 'accepted', 'rejected'

  Guardian({
    required this.id,
    required this.contactName,
    required this.contactPhoneNumber,
    required this.status,
  });

  // Cập nhật factory để đọc JSON từ API
  factory Guardian.fromJson(Map<String, dynamic> json) {
    return Guardian(
      id: json['id'],
      contactName: json['contact_name'],
      contactPhoneNumber: json['contact_phone_number'],
      status: json['status'],
    );
  }

  // Cập nhật hàm toJson để gửi dữ liệu lên API
  Map<String, dynamic> toJson() {
    return {
      'contact_name': contactName,
      'contact_phone_number': contactPhoneNumber,
    };
  }
}