import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.family_restroom,
      title: 'Secure Family Governance',
      description: 'Build a strong foundation for your family with structured governance and clear roles for every member.',
      color: const Color(0xFF8B5CF6),
    ),
    OnboardingSlide(
      icon: Icons.description_outlined,
      title: 'Living Constitution',
      description: 'Create and maintain your family constitution that evolves with your values and adapts to changing needs.',
      color: const Color(0xFF3B82F6),
    ),
    OnboardingSlide(
      icon: Icons.trending_up,
      title: 'Generational Wealth',
      description: 'Make informed decisions together to preserve and grow your family legacy across generations.',
      color: const Color(0xFF10B981),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    await ref.read(authStateProvider.notifier).completeOnboarding();
    if (mounted) {
      context.router.replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    return Scaffold(
      backgroundColor: RelunaTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AdaptiveTextButton(
                  text: 'Skip',
                  onPressed: _completeOnboarding,
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: slide.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 80,
                            color: slide.color,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: RelunaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: RelunaTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: _slides.length,
              effect: WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                spacing: 12,
                dotColor: RelunaTheme.divider,
                activeDotColor: RelunaTheme.accentColor,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: _currentPage == _slides.length - 1
                    ? AdaptiveButton(
                        text: 'Get Started',
                        onPressed: _completeOnboarding,
                      )
                    : AdaptiveButton(
                        text: 'Next',
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
              ),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
