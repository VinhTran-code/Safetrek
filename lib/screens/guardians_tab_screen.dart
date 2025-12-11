import 'package:flutter/material.dart';

// 1. Chuyển thành StatefulWidget
class GuardiansTabScreen extends StatefulWidget {
  const GuardiansTabScreen({super.key});

  @override
  State<GuardiansTabScreen> createState() => _GuardiansTabScreenState();
}

class _GuardiansTabScreenState extends State<GuardiansTabScreen> {

  // Hàm hiển thị pop-up thêm người bảo vệ
  void _showAddGuardianModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép modal chiếm nhiều không gian hơn
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // Trả về widget AddGuardianModal để xây dựng giao diện pop-up
        return const _AddGuardianModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lưu ý: Theme.of(context).primaryColor được dùng làm màu chủ đạo (màu xanh lá)
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Người bảo vệ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                // Gắn hàm _showAddGuardianModal vào onPressed
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
            const Text(
              'Danh sách (2/5)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildGuardianCard(
              context,
              initial: 'N',
              name: 'Nguyễn Văn A',
              relation: 'Bố/Mẹ',
              phone: '0901234567',
              email: 'nguyenvana@email.com',
              isVerified: true,
            ),
            const SizedBox(height: 16),
            _buildGuardianCard(
              context,
              initial: 'L',
              name: 'Lê Văn C',
              relation: 'Anh/Chị',
              phone: '0923456789',
              email: 'levanc@email.com',
              isVerified: false,
            ),
            const SizedBox(height: 30),
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
    );
  }

  Widget _buildGuardianCard(
      BuildContext context, {
        required String initial,
        required String name,
        required String relation,
        required String phone,
        required String email,
        required bool isVerified,
      }) {
    return Card(
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
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(relation, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // TODO: Remove guardian logic
                  },
                )
              ],
            ),
            const SizedBox(height: 12),
            if (isVerified)
              _buildStatusChip(Icons.check_circle, 'Đã xác nhận', Colors.green)
            else
              _buildStatusChip(Icons.hourglass_empty, 'Đang chờ xác nhận', Colors.orange),
            const Divider(height: 24),
            _buildContactInfo(Icons.phone_outlined, phone),
            const SizedBox(height: 8),
            _buildContactInfo(Icons.email_outlined, email),
          ],
        ),
      ),
    );
  }

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

// Widget riêng cho pop-up thêm người bảo vệ
class _AddGuardianModal extends StatefulWidget {
  const _AddGuardianModal();

  @override
  State<_AddGuardianModal> createState() => _AddGuardianModalState();
}

class _AddGuardianModalState extends State<_AddGuardianModal> {
  // Biến tạm để mô phỏng việc chọn quan hệ
  String _selectedRelation = 'Bố/Mẹ';

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Sử dụng Padding + MediaQuery.of(context).viewInsets.bottom để bàn phím không che form
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thêm người bảo vệ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tên người bảo vệ
            const Text('Tên người bảo vệ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              decoration: _buildInputDecoration('Ví dụ: Nguyễn Văn A'),
            ),
            const SizedBox(height: 16),

            // Số điện thoại
            const Text('Số điện thoại người bảo vệ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration('Ví dụ: 0123456789'),
            ),
            const SizedBox(height: 16),

            // Email
            const Text('email người bảo vệ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: _buildInputDecoration('Ví dụ: nguyenvana@email.com'),
            ),
            const SizedBox(height: 24),

            // Dạng người bảo vệ (Relation buttons)
            const Text('Dạng người bảo vệ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRelationButton('Bố/Mẹ', primaryColor),
                const SizedBox(width: 10),
                _buildRelationButton('Anh/Chị', primaryColor),
                const SizedBox(width: 10),
                _buildRelationButton('Khác', primaryColor),
              ],
            ),
            const SizedBox(height: 30),

            // Nút Thêm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Thêm logic lưu thông tin người bảo vệ
                  Navigator.pop(context); // Đóng pop-up sau khi thêm
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Thêm người bảo vệ', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function cho InputDecoration của TextField
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }

  // Helper function cho nút chọn quan hệ
  Widget _buildRelationButton(String text, Color primaryColor) {
    final isSelected = _selectedRelation == text;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedRelation = text;
          });
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          side: BorderSide(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}