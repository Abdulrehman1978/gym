import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:ironlog/features/home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_complete') ?? false;
    if (completed && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _OnboardingPage(
                    icon: Icons.fitness_center,
                    title: 'Welcome to IronLog',
                    body: 'Your personal gym tracker.\nBuilt for YOUR gym.\nWorks offline. Always.',
                    buttonText: 'Let\u2019s Start \u2192',
                    onPressed: _onNext,
                  ),
                  _OnboardingPage(
                    icon: Icons.calendar_month,
                    title: 'Your 6-Day Program',
                    body: 'Push \u2192 Pull \u2192 Legs \u2192 Push \u2192 Pull \u2192 Legs\nEvery exercise matched to your gym equipment.\nEvery workout pre-planned for you.',
                    buttonText: 'Got it \u2192',
                    onPressed: _onNext,
                  ),
                  _OnboardingPage(
                    icon: Icons.menu_book,
                    title: 'Learn Correct Form',
                    body: 'Every exercise has a full animation\nand detailed form guide.\nWatch before you lift.',
                    buttonText: 'Next \u2192',
                    onPressed: _onNext,
                  ),
                  _OnboardingPage(
                    icon: Icons.trending_up,
                    title: 'Track Your Progress',
                    body: 'Log your weights after every set.\nSee your strength grow week by week.\nThe app tells you when to add weight.',
                    buttonText: 'Next \u2192',
                    onPressed: _onNext,
                  ),
                  _OnboardingPage(
                    icon: Icons.wifi_off,
                    title: 'Works 100% Offline',
                    body: 'Everything works at the gym\nwith no internet.\nAI analysis syncs when you get home.',
                    buttonText: 'START MY JOURNEY \u{1F4AA}',
                    onPressed: _completeOnboarding,
                  ),
                ],
              ),
            ),
            _buildDots(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.textMuted.withAlpha(80),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String buttonText;
  final VoidCallback onPressed;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(icon, size: 80, color: AppColors.primary),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
