import 'package:flutter/material.dart';
import 'package:safetrek_app/widgets/circular_timer_view.dart';
import 'package:safetrek_app/utils/app_routes.dart';

class TripMonitoringScreen extends StatelessWidget {
  final int tripDurationInSeconds;

  const TripMonitoringScreen({super.key, required this.tripDurationInSeconds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyến đi đang diễn ra'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Tắt nút back mặc định
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Phần đồng hồ
            CircularTimerView(duration: tripDurationInSeconds),
            
            // Phần thông tin
            Column(
              children: [
                _buildInfoCard(
                  context: context,
                  title: 'Trạng thái GPS',
                  content: 'Đang theo dõi vị trí',
                  icon: Icons.gps_fixed,
                  iconColor: Theme.of(context).primaryColor,
                  isHighlighted: true,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context: context,
                  title: 'Bắt đầu lúc',
                  content: TimeOfDay.now().format(context),
                  icon: Icons.access_time,
                  iconColor: Colors.grey,
                ),
              ],
            ),
            
            // Phần nút bấm
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Logic xác nhận an toàn
                      Navigator.pop(context); // Tạm thời quay về
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Tôi đã an toàn'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.panicAlert);
                    },
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('NÚT HOẢNG LOẠN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                 const SizedBox(height: 8),
                Text(
                  'Bấm để gửi cảnh báo khẩn cấp ngay lập tức',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
