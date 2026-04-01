import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/services/background_task_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/processor_info.dart';
import '../../data/providers/refresh_provider.dart';
import '../../data/providers/supabase_provider.dart';
import '../dashboard/providers/dashboard_provider.dart';
import 'widgets/processor_info_tile.dart';
import 'widgets/processor_map_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const List<Duration> _refreshOptions = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
  ];

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
    final selectedInterval =
        _refreshOptions.contains(interval) ? interval : _refreshOptions[3];
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
                            onRename: () => _showRenameDialog(p),
                            onEditLocation: () =>
                                _showCoordinatesDialog(p),
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

            const SizedBox(height: AppSpacing.xl),

            // Processor map
            Text(
              'Map',
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            processorsAsync.when(
              data: (procs) => ProcessorMapCard(
                processors: procs,
                onProcessorTap: (p) =>
                    context.push('/processor/${p.procId}'),
              ),
              loading: () => Container(
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.soil800,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.leafGreen),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
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
                activeThumbColor: AppColors.leafGreen,
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
              subtitle: _formatInterval(selectedInterval),
              trailing: DropdownButton<Duration>(
                value: selectedInterval,
                dropdownColor: AppColors.soil700,
                underline: const SizedBox.shrink(),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.cream,
                ),
                items: _refreshOptions
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(_formatInterval(d)),
                      ),
                    )
                    .toList(),
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
                activeThumbColor: AppColors.leafGreen,
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

  Future<void> _showRenameDialog(ProcessorInfo processor) async {
    final controller = TextEditingController(text: processor.name ?? '');

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.soil800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Rename Processor',
          style: AppTypography.titleLarge.copyWith(color: AppColors.cream),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              processor.procId,
              style: AppTypography.bodySmall.copyWith(color: AppColors.clay),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: controller,
              autofocus: true,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: 'Enter a name…',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.clay,
                ),
                filled: true,
                fillColor: AppColors.soil700,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(color: AppColors.leafGreen),
                ),
              ),
              onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(color: AppColors.clay),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.leafGreen,
              foregroundColor: AppColors.soil900,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;
    if (!mounted) return;

    try {
      final repo = ref.read(processorRepositoryProvider);
      await repo.updateName(processor.procId, newName);
      if (mounted) {
        ref.invalidate(processorsProvider);
        ref.read(refreshTriggerProvider.notifier).update((s) => s + 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processor renamed to "$newName"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showCoordinatesDialog(ProcessorInfo processor) async {
    final latController =
        TextEditingController(text: processor.latitude ?? '');
    final lngController =
        TextEditingController(text: processor.longitude ?? '');
    var gpsLoading = false;

    final result = await showDialog<({String lat, String lng})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.soil800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'Edit Location',
            style:
                AppTypography.titleLarge.copyWith(color: AppColors.cream),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                processor.displayName,
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.clay),
              ),
              const SizedBox(height: AppSpacing.lg),
              _CoordTextField(
                controller: latController,
                label: 'Latitude',
                hint: '45.7640',
              ),
              const SizedBox(height: AppSpacing.md),
              _CoordTextField(
                controller: lngController,
                label: 'Longitude',
                hint: '4.8357',
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: gpsLoading
                      ? null
                      : () async {
                          setDialogState(() => gpsLoading = true);
                          try {
                            final pos = await _acquirePosition();
                            latController.text =
                                pos.latitude.toStringAsFixed(6);
                            lngController.text =
                                pos.longitude.toStringAsFixed(6);
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('$e')),
                              );
                            }
                          } finally {
                            setDialogState(() => gpsLoading = false);
                          }
                        },
                  icon: gpsLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.leafGreen,
                          ),
                        )
                      : const Icon(PhosphorIconsBold.crosshairSimple),
                  label: Text(
                      gpsLoading ? 'Locating…' : 'Use phone location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.leafGreenLight,
                    side: const BorderSide(color: AppColors.leafGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style:
                    AppTypography.labelLarge.copyWith(color: AppColors.clay),
              ),
            ),
            FilledButton(
              onPressed: () {
                final lat = latController.text.trim();
                final lng = lngController.text.trim();
                if (lat.isEmpty || lng.isEmpty) return;
                if (double.tryParse(lat) == null ||
                    double.tryParse(lng) == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter valid numbers')),
                  );
                  return;
                }
                Navigator.pop(ctx, (lat: lat, lng: lng));
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.leafGreen,
                foregroundColor: AppColors.soil900,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;
    if (!mounted) return;

    try {
      final repo = ref.read(processorRepositoryProvider);
      await repo.updateCoordinates(
          processor.procId, result.lat, result.lng);
      if (mounted) {
        ref.invalidate(processorsProvider);
        ref.read(refreshTriggerProvider.notifier).update((s) => s + 1);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coordinates updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<Position> _acquirePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Enable them in device settings.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied. Enable it in device settings.';
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  String _formatInterval(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    return '${d.inMinutes}m';
  }
}

class _CoordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _CoordTextField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      style: AppTypography.bodyLarge.copyWith(color: AppColors.cream),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.clay),
        hintText: hint,
        hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.soil600),
        filled: true,
        fillColor: AppColors.soil700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.leafGreen),
        ),
      ),
    );
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
