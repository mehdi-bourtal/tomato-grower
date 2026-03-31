import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/services/background_task_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../dashboard/providers/dashboard_provider.dart';
import 'widgets/processor_info_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final enabled = await BackgroundTaskService.getNotificationsEnabled();
    if (mounted) {
      ref.read(notificationsEnabledProvider.notifier).state = enabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final processorsAsync = ref.watch(processorsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final celsius = ref.watch(temperatureUnitProvider);
    final interval = ref.watch(refreshIntervalProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.soil900,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            Text(
              'Settings',
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Processors section
            Text(
              'Processors',
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            processorsAsync.when(
              data: (procs) => Column(
                children: procs
                    .map((p) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: ProcessorInfoTile(
                            processor: p,
                            onTap: () =>
                                context.push('/processor/${p.procId}'),
                          ),
                        ))
                    .toList(),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.leafGreen),
              ),
              error: (e, _) => Text(
                'Error: $e',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.tomatoRed,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Preferences section
            Text(
              'Preferences',
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Theme toggle
            _SettingsTile(
              icon: PhosphorIconsBold.moon,
              title: 'Dark Mode',
              subtitle: themeMode == ThemeMode.dark ? 'On' : 'Off',
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                activeColor: AppColors.leafGreen,
                onChanged: (v) {
                  ref.read(themeModeProvider.notifier).state =
                      v ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
            const Divider(indent: 56, color: AppColors.soil600, height: 1),

            // Temperature unit
            _SettingsTile(
              icon: PhosphorIconsBold.thermometerSimple,
              title: 'Temperature Unit',
              subtitle: celsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
              trailing: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('°C')),
                  ButtonSegment(value: false, label: Text('°F')),
                ],
                selected: {celsius},
                onSelectionChanged: (val) {
                  ref.read(temperatureUnitProvider.notifier).state =
                      val.first;
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.leafGreen,
                  selectedForegroundColor: AppColors.soil900,
                  foregroundColor: AppColors.parchment,
                ),
              ),
            ),
            const Divider(indent: 56, color: AppColors.soil600, height: 1),

            // Refresh interval
            _SettingsTile(
              icon: PhosphorIconsBold.arrowClockwise,
              title: 'Refresh Interval',
              subtitle: _formatInterval(interval),
              trailing: DropdownButton<Duration>(
                value: interval,
                dropdownColor: AppColors.soil700,
                underline: const SizedBox.shrink(),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.cream,
                ),
                items: const [
                  DropdownMenuItem(
                    value: Duration(seconds: 30),
                    child: Text('30s'),
                  ),
                  DropdownMenuItem(
                    value: Duration(minutes: 1),
                    child: Text('1m'),
                  ),
                  DropdownMenuItem(
                    value: Duration(minutes: 5),
                    child: Text('5m'),
                  ),
                  DropdownMenuItem(
                    value: Duration(minutes: 15),
                    child: Text('15m'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(refreshIntervalProvider.notifier).state = v;
                  }
                },
              ),
            ),
            const Divider(indent: 56, color: AppColors.soil600, height: 1),

            // Ripe tomato notifications
            _SettingsTile(
              icon: PhosphorIconsBold.bell,
              title: 'Ripe Tomato Alerts',
              subtitle: notificationsEnabled
                  ? 'Daily check for ripe tomatoes'
                  : 'Disabled',
              trailing: Switch(
                value: notificationsEnabled,
                activeColor: AppColors.leafGreen,
                onChanged: (v) async {
                  ref.read(notificationsEnabledProvider.notifier).state = v;
                  await BackgroundTaskService.setNotificationsEnabled(v);
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // About section
            Center(
              child: Column(
                children: [
                  Text(
                    'Tomato Grower v1.0.0',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.clay,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Made with 🌱',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.clay,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _formatInterval(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    return '${d.inMinutes}m';
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.leafGreenLight),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.cream,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.clay,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
