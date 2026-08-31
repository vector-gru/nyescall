import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
import '../painters/onboarding_painters.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.buildPainter,
  });

  final String title;
  final String body;

  /// Factory that produces the CustomPainter for the current animation value.
  final CustomPainter Function(double progress) buildPainter;
}

final _pages = <_OnboardingPage>[
  _OnboardingPage(
    title: AppStrings.onboarding1Title,
    body: AppStrings.onboarding1Body,
    buildPainter: (p) => GlobeLanguagePainter(progress: p),
  ),
  _OnboardingPage(
    title: AppStrings.onboarding2Title,
    body: AppStrings.onboarding2Body,
    buildPainter: (p) => VoiceWavePainter(progress: p),
  ),
  _OnboardingPage(
    title: AppStrings.onboarding3Title,
    body: AppStrings.onboarding3Body,
    buildPainter: (p) => TrialCalendarPainter(progress: p),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  // One looping animation controller per page drives the painter's progress.
  late final List<AnimationController> _animControllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _animControllers = List.generate(
      _pages.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2800),
      )..repeat(),
    );
    _anims = _animControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeInOut))
        .toList();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _animControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  Future<void> _markDoneAndNavigate() async {
    // Persist for future app launches.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, true);
    // Update the in-memory provider so the router redirect sees true
    // synchronously and does not bounce back to /onboarding.
    ref.read(onboardingDoneProvider.notifier).state = true;
    if (mounted) context.go(AppRoutes.landing);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _markDoneAndNavigate();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ───────────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: AnimatedOpacity(
                  opacity: isLast ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: isLast ? null : _markDoneAndNavigate,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                    ),
                    child: Text(
                      AppStrings.onboardingSkip,
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _PageContent(
                  page: _pages[i],
                  anim: _anims[i],
                ),
              ),
            ),

            // ── Bottom controls ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                children: [
                  // Dot indicators
                  _DotIndicator(
                    count: _pages.length,
                    current: _currentPage,
                  ),

                  const SizedBox(height: 24),

                  // CTA button
                  NyButton(
                    label: isLast
                        ? AppStrings.onboardingGetStarted
                        : AppStrings.onboardingNext,
                    onPressed: _nextPage,
                  )
                      .animate(key: ValueKey(isLast))
                      .fadeIn(duration: 200.ms)
                      .slideY(begin: 0.05, end: 0, duration: 200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page content
// ─────────────────────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page, required this.anim});

  final _OnboardingPage page;
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // ── Illustration ───────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, __) => CustomPaint(
                painter: page.buildPainter(anim.value),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // ── Text block ─────────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium,
                )
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 80.ms)
                    .slideY(begin: 0.08, end: 0, duration: 350.ms),
                const SizedBox(height: 12),
                Text(
                  page.body,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary, height: 1.6),
                )
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 160.ms)
                    .slideY(begin: 0.08, end: 0, duration: 350.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dot indicator
// ─────────────────────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
