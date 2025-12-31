import 'package:flutter/material.dart';
import 'package:safetrek_app/widgets/circular_timer_view.dart';
import 'package:safetrek_app/utils/app_routes.dart';
import 'package:safetrek_app/screens/submitpin.dart';
import 'package:safetrek_app/screens/trip_view_model.dart';
import 'package:safetrek_app/injection_container.dart';
import 'package:geolocator/geolocator.dart';


class TripMonitoringScreen extends StatefulWidget {
  final int tripDurationInSeconds;
  final int? tripId;

  const TripMonitoringScreen({
    super.key,
    required this.tripDurationInSeconds,
    this.tripId,
  });

  @override
  State<TripMonitoringScreen> createState() => _TripMonitoringScreenState();
}

class _TripMonitoringScreenState extends State<TripMonitoringScreen> {
  late final TripViewModel _tripViewModel;
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tripViewModel = sl<TripViewModel>();
  }

  Future<void> _handlePanicButton() async {
    // Hiển thị dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn gửi cảnh báo khẩn cấp?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Lấy battery level (giả định 100% nếu không lấy được)
      int batteryLevel = 100;

      // Gọi API panic
      await _tripViewModel.sendPanic(
        latitude: position.latitude,
        longitude: position.longitude,
        batteryLevel: batteryLevel,
      );

      // Đóng loading
      if (mounted) Navigator.pop(context);

      // Chuyển đến màn hình panic alert
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.panicAlert);
      }
    } catch (e) {
      // Đóng loading
      if (mounted) Navigator.pop(context);

      // Hiển thị lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi cảnh báo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSafeArrival() {
    if (widget.tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin chuyến đi')),
      );
      return;
    }

    // Chuyển đến màn hình nhập PIN
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitPinScreen(tripId: widget.tripId!),
      ),
    );
  }

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
            CircularTimerView(duration: widget.tripDurationInSeconds),

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
                  content: TimeOfDay.fromDateTime(_startTime).format(context),
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
                    onPressed: _handleSafeArrival,
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
                    onPressed: _handlePanicButton,
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
