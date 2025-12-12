import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safetrek_app/screens/auth_view_model.dart';
import 'package:safetrek_app/screens/change_password_screen.dart';
import 'package:safetrek_app/screens/safe_pin.dart';
import 'package:safetrek_app/screens/force_pin.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  bool _notificationsEnabled = true;
  bool _gpsEnabled = true;
  bool _backgroundRunEnabled = true;

  //điều hướng tới màn hình đổi mã PIN an toàn
  void _navigateToSafePinSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SafePinSetupScreen(),
      ),
    );
  }
  //điều hướng tới màn hình đổi mã PIN ép buộc
  void _navigateToForcePinSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForcePinSetupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy viewModel để gọi hàm logout, không lắng nghe thay đổi
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cấu hình ứng dụng và bảo mật',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Bảo mật'),
            _buildSettingCard(
              icon: Icons.lock_outline_rounded,
              iconColor: Colors.green,
              title: 'Mã PIN an toàn',
              subtitle: '****',
              onTap: _navigateToSafePinSetup,
            ),
            _buildSettingCard(
              icon: Icons.phonelink_lock_outlined,
              iconColor: Colors.red,
              title: 'Mã PIN bị ép buộc',
              subtitle: '****',
              onTap: _navigateToForcePinSetup,
            ),
            _buildInfoBox(
              icon: Icons.info_outline,
              color: Colors.orange,
              text: 'Mã pin bị ép buộc: Dùng khi bị ép buộc tắt ứng dụng. Ứng dụng sẽ giả vờ tắt nhưng vẫn gửi cảnh báo ngầm.',
            ),
            
            const SizedBox(height: 20),
            _buildSectionHeader('Quyền truy cập'),
            _buildSwitchSettingCard(
              icon: Icons.notifications_outlined,
              iconColor: Colors.blue,
              title: 'Thông báo',
              subtitle: 'Cho phép gửi cảnh báo',
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            _buildSwitchSettingCard(
              icon: Icons.gps_fixed_rounded,
              iconColor: Colors.green,
              title: 'Vị trí GPS',
              subtitle: 'Theo dõi vị trí liên tục',
              value: _gpsEnabled,
              onChanged: (val) => setState(() => _gpsEnabled = val),
            ),
             _buildSwitchSettingCard(
              icon: Icons.battery_charging_full_outlined,
              iconColor: Colors.orange,
              title: 'Chạy nền',
              subtitle: 'Hoạt động khi tắt màn hình',
              value: _backgroundRunEnabled,
              onChanged: (val) => setState(() => _backgroundRunEnabled = val),
            ),
             _buildInfoBox(
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              text: 'Quan trọng: Tất cả các quyền trên phải được bật để ứng dụng hoạt động chính xác trong trường hợp khẩn cấp.',
            ),

            const SizedBox(height: 20),
            _buildSectionHeader('Thông tin chung'),
            _buildSettingCard(
              icon: Icons.password_rounded,
              iconColor: Colors.grey,
              title: 'Đổi mật khẩu',
              subtitle: '********',
              onTap: () { // Modified onTap to navigate to ChangePasswordScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              }
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  authViewModel.performLogout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Đăng xuất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionHeader('Về ứng dụng'),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phiên bản: 1.0.0'),
                  SizedBox(height: 8),
                  Text('Mục đích: Bảo vệ an toàn cá nhân'),
                  SizedBox(height: 8),
                  Text('Lưu ý: Ứng dụng không thu thập dữ liệu cá nhân nhạy cảm', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }
  
  Widget _buildSettingCard({required IconData icon, Color? iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200)
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchSettingCard({required IconData icon, required Color iconColor, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
     return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200)
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoBox({required IconData icon, required Color color, required String text}) {
     return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 4, bottom:12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                // ĐÂY LÀ DÒNG ĐÃ SỬA
                style: TextStyle(color: color, height: 1.4),
              ),
            ),
          ],
        ),
      );
  }
}
