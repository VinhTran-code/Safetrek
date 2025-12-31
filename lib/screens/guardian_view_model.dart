// lib/screens/guardian_view_model.dart
import 'package:flutter/material.dart';
import 'package:safetrek_app/models/guardian.dart';
import 'package:safetrek_app/repositories/guardian_repository.dart';
import 'package:safetrek_app/services/auth_service.dart';
import 'auth_state.dart'; // Sử dụng lại các trạng thái AuthLoading, AuthError

class GuardianViewModel extends ChangeNotifier {
  // Sửa đổi: Chỉ cần repository và authService, không cần token trực tiếp
  final GuardianRepository repository;
  final AuthService authService;

  // Sửa đổi: Cập nhật hàm khởi tạo để khớp với injection_container.dart
  GuardianViewModel({required this.repository, required this.authService});

  dynamic _state;
  dynamic get state => _state;

  List<Guardian> _guardians = [];
  List<Guardian> get guardians => _guardians;

  void resetState() {
    _state = null;
    notifyListeners();
  }

  // Lấy danh sách người bảo vệ
  Future<void> fetchGuardians() async {
    // Chỉ thực hiện nếu người dùng đã đăng nhập
    if (authService.currentUser == null) return;

    _state = AuthLoading();
    notifyListeners();
    try {
      // Sửa đổi: Không cần truyền token nữa
      _guardians = await repository.getGuardians();
      _state = null; // Success
    } catch (e) {
      _state = AuthError(e.toString());
    }
    notifyListeners();
  }

  // Thêm người bảo vệ mới
  Future<void> addGuardian(Guardian guardian) async {
    _state = AuthLoading();
    notifyListeners();
    try {
      // Sửa đổi: Repository giờ trả về guardian đã được tạo
      final newGuardian = await repository.addGuardian(guardian);
      _guardians.add(newGuardian); // Tối ưu: Chỉ cần thêm vào danh sách
      _state = null; // Success
    } catch (e) {
      _state = AuthError(e.toString());
    }
    notifyListeners();
  }

  // Xóa một người bảo vệ
  Future<void> removeGuardian(int guardianId) async {
    // Không cần set state loading cho việc xóa để UI mượt hơn
    try {
      // Sửa đổi: Không cần truyền token
      await repository.deleteGuardian(guardianId);
      _guardians.removeWhere((g) => g.id == guardianId); // Xóa khỏi danh sách trên UI
    } catch (e) {
      // Nếu có lỗi, có thể hiển thị snackbar hoặc set state lỗi
      _state = AuthError(e.toString());
    }
    notifyListeners();
  }

  // Cập nhật trạng thái guardian (accepted/pending/rejected)
  Future<void> updateGuardianStatus(int guardianId, String status) async {
    try {
      final updatedGuardian = await repository.updateGuardianStatus(guardianId, status);
      // Tìm và cập nhật trong danh sách
      final index = _guardians.indexWhere((g) => g.id == guardianId);
      if (index != -1) {
        _guardians[index] = updatedGuardian;
      }
    } catch (e) {
      _state = AuthError(e.toString());
    }
    notifyListeners();
  }
}
