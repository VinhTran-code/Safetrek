import 'package:flutter/material.dart';
import 'package:safetrek_app/screens/initial_setup/setup_permissions_screen.dart';
import 'package:safetrek_app/services/pin_service.dart';
import 'package:safetrek_app/injection_container.dart' as di;

/// Bước 2: Thiết lập mã PIN bị ép buộc
/// User phải nhập PIN khác với PIN an toàn
class SetupDuressPinScreen extends StatefulWidget {
  final String safePinToCompare; // PIN an toàn để so sánh không trùng

  const SetupDuressPinScreen({
    super.key,
    required this.safePinToCompare,
  });

  @override
  State<SetupDuressPinScreen> createState() => _SetupDuressPinScreenState();
}

class _SetupDuressPinScreenState extends State<SetupDuressPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePin = true;
  bool _saving = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePin(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập mã PIN';
    if (v.trim().length != 4) return 'Mã PIN phải có đúng 4 chữ số';
    if (!RegExp(r"^\d+$").hasMatch(v)) return 'Mã PIN chỉ được chứa chữ số';
    if (v == widget.safePinToCompare) {
      return 'Mã PIN bị ép buộc phải khác mã PIN an toàn';
    }
    return null;
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      // Gọi API để setup PINs
      final pinService = di.sl<PinService>();
      await pinService.setupPins(
        safetyPin: widget.safePinToCompare,
        duressPin: _pinController.text,
      );

      setState(() => _saving = false);

      if (mounted) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thiết lập mã PIN thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển sang bước 3: Hướng dẫn cấp quyền
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SetupPermissionsScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Không cho phép back
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bước 2/3'),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: 2 / 3,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
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
                    'Tạo mã PIN bị ép buộc',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  const Text(
                    'Mã PIN này sẽ được sử dụng khi bạn bị ép buộc tắt ứng dụng. Ứng dụng sẽ giả vờ tắt nhưng vẫn tiếp tục hoạt động và gửi cảnh báo ngầm. Bạn cần nhập đúng 4 chữ số.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // PIN input
                  TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: _obscurePin,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'Mã PIN bị ép buộc',
                      hintText: 'Nhập đúng 4 chữ số',
                      prefixIcon: const Icon(Icons.phonelink_lock_outlined, color: Colors.red),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: _validatePin,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // Confirm PIN input
                  TextFormField(
                    controller: _confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: _obscurePin,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'Nhập lại mã PIN',
                      hintText: 'Xác nhận mã PIN',
                      prefixIcon: const Icon(Icons.lock, color: Colors.red),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (v) {
                      final base = _validatePin(v);
                      if (base != null) return base;
                      if (v != _pinController.text) return 'Mã PIN không khớp';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 24),

                  // Warning box
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quan trọng:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Khi nhập mã PIN này, ứng dụng sẽ:\n'
                                '• Giả vờ đóng và hiện màn hình đen\n'
                                '• Gửi cảnh báo khẩn cấp tới người thân\n'
                                '• Tiếp tục ghi âm và định vị GPS\n'
                                '• Chỉ bạn biết ứng dụng vẫn hoạt động',
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Mã PIN bị ép buộc phải khác hoàn toàn với mã PIN an toàn để tránh nhầm lẫn.',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Tiếp tục',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cannot skip message
                  Center(
                    child: Text(
                      'Bạn không thể bỏ qua bước này',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

