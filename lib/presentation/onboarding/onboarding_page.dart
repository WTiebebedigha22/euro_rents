import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/colors.dart';
import '../onboarding/onboarding_view_model.dart';
import '../auth/login_page.dart'; // Redirect after onboarding

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  final OnboardingViewModel _viewModel = OnboardingViewModel();
  bool isLastPage = false;
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding.jpg",
      "title": "Easy Car Rentals",
      "description": "Find and book cars quickly with just a few taps."
    },
    {
      "image": "assets/images/onboarding2.jpg",
      "title": "Wide Selection",
      "description": "Choose from a variety of vehicles that suit your needs."
    },
    {
      "image": "assets/images/onboarding3.jpg",
      "title": "Secure Payments",
      "description": "Pay safely and enjoy your ride with peace of mind."
    },
  ];

  void _finishOnboarding() async {
    await _viewModel.setSeenOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with background + overlay + animated bottom text
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
                isLastPage = index == onboardingData.length - 1;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              final data = onboardingData[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Image.asset(
                    data["image"]!,
                    fit: BoxFit.cover,
                  ),

                  // Dark overlay
                  Container(
                    color: Colors.black.withOpacity(0.55),
                  ),

                  // Animated text content at bottom
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey<int>(currentPage),
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            data["title"]!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data["description"]!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: onboardingData.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white54,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        "Skip",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    isLastPage
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _finishOnboarding,
                            child: const Text("Get Started"),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              _controller.nextPage(
                                duration:
                                    const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text("Next"),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
