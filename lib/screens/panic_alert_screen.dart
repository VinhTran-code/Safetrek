import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safetrek_app/injection_container.dart';
import 'package:safetrek_app/screens/trip_view_model.dart';
import 'package:safetrek_app/models/trip.dart';

class PanicAlertScreen extends StatefulWidget {
  final bool isInTrip; // Có đang trong chuyến đi hay không
  final Trip? tripData; // Dữ liệu trip được truyền từ bên ngoài

  const PanicAlertScreen({
    super.key,
    this.isInTrip = false, // Mặc định là false (gọi từ trang chủ)
    this.tripData, // Trip data nếu có
  });

  @override
  State<PanicAlertScreen> createState() => _PanicAlertScreenState();
}

class _PanicAlertScreenState extends State<PanicAlertScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late final TripViewModel _tripViewModel;
  bool _isLoading = true;
  String _currentLocation = 'Đang cập nhật...';

  @override
  void initState() {
    super.initState();
    _tripViewModel = sl<TripViewModel>();

    // Tạo animation cho màu đỏ nhấp nháy
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.red.shade600,
      end: Colors.red.shade800,
    ).animate(_animationController);

    // Nếu có tripData được truyền vào
    if (widget.tripData != null) {
      // Lấy vị trí từ tripData nếu có
      if (widget.tripData!.locationHistory?.isNotEmpty ?? false) {
        final lastLoc = widget.tripData!.locationHistory!.last;
        _currentLocation = 'https://maps.google.com/?q=${lastLoc.latitude},${lastLoc.longitude}';
      } else {
        // Nếu không có locationHistory, thử lấy vị trí hiện tại
        _getCurrentLocation();
      }
      _isLoading = false;
    } else {
      // Làm mới thông tin trip nếu cần
      _refreshTripData();
    }
  }

  Future<void> _refreshTripData() async {
    try {
      if (widget.isInTrip) {
        // Ưu tiên sử dụng tripData được truyền vào
        if (widget.tripData != null) {
          // Lấy vị trí từ locationHistory hoặc lấy vị trí hiện tại
          if (widget.tripData!.locationHistory?.isEmpty ?? true) {
            await _getCurrentLocation();
          } else {
            final lastLoc = widget.tripData!.locationHistory!.last;
            _currentLocation = 'https://maps.google.com/?q=${lastLoc.latitude},${lastLoc.longitude}';
          }
        } else {
          // Nếu không có tripData, thử lấy từ service
          await _tripViewModel.tripService.refreshCurrentTrip();

          final currentTrip = _tripViewModel.currentTrip;
          if (currentTrip?.locationHistory?.isEmpty ?? true) {
            await _getCurrentLocation();
          } else {
            final lastLoc = currentTrip!.locationHistory!.last;
            _currentLocation = 'https://maps.google.com/?q=${lastLoc.latitude},${lastLoc.longitude}';
          }
        }
      }
    } catch (e) {
      print('Lỗi khi làm mới thông tin trip: $e');
      // Thử lấy vị trí hiện tại (nhưng không await để tránh blocking)
      if (widget.isInTrip) {
        _getCurrentLocation().catchError((e) {
          print('Lỗi khi lấy vị trí: $e');
        });
      }
    } finally {
      // Luôn set _isLoading = false để hiển thị UI
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentLocation = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
        });
      }
    } catch (e) {
      print('Lỗi khi lấy vị trí: $e');
      if (mounted) {
        setState(() {
          _currentLocation = 'Không thể lấy vị trí';
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$hour:$minute:$second $day/$month/$year';
  }

  void _closeScreen() {
    // Pop về trang chủ an toàn
    if (mounted) {
      // Sử dụng pushNamedAndRemoveUntil để tránh lỗi
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/dashboard',
        (route) => false,
      );
    }
  }

  String _getTripStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'Đang hoạt động';
      case 'panic':
        return 'Khẩn cấp';
      case 'completed':
        return 'Hoàn thành';
      case 'duress_ended':
        return 'Đã kết thúc';
      case 'alerted':
        return 'Đã cảnh báo';
      default:
        return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ưu tiên sử dụng tripData được truyền vào
    final currentTrip = widget.tripData ?? _tripViewModel.currentTrip;
    final now = DateTime.now();

    // Nếu không trong chuyến đi, không cần hiển thị thông tin trip
    final showTripInfo = widget.isInTrip && currentTrip != null;

    // Hiển thị loading nếu đang tải dữ liệu và đang trong chuyến đi
    if (_isLoading && widget.isInTrip) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _closeScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Red Alert Banner với animation
              AnimatedBuilder(
                animation: _colorAnimation,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _colorAnimation.value,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: child,
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            showTripInfo
                              ? 'Cảnh báo khẩn cấp trong chuyến đi!'
                              : 'Cảnh báo khẩn cấp đã được gửi!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            showTripInfo
                              ? 'Bạn đã kích hoạt nút khẩn cấp trong chuyến đi. Cảnh báo đã được gửi đến tất cả người bảo vệ với thông tin vị trí.'
                              : 'Nút khẩn cấp đã kích hoạt. Cảnh báo đã được gửi đến tất cả người bảo vệ.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _closeScreen,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [

                      // Quick Info Card 1: Time
                      _buildQuickInfoCard(
                        Icons.timer_outlined,
                        'Thời gian gửi',
                        _formatTime(now),
                      ),
                      const SizedBox(height: 12),

                      // Quick Info Card 2: Location (chỉ hiện khi có trip)
                      if (showTripInfo) ...[
                        _buildQuickInfoCard(
                          Icons.location_on_outlined,
                          'Vị trí cuối cùng',
                          _currentLocation,
                        ),
                        const SizedBox(height: 12),

                        // Quick Info Card 3: Battery
                        _buildQuickInfoCard(
                          Icons.battery_full_rounded,
                          'Mức pin',
                          currentTrip.locationHistory?.isNotEmpty == true
                              ? '${currentTrip.locationHistory!.last.batteryLevel}%'
                              : '100%',
                        ),
                        const SizedBox(height: 24),

                        // Trip Information Section (chỉ hiện khi có trip)
                        _buildSection(
                          'Thông tin chuyến đi',
                          [
                            _buildRow('Điểm đến', currentTrip.destinationName),
                            const SizedBox(height: 12),
                            _buildRow('Bắt đầu lúc', _formatTime(currentTrip.startTime).substring(0, 8)),
                            const SizedBox(height: 12),
                            _buildRow('Thời gian dự kiến', _formatTime(currentTrip.expectedEndTime).substring(0, 5)),
                            const SizedBox(height: 12),
                            _buildRow('Trạng thái', _getTripStatusText(currentTrip.status)),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Guardians Section
                      _buildSection(
                        'Đã gửi cảnh báo đến người bảo vệ',
                        [
                          const Text(
                            'Tin nhắn cảnh báo đã được gửi đến tất cả người bảo vệ của bạn.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Message Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.phone, color: Colors.orange.shade600, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Nội dung tin nhắn đã gửi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                showTripInfo
                                  ? 'Cảnh báo khẩn cấp! Người thân của bạn đang trong chuyến đi đến ${currentTrip.destinationName} và đã kích hoạt nút hoảng loạn. '
                                    'Thời gian: ${_formatTime(now)}. '
                                    'Vui lòng liên hệ ngay.'
                                  : 'Cảnh báo khẩn cấp! Người thân của bạn đã kích hoạt nút hoảng loạn. '
                                    'Thời gian: ${_formatTime(now)}. '
                                    'Vui lòng liên hệ ngay.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _closeScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Call 113 - có thể dùng url_launcher để gọi tel:113
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chức năng gọi 113 sẽ được tích hợp sau'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Gọi 113 (Cảnh sát)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

