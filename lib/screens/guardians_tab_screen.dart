import 'package:flutter/material.dart';
import 'package:safetrek_app/injection_container.dart';
import 'package:safetrek_app/models/guardian.dart';
import 'package:safetrek_app/screens/auth_state.dart';
import 'package:safetrek_app/screens/guardian_view_model.dart';
import 'package:safetrek_app/utils/validation_helper.dart';

// 1. Giữ nguyên là StatefulWidget
class GuardiansTabScreen extends StatefulWidget {
  const GuardiansTabScreen({super.key});

  @override
  State<GuardiansTabScreen> createState() => _GuardiansTabScreenState();
}

class _GuardiansTabScreenState extends State<GuardiansTabScreen> {
  // 2. Thêm ViewModel và các biến trạng thái
  late final GuardianViewModel _viewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Lấy ViewModel từ GetIt (sl)
    _viewModel = sl<GuardianViewModel>();
    // Lắng nghe các thay đổi từ ViewModel để cập nhật lại UI
    _viewModel.addListener(_onViewModelUpdated);
    // Tải dữ liệu người bảo vệ lần đầu
    _viewModel.fetchGuardians();
  }

  @override
  void dispose() {
    // Huỷ lắng nghe để tránh lỗi rò rỉ bộ nhớ
    _viewModel.removeListener(_onViewModelUpdated);
    super.dispose();
  }

  // Hàm được gọi mỗi khi ViewModel có sự thay đổi
  void _onViewModelUpdated() {
    // Dùng setState để build lại giao diện với dữ liệu mới
    setState(() {
      _isLoading = _viewModel.state is AuthLoading && _viewModel.guardians.isEmpty;
    });
  }

  // 3. Sửa đổi hàm hiển thị pop-up để nó hoạt động với ViewModel
  void _showAddGuardianModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // Truyền ViewModel vào modal để nó có thể gọi hàm "addGuardian"
        return _AddGuardianModal(viewModel: _viewModel);
      },
    );
  }

  // Hiển thị dialog xác nhận xóa
  void _showDeleteConfirmDialog(Guardian guardian) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa "${guardian.contactName}" khỏi danh sách người bảo vệ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng dialog
                try {
                  await _viewModel.removeGuardian(guardian.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa người bảo vệ'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Xóa thất bại: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Người bảo vệ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack( // Dùng Stack để hiển thị loading indicator
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Các widget mô tả không thay đổi
                const Text(
                  'Danh sách những người sẽ nhận cảnh báo khẩn cấp',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Khi có cảnh báo, tất cả người bảo vệ sẽ nhận được tin nhắn SMS, thông báo push và email với vị trí GPS của bạn.',
                    style: TextStyle(color: primaryColor, height: 1.5),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddGuardianModal,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Thêm người bảo vệ', style: TextStyle(color: Colors.white, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // 4. Cập nhật số đếm từ dữ liệu thật
                Text(
                  'Danh sách (${_viewModel.guardians.length}/5)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 5. Thay thế danh sách giả bằng ListView.builder để hiển thị dữ liệu thật
                if (_viewModel.guardians.isEmpty && !_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('Chưa có người bảo vệ nào.', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _viewModel.guardians.length,
                    itemBuilder: (context, index) {
                      final guardian = _viewModel.guardians[index];
                      // Gọi hàm _buildGuardianCard với dữ liệu thật
                      return _buildGuardianCard(guardian);
                    },
                  ),

                const SizedBox(height: 30),
                // Widget "Quan trọng" giữ nguyên
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Text('Quan trọng', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Người bảo vệ phải xác nhận đồng ý nhận cảnh báo'),
                      const SizedBox(height: 8),
                      const Text('Chọn người đáng tin cậy và có thể liên lạc 24/7'),
                      const SizedBox(height: 8),
                      const Text('Nên có ít nhất 3 người bảo vệ'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Hiển thị vòng xoay loading khi đang tải
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  // 6. Sửa đổi _buildGuardianCard để nhận vào object Guardian
  Widget _buildGuardianCard(Guardian guardian) {
    final isVerified = guardian.status == 'accepted';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isVerified ? Theme.of(context).primaryColor : Colors.grey.shade400,
                  child: Text(
                      guardian.contactName.isNotEmpty ? guardian.contactName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(width: 16),
                // Dùng tên thật
                Expanded(child: Text(guardian.contactName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                const Spacer(),
                // Nút xóa với xác nhận
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteConfirmDialog(guardian),
                )
              ],
            ),
            const SizedBox(height: 12),
            // Dùng trạng thái thật
            if (isVerified)
              _buildStatusChip(Icons.check_circle, 'Đã xác nhận', Colors.green)
            else
              Column(
                children: [
                  _buildStatusChip(Icons.hourglass_empty, 'Đang chờ xác nhận', Colors.orange),
                  const SizedBox(height: 12),
                  // Nút để chuyển trạng thái sang accepted (dành cho test/demo)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _viewModel.updateGuardianStatus(guardian.id, 'accepted');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã cập nhật trạng thái thành công'), backgroundColor: Colors.green),
                          );
                        }
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Đánh dấu đã xác nhận'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            const Divider(height: 24),
            // Dùng SĐT thật
            _buildContactInfo(Icons.phone_outlined, guardian.contactPhoneNumber),
          ],
        ),
      ),
    );
  }

  // Các hàm helper giữ nguyên
  Widget _buildStatusChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }
}

// 7. Sửa _AddGuardianModal để nhận ViewModel và xử lý việc thêm
class _AddGuardianModal extends StatefulWidget {
  final GuardianViewModel viewModel;
  const _AddGuardianModal({required this.viewModel});

  @override
  State<_AddGuardianModal> createState() => _AddGuardianModalState();
}

class _AddGuardianModalState extends State<_AddGuardianModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isAdding = true);

      final newGuardian = Guardian(
        id: 0,
        contactName: _nameController.text,
        contactPhoneNumber: _phoneController.text,
        status: 'pending',
      );

      try {
        await widget.viewModel.addGuardian(newGuardian);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thêm thất bại: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isAdding = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Thêm người bảo vệ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Tên người bảo vệ', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Ví dụ: Nguyễn Văn A'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên người liên hệ';
                  }
                  if (value.length > 255) {
                    return 'Tên tối đa 255 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Số điện thoại người bảo vệ', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration('0xxxxxxxxx hoặc +84xxxxxxxxx'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (value.length > 20) {
                    return 'Số điện thoại tối đa 20 ký tự';
                  }
                  // Validate format Việt Nam
                  if (!ValidationHelper.isValidPhone(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAdding ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isAdding
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Thêm người bảo vệ', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
    );
  }
}