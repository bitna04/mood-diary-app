import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _iconAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    widget.onComplete();
  }

  void _skipOnboarding() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accentPink = isDarkMode ? Colors.pink.shade400 : Colors.pink.shade300;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _iconAnimationController.reset();
              _iconAnimationController.forward();
            },
            children: [
              _buildPage(
                context,
                icon: Icons.edit_note_rounded,
                title: 'Track Your Moods',
                description:
                    'Record how you feel each day. Spot patterns and understand your emotional journey over time.',
                isDarkMode: isDarkMode,
              ),
              _buildPage(
                context,
                icon: Icons.auto_awesome_rounded,
                title: 'AI-Powered Reflections',
                description:
                    'After each entry, receive a personalized reflection. Let AI gently guide your emotional awareness.',
                isDarkMode: isDarkMode,
              ),
              _buildPage(
                context,
                icon: Icons.favorite_rounded,
                title: 'Your Private Safe Space',
                description:
                    'Your diary is protected with biometrics and optional PIN. Your feelings stay yours, always.',
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: _currentPage < 2
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: accentPink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: index == _currentPage ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == _currentPage
                                  ? accentPink
                                  : accentPink.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentPage == 2 ? 'Get Started' : 'Next →',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    final accentPink = isDarkMode ? Colors.pink.shade400 : Colors.pink.shade300;
    final gradientStart = isDarkMode ? const Color(0xFF2A2A2A) : Colors.pink.shade100;
    final gradientEnd = isDarkMode ? const Color(0xFF1F1F1F) : Colors.pink.shade200;

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, gradientEnd],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                DecorativeCircle(
                  size: 200,
                  color: accentPink.withOpacity(0.1),
                  top: 20,
                  left: -50,
                ),
                DecorativeCircle(
                  size: 120,
                  color: accentPink.withOpacity(0.15),
                  bottom: 100,
                  right: -40,
                ),
                DecorativeCircle(
                  size: 80,
                  color: accentPink.withOpacity(0.12),
                  top: 150,
                  right: 20,
                ),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _iconAnimationController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: accentPink.withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 56,
                        color: accentPink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDarkMode ? Color(0xFFBDBDBD) : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

class DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const DecorativeCircle({
    super.key,
    required this.size,
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
