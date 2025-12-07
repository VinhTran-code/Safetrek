// lib/features/auth/presentation/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:safetrek_app/models/onboarding_page_content.dart';
import 'package:safetrek_app/utils/app_routes.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageContent> pages = [
    OnboardingPageContent(
      image: 'assets/images/onboarding_1.png',
      title: ' Không Bao Giờ Phải Đi Một Mình',
      description:
      'SafeTrek là vệ sĩ ảo âm thầm theo dõi từng bước chân của bạn 24/7. Dù là đêm khuya hay đường vắng, bạn luôn có người đồng hành.',
    ),
    OnboardingPageContent(
      image: 'assets/images/onboarding_2.png',
      title: ' Nếu Bạn Không Thể Gọi Cứu Hộ...',
      description:
      '...Chúng tôi sẽ làm thay bạn. Đặt hẹn giờ cho chuyến đi, nếu bạn không xác nhận an toàn khi hết giờ, SafeTrek sẽ tự động gửi vị trí và báo động cho người thân.',
    ),
    OnboardingPageContent(
      image: 'assets/images/onboarding_3.png',
      title: 'Lớp Bảo Vệ Vô Hình',
      description:
      'Bị ép buộc tắt ứng dụng? Hãy nhập Mã PIN Giả. Ứng dụng sẽ giả vờ tắt nhưng thực chất vẫn đang âm thầm gửi tín hiệu cầu cứu khẩn cấp.',
    ),
  ];

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        pages[index].image,
                        height: 250,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        pages[index].title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pages[index].description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == pages.length - 1) {
                        _navigateToLogin();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(_currentPage == pages.length - 1 ? 'BẮT ĐẦU' : 'TIẾP THEO'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




