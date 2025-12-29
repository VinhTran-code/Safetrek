// lib/repositories/guardian_repository.dart
import 'package:safetrek_app/core/network/api_client.dart';
import 'package:safetrek_app/models/guardian.dart';
import 'package:safetrek_app/core/constants/api_constants.dart';

class GuardianRepository {
  final ApiClient apiClient;

  GuardianRepository({required this.apiClient});

  Future<List<Guardian>> getGuardians() async {
    try {
      final response = await apiClient.get(ApiConstants.guardians);
      // API của bạn trả về { "success": true, "data": [ ... ] }
      List<dynamic> data = response.data['data'];
      return data.map((json) => Guardian.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi tải danh sách người bảo vệ: $e');
      rethrow; // Ném lại lỗi để ViewModel có thể xử lý
    }
  }

  Future<Guardian> addGuardian(Guardian guardian) async {
    try {
      // Phương thức toJson() của guardian chỉ chứa tên và sđt
      final response = await apiClient.post(
        ApiConstants.guardians,
        data: guardian.toJson(),
      );
      // API của bạn trả về { ..., "data": { ... } }
      return Guardian.fromJson(response.data['data']);
    } catch (e) {
      print('Lỗi khi thêm người bảo vệ: $e');
      rethrow;
    }
  }

  Future<void> deleteGuardian(int guardianId) async {
    try {
      // Endpoint là /api/guardians/{id}
      await apiClient.delete('${ApiConstants.guardians}/$guardianId');
    } catch (e) {
      print('Lỗi khi xóa người bảo vệ: $e');
      rethrow;
    }
  }
}
