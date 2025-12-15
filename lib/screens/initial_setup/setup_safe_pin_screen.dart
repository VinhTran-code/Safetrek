import 'package:flutter/material.dart';
import 'package:safetrek_app/screens/initial_setup/setup_duress_pin_screen.dart';

/// Bước 1: Thiết lập mã PIN an toàn
/// User phải nhập và xác nhận PIN, không thể bỏ qua
class SetupSafePinScreen extends StatefulWidget {
  const SetupSafePinScreen({super.key});

  @override
  State<SetupSafePinScreen> createState() => _SetupSafePinScreenState();
}

class _SetupSafePinScreenState extends State<SetupSafePinScreen> {
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
    return null;
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Lưu PIN an toàn vào secure storage
    // await SecureStorage.saveSafePin(_pinController.text);

    setState(() => _saving = false);

    if (mounted) {
      // Chuyển sang bước 2: Setup PIN bị ép buộc
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SetupDuressPinScreen(
            safePinToCompare: _pinController.text, // Truyền để so sánh không trùng
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Không cho phép back
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bước 1/3'),
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
                    value: 1 / 3,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
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
                    'Tạo mã PIN an toàn',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  const Text(
                    'Mã PIN này sẽ được sử dụng để mở khóa ứng dụng trong tình huống bình thường. Bạn cần nhập đúng 4 chữ số.',
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
                      labelText: 'Mã PIN an toàn',
                      hintText: 'Nhập đúng 4 chữ số',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.green),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
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
                      prefixIcon: const Icon(Icons.lock, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
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

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.tips_and_updates_outlined, color: Colors.blue.shade700, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mẹo an toàn:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Không dùng PIN dễ đoán (1234, 0000)\n'
                                '• Không chia sẻ PIN với người khác\n'
                                '• Ghi nhớ PIN, không lưu ở nơi dễ thấy',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
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

                  const SizedBox(height: 32),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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

