import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'data/providers/refresh_provider.dart';
import 'features/camera/camera_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/history/history_screen.dart';
import 'features/processor_detail/processor_detail_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (_, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/camera',
            pageBuilder: (_, state) => const NoTransitionPage(
              child: CameraScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/processor/:procId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => ProcessorDetailScreen(
          procId: state.pathParameters['procId']!,
        ),
      ),
    ],
  );
});

class TomatoGrowerApp extends ConsumerWidget {
  const TomatoGrowerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'Tomato Grower',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  RefreshManager? _refreshManager;

  static const _tabs = ['/dashboard', '/history', '/camera', '/settings'];

  int get _currentIndex {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _tabs.indexWhere((t) => location.startsWith(t));
    return idx >= 0 ? idx : 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshManager = RefreshManager(ref);
      _refreshManager!.start();
    });
  }

  @override
  void dispose() {
    _refreshManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // React to interval changes from settings
    ref.listen(refreshIntervalProvider, (_, next) {
      _refreshManager?.updateInterval(next);
    });

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.soil800,
          border: Border(
            top: BorderSide(color: AppColors.soil600, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: PhosphorIconsBold.house,
                  label: 'Home',
                  active: _currentIndex == 0,
                  onTap: () => context.go('/dashboard'),
                ),
                _NavItem(
                  icon: PhosphorIconsBold.clockCounterClockwise,
                  label: 'History',
                  active: _currentIndex == 1,
                  onTap: () => context.go('/history'),
                ),
                _NavItem(
                  icon: PhosphorIconsBold.camera,
                  label: 'Camera',
                  active: _currentIndex == 2,
                  onTap: () => context.go('/camera'),
                ),
                _NavItem(
                  icon: PhosphorIconsBold.gear,
                  label: 'Settings',
                  active: _currentIndex == 3,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.leafGreen.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(
                icon,
                size: 24,
                color: active ? AppColors.leafGreen : AppColors.clay,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: active ? AppColors.leafGreen : AppColors.clay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
