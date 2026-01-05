// lib/widgets/session_expired_dialog.dart

import 'package:flutter/material.dart';
import 'package:safetrek_app/utils/app_routes.dart';

/// Dialog hiển thị khi session hết hạn
class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.access_time_filled,
            color: Colors.orange[400],
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Phiên đăng nhập hết hạn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phiên đăng nhập của bạn đã hết hạn do:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildReason('• Sử dụng app quá lâu'),
          _buildReason('• Không có hoạt động trong thời gian dài'),
          _buildReason('• Token đã bị thu hồi'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[300],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vui lòng đăng nhập lại để tiếp tục sử dụng.',
                    style: TextStyle(
                      color: Colors.blue[200],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Close dialog
            Navigator.of(context).pop();

            // Navigate to login
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue[600],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Đăng nhập lại',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReason(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Helper function để show dialog từ bất kỳ đâu
Future<void> showSessionExpiredDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false, // Không cho đóng bằng cách tap outside
    builder: (context) => const SessionExpiredDialog(),
  );
}

