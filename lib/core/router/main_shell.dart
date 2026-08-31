import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import 'app_routes.dart';

/// The persistent bottom-navigation shell that wraps the main tabs.
/// The Staff tab is only shown for organisation accounts.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOrg = ref.watch(isOrgAccountProvider);
    final location = GoRouterState.of(context).matchedLocation;

    // Tabs visible to everyone
    final baseTabs = [
      _Tab(AppRoutes.home, AppStrings.navHome, Icons.grid_view_outlined,
          Icons.grid_view_rounded),
      _Tab(AppRoutes.call, AppStrings.navCall, Icons.phone_outlined,
          Icons.phone_rounded),
      _Tab(AppRoutes.voices, AppStrings.navVoices, Icons.mic_none_rounded,
          Icons.mic_rounded),
      _Tab(AppRoutes.billing, AppStrings.navBilling, Icons.credit_card_outlined,
          Icons.credit_card_rounded),
    ];

    // Staff tab only for org accounts
    final tabs = isOrg
        ? [
            ...baseTabs,
            _Tab(AppRoutes.staff, AppStrings.navStaff, Icons.badge_outlined,
                Icons.badge_rounded)
          ]
        : baseTabs;

    int currentIndex = 0;
    for (var i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].route)) {
        currentIndex = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == currentIndex) return;
            context.go(tabs[index].route);
          },
          items: tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Icon(t.icon),
                    activeIcon: Icon(t.activeIcon),
                    label: t.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.route, this.label, this.icon, this.activeIcon);
  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}
