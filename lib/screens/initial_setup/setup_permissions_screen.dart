import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safetrek_app/utils/app_routes.dart';

/// Bước 3: Hướng dẫn cấp quyền cho ứng dụng
/// GPS, Thông báo, Chạy nền
class SetupPermissionsScreen extends StatefulWidget {
  const SetupPermissionsScreen({super.key});

  @override
  State<SetupPermissionsScreen> createState() => _SetupPermissionsScreenState();
}

class _SetupPermissionsScreenState extends State<SetupPermissionsScreen> {
  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _backgroundGranted = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsWithTimeout();
  }

  Future<void> _checkPermissionsWithTimeout() async {
    try {
      await _checkPermissions().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          // Nếu timeout (quá 3s), hiển thị UI với quyền chưa cấp
          print('Permission check timeout');
          setState(() {
            _checking = false;
            _locationGranted = false;
            _notificationGranted = false;
            _backgroundGranted = false;
          });
        },
      );
    } catch (e) {
      print('Permission check error: $e');
      setState(() {
        _checking = false;
        _locationGranted = false;
        _notificationGranted = false;
        _backgroundGranted = false;
      });
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _checking = true);

    try {
      // Kiểm tra quyền location
      final locationStatus = await Permission.location.status;
      _locationGranted = locationStatus.isGranted;

      // Kiểm tra quyền notification
      final notificationStatus = await Permission.notification.status;
      _notificationGranted = notificationStatus.isGranted;

      // Kiểm tra quyền background (Always location)
      final backgroundStatus = await Permission.locationAlways.status;
      _backgroundGranted = backgroundStatus.isGranted;
    } catch (e) {
      // Nếu lỗi (chưa cấu hình đúng), mặc định là chưa cấp
      print('Error checking permissions: $e');
      _locationGranted = false;
      _notificationGranted = false;
      _backgroundGranted = false;
    }

    setState(() => _checking = false);
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    await _checkPermissions();

    if (status.isPermanentlyDenied) {
      // Hướng dẫn mở Settings
      _showOpenSettingsDialog();
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cần cấp quyền'),
        content: const Text(
          'Một số quyền đã bị từ chối vĩnh viễn. Vui lòng vào Cài đặt hệ thống để cấp quyền cho ứng dụng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
  }

  void _onComplete() async {
    // TODO: Lưu trạng thái đã hoàn thành setup
    // await SharedPreferences.getInstance().then((prefs) => prefs.setBool('setup_completed', true));

    if (mounted) {
      // Chuyển đến Dashboard
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false, // Xóa toàn bộ stack
      );
    }
  }

  bool get _allPermissionsGranted {
    return _locationGranted && _notificationGranted && _backgroundGranted;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Không cho phép back
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bước 3/3'),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: 3 / 3,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),

                const SizedBox(height: 24),

                // Logo from assets - Larger size
                Center(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Cấp quyền cho ứng dụng',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                const Text(
                  'Để bảo vệ bạn hiệu quả, ứng dụng cần một số quyền quan trọng. Hãy cấp tất cả các quyền dưới đây.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                if (_checking)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  // Permission card - Location
                  _buildPermissionCard(
                    icon: Icons.location_on_outlined,
                    color: Colors.blue,
                    title: 'Vị trí GPS',
                    description: 'Để theo dõi vị trí của bạn trong trường hợp khẩn cấp',
                    isGranted: _locationGranted,
                    onRequest: () => _requestPermission(Permission.location),
                  ),

                  const SizedBox(height: 16),

                  // Permission card - Notification
                  _buildPermissionCard(
                    icon: Icons.notifications_outlined,
                    color: Colors.green,
                    title: 'Thông báo',
                    description: 'Để gửi cảnh báo khẩn cấp tới bạn và người thân',
                    isGranted: _notificationGranted,
                    onRequest: () => _requestPermission(Permission.notification),
                  ),

                  const SizedBox(height: 16),

                  // Permission card - Background
                  _buildPermissionCard(
                    icon: Icons.watch_later_outlined,
                    color: Colors.orange,
                    title: 'Chạy nền',
                    description: 'Để ứng dụng tiếp tục bảo vệ bạn ngay cả khi màn hình tắt',
                    isGranted: _backgroundGranted,
                    onRequest: () => _requestPermission(Permission.locationAlways),
                  ),
                ],

                const SizedBox(height: 24),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Quan trọng: Tất cả các quyền này là BẮT BUỘC để ứng dụng hoạt động đúng trong tình huống khẩn cấp. Không cấp quyền có thể khiến bạn không được bảo vệ.',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Complete button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _allPermissionsGranted ? _onComplete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Hoàn thành thiết lập',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_allPermissionsGranted) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_outline, size: 24),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Status message
                Center(
                  child: Text(
                    _allPermissionsGranted
                        ? 'Tất cả quyền đã được cấp ✓'
                        : 'Vui lòng cấp tất cả các quyền để tiếp tục',
                    style: TextStyle(
                      color: _allPermissionsGranted ? Colors.green : Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: _allPermissionsGranted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Open settings manually
                Center(
                  child: TextButton.icon(
                    onPressed: openAppSettings,
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('Mở Cài đặt hệ thống'),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGranted ? color.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted ? color : Colors.grey.shade300,
          width: isGranted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGranted ? color.withOpacity(0.1) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isGranted ? color : Colors.grey, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isGranted)
                      Icon(Icons.check_circle, color: color, size: 24),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                if (!isGranted) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: onRequest,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Cấp quyền'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

