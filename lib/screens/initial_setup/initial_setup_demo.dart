import 'package:flutter/material.dart';
import 'package:safetrek_app/screens/initial_setup/initial_setup_welcome_screen.dart';

/// File demo để test Initial Setup Flow
/// Chạy màn hình này để xem toàn bộ flow setup
///
/// Để test:
/// 1. Thay đổi home trong main.dart thành: home: InitialSetupDemo()
/// 2. Chạy: flutter run
/// 3. Nhấn nút "Test Initial Setup Flow"
class InitialSetupDemo extends StatelessWidget {
  const InitialSetupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo - Initial Setup Flow'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_outline,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Initial Setup Flow Demo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Luồng thiết lập ban đầu bao gồm:\n'
                '1. Màn hình chào mừng\n'
                '2. Tạo mã PIN an toàn\n'
                '3. Tạo mã PIN bị ép buộc\n'
                '4. Cấp quyền ứng dụng',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InitialSetupWelcomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu Test Flow',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hướng dẫn Test'),
                      content: const SingleChildScrollView(
                        child: Text(
                          'Các bước test:\n\n'
                          '1. Nhấn "Bắt đầu Test Flow"\n\n'
                          '2. Màn hình Welcome: Không thể nhấn Back\n\n'
                          '3. Setup Safe PIN:\n'
                          '   - Nhập PIN: 1234\n'
                          '   - Xác nhận: 1234\n\n'
                          '4. Setup Duress PIN:\n'
                          '   - Thử nhập: 1234 → Lỗi\n'
                          '   - Nhập: 9876\n'
                          '   - Xác nhận: 9876\n\n'
                          '5. Cấp quyền:\n'
                          '   - Nhấn "Cấp quyền" cho từng mục\n'
                          '   - Hoặc "Mở Cài đặt" để cấp thủ công\n\n'
                          '6. Hoàn thành → Về Dashboard',
                          style: TextStyle(height: 1.5),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Xem hướng dẫn test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

