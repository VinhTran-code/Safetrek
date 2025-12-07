import 'package:flutter/material.dart';

class GuardiansTabScreen extends StatelessWidget {
  const GuardiansTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Khi có cảnh báo, tất cả người bảo vệ sẽ nhận được tin nhắn SMS, thông báo push và email với vị trí GPS của bạn.',
                style: TextStyle(color: Theme.of(context).primaryColor, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add guardian logic
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Thêm người bảo vệ', style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
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
