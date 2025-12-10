import 'package:flutter/material.dart';
import 'package:safetrek_app/screens/trip_setup_screen.dart';
import 'package:safetrek_app/utils/app_routes.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Image.asset('assets/images/app_logo.png', height: 300)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Nút Bắt đầu chuyến đi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TripSetupScreen()),
                  );
                },
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('Bắt đầu chuyến đi', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Nút Hoảng loạn
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.panicAlert);
                },
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
                label: const Text('NÚT HOẢNG LOẠN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Colors.red.shade600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bấm để gửi cảnh báo khẩn cấp ngay lập tức',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            // Các thẻ thông tin
            Row(
              children: [
                Expanded(child: _buildInfoCard(context, Icons.timer_outlined, 'Tự động giám sát', 'Hẹn giờ theo dõi chuyến đi')),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard(context, Icons.notification_important_outlined, 'Cảnh báo khẩn cấp', 'Thông báo người thân tự động')),
              ],
            ),
            const SizedBox(height: 30),
            // Phần "Cách hoạt động"
            _buildHowItWorksSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).primaryColor),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cách hoạt động',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStep(context, '1', 'Đặt thời gian dự kiến và điểm đến'),
          _buildStep(context, '2', 'Ứng dụng theo dõi hành trình của bạn'),
          _buildStep(context, '3', 'Xác nhận an toàn khi đến nơi'),
          _buildStep(context, '4', 'Nếu không xác nhận, cảnh báo sẽ được gửi tự động', isLast: true),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}