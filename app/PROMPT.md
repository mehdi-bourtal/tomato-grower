# Opus 4.6 Prompt — Tomato Grower Flutter App (Complete Code Generation)

You are a senior Flutter/Dart engineer. Generate the **complete, production-ready** source code for a mobile app called **"Tomato Grower"**. Output **every file** listed in the folder structure below — no placeholders, no TODOs, no stubs. Each file must compile and run.

---

## PROJECT OVERVIEW

**Tomato Grower** monitors tomato cultivations via IoT microprocessors. The microprocessors send sensor data (temperature, humidity, luminosity, pressure, photos) to a Supabase database. This Flutter app fetches and displays that data.

---

## CRITICAL REQUIREMENTS (read before coding)

1. **Data refresh**: fetch ALL data from Supabase when the app launches (in `main.dart` or the dashboard provider initialization), AND set up a **periodic Timer of 10 minutes** that re-fetches all data while the app is in the foreground. Use `WidgetsBindingObserver` to pause the timer when the app goes to background and resume it when the app returns to foreground. Pull-to-refresh on the DashboardScreen also triggers a full refetch.
2. **Null safety**: every Supabase field can be `null`. Models must use nullable types (`double?`, `int?`, `String?`, `DateTime?`). The UI must display a dash `"—"` or a placeholder when a value is `null`. Never let a null crash the app.
3. **Error handling**: wrap every Supabase call in try/catch. On failure, show a non-intrusive `SnackBar` with the error message and keep the last-known data visible (do not clear the UI). Log errors with `debugPrint`. The `error` column from `culture_info` should be displayed in the 6th MetricCard on the dashboard.
4. **Empty states**: if a table returns zero rows, show a dedicated empty-state widget (icon + message) instead of a blank screen.
5. **No Freezed / code generation**: do NOT use `freezed`, `json_serializable`, or any build_runner-dependent packages. Write plain Dart model classes with `factory fromJson(Map<String, dynamic>)` and `Map<String, dynamic> toJson()` methods manually. This keeps the project immediately compilable with no code generation step.
6. **No Lottie/Rive files**: since we don't have animation assets, replace all Lottie/Rive references with **static SVG-like illustrations built with Flutter CustomPaint** or simple **animated Container/Icon compositions** using `flutter_animate`. The splash screen should use a `flutter_animate` sequence (fade + scale on a plant icon) instead of Lottie.
7. **No flutter_map**: replace the map in ProcessorDetailScreen with a static `CachedNetworkImage` using the OpenStreetMap static tile URL: `https://staticmap.openstreetmap.de/staticmap.php?center={lat},{lon}&zoom=14&size=600x300&maptype=mapnik&markers={lat},{lon},lightblue`. This avoids an extra heavy dependency.
8. **Environment variables**: read Supabase credentials from a `.env` file using `flutter_dotenv`. The `.env` file has these keys:
   ```
   SUPABASE_URL=
   SUPABASE_BUCKET=
   SUPABASE_SERVICE_KEY=
   ```
   Use `dotenv.env['SUPABASE_URL']` etc. If any env var is missing, show a fatal error screen at startup.
9. **State management**: use `flutter_riverpod` (with `hooks_riverpod` and `flutter_hooks` if helpful). Create providers for each repository and for UI state (selected processor, selected date range, selected metrics, theme mode).
10. **Routing**: use `go_router`. Define all routes in `app.dart`.
11. **Target platforms**: Android + iOS. No web-specific code needed.

---

## SUPABASE SCHEMA

### Table: `culture_info`
| Column         | Type        | Description                    | Nullable |
|----------------|-------------|--------------------------------|----------|
| `date`         | `timestamp` | When the reading was taken      | NO       |
| `proc_id`      | `uuid`      | Foreign key to `proc_info`      | NO       |
| `temperature`  | `float4`    | Temperature in °C               | YES      |
| `humidity_air`  | `int8`      | Air humidity in %              | YES      |
| `humidity_ground`| `int8`    | Ground humidity in %           | YES      |
| `luminosity`   | `int8`      | Luminosity in lux               | YES      |
| `pressure`     | `int8`      | Atmospheric pressure in Pa      | YES      |
| `error`        | `text`      | Error message from processor    | YES      |

### Table: `tomatos_status`
| Column             | Type        | Description                    | Nullable |
|--------------------|-------------|--------------------------------|----------|
| `date`             | `timestamp` | When the photo was analyzed     | NO       |
| `proc_id`          | `uuid`      | Foreign key to `proc_info`      | NO       |
| `ripe_tomatos`     | `int4`      | Number of ripe tomatoes         | YES      |
| `img_supabase_url` | `text`      | URL path to image in bucket     | YES      |

### Table: `proc_info`
| Column             | Type   | Description                      | Nullable |
|--------------------|--------|----------------------------------|----------|
| `proc_id`          | `uuid` | Primary key                      | NO       |
| `name`             | `text` | Human-readable processor name    | YES      |
| `latitude`         | `text` | GPS latitude                     | YES      |
| `longitude`        | `text` | GPS longitude                    | YES      |
| `watering_volume`  | `int4` | Watering volume in mL            | YES      |
| `cultivation_size` | `int4` | Number of tomato plants          | YES      |

### Supabase queries
- Use `supabase.from('table_name').select()` for reads.
- Order `culture_info` and `tomatos_status` by `date` descending.
- For the dashboard: fetch the latest row per `proc_id` from `culture_info`, fetch the latest row from `tomatos_status`, and fetch all rows from `proc_info`.
- For the history screen: fetch rows from `culture_info` filtered by `proc_id` and a date range, ordered by `date` ascending (for chart plotting).
- For the camera screen: fetch all rows from `tomatos_status` for the selected `proc_id`, ordered by `date` descending.
- To build the full image URL from `img_supabase_url`:
  ```dart
  final imageUrl = Supabase.instance.client.storage
      .from(dotenv.env['SUPABASE_BUCKET']!)
      .getPublicUrl(record.imgSupabaseUrl!);
  ```

---

## DESIGN SYSTEM (implement exactly)

### Colors — `app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Dark theme (primary)
  static const soil900       = Color(0xFF0F1A0F);
  static const soil800       = Color(0xFF1A2B1A);
  static const soil700       = Color(0xFF253825);
  static const soil600       = Color(0xFF34503A);
  static const leafGreen     = Color(0xFF4CAF50);
  static const leafGreenLight= Color(0xFF81C784);
  static const sprout        = Color(0xFFC8E6C9);
  static const tomatoRed     = Color(0xFFE53935);
  static const tomatoOrange  = Color(0xFFFF7043);
  static const sunYellow     = Color(0xFFFFD54F);
  static const cream         = Color(0xFFFFF8E1);
  static const parchment     = Color(0xFFF5F0E1);
  static const clay          = Color(0xFF8D6E63);
  static const water         = Color(0xFF4FC3F7);
  static const waterDark     = Color(0xFF0288D1);

  // Light theme overrides
  static const backgroundLight   = Color(0xFFFBF8F0);
  static const surfaceLight      = Color(0xFFFFFFFF);
  static const textPrimaryLight  = Color(0xFF1B2E1B);
  static const textSecondaryLight= Color(0xFF4E6E4E);
  static const dividerLight      = Color(0xFFD7CFC0);

  // Semantic
  static const healthy  = leafGreen;
  static const warning  = tomatoOrange;
  static const critical = tomatoRed;
  static const info     = water;
  static const inactive = soil600;
}
```

### Typography — `app_typography.dart`

Use `google_fonts` package. Build all `TextStyle` objects using `GoogleFonts.dmSans(...)` and `GoogleFonts.dmMono(...)` with the exact weight/size/height/letterSpacing from this table:

```
Token               Font      Weight  Size  Height  Spacing
displayLarge        DM Sans   w700    32    40      -0.5
displayMedium       DM Sans   w700    24    32      -0.25
titleLarge          DM Sans   w600    20    28       0.0
titleMedium         DM Sans   w600    16    24       0.1
bodyLarge           DM Sans   w400    16    24       0.15
bodyMedium          DM Sans   w400    14    20       0.25
bodySmall           DM Sans   w400    12    16       0.4
labelLarge          DM Sans   w600    14    20       0.1
labelSmall          DM Sans   w500    11    16       0.5
metricValue         DM Mono   w700    28    34      -0.5
metricUnit          DM Mono   w400    14    20       0.0
metricSmall         DM Mono   w500    16    22       0.0
```

### Spacing — `app_spacing.dart`

```dart
class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;
}

class AppRadius {
  static const double sm   = 8;
  static const double md   = 16;
  static const double lg   = 24;
  static const double full = 999;
}
```

### Theme — `app_theme.dart`

Build two `ThemeData` objects (dark and light). Dark is the default.

**Dark ColorScheme:**
```dart
ColorScheme.dark(
  primary: Color(0xFF4CAF50),
  onPrimary: Color(0xFF0F1A0F),
  primaryContainer: Color(0xFF1A2B1A),
  onPrimaryContainer: Color(0xFFC8E6C9),
  secondary: Color(0xFF4FC3F7),
  onSecondary: Color(0xFF0F1A0F),
  secondaryContainer: Color(0xFF0288D1),
  onSecondaryContainer: Color(0xFFE1F5FE),
  error: Color(0xFFE53935),
  onError: Color(0xFFFFF8E1),
  surface: Color(0xFF1A2B1A),
  onSurface: Color(0xFFFFF8E1),
  surfaceContainerHighest: Color(0xFF253825),
  outline: Color(0xFF34503A),
  outlineVariant: Color(0xFF34503A),
)
```

**Light ColorScheme:**
```dart
ColorScheme.light(
  primary: Color(0xFF388E3C),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFC8E6C9),
  onPrimaryContainer: Color(0xFF1B2E1B),
  secondary: Color(0xFF0288D1),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFC62828),
  onError: Color(0xFFFFFFFF),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF1B2E1B),
  surfaceContainerHighest: Color(0xFFF5F0E1),
  outline: Color(0xFFD7CFC0),
)
```

Set the scaffold background to `soil900` (dark) / `backgroundLight` (light). Use `DM Sans` as the default text theme. Cards: no elevation, 1dp border using `outline` color. Buttons: 8dp radius, 48dp height.

### Iconography

Use `phosphor_flutter` package. Mapping:
```
Temperature      → PhosphorIconsBold.thermometerSimple
Air Humidity     → PhosphorIconsBold.drop
Ground Humidity  → PhosphorIconsBold.plant
Luminosity       → PhosphorIconsBold.sun
Pressure         → PhosphorIconsBold.gauge
Ripe Tomato      → PhosphorIconsBold.orangeSlice
Watering         → PhosphorIconsBold.dropHalf
Photo            → PhosphorIconsBold.camera
Error            → PhosphorIconsBold.warning
Processor        → PhosphorIconsBold.cpu
Location         → PhosphorIconsBold.mapPin
Settings         → PhosphorIconsBold.gear
Nav: Home        → PhosphorIconsBold.house
Nav: History     → PhosphorIconsBold.clockCounterClockwise
Nav: Camera      → PhosphorIconsBold.camera
Nav: Settings    → PhosphorIconsBold.gear
```

---

## PACKAGES (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.0
  flutter_riverpod: ^2.6.1
  hooks_riverpod: ^2.6.1
  flutter_hooks: ^0.20.5
  go_router: ^14.8.1
  fl_chart: ^0.70.2
  phosphor_flutter: ^2.1.0
  google_fonts: ^6.2.1
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  flutter_animate: ^4.5.2
  flutter_dotenv: ^5.2.1
  intl: ^0.19.0
  flutter_staggered_grid_view: ^0.7.0

flutter:
  assets:
    - .env
```

---

## FILE STRUCTURE (generate every file)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_theme.dart
│   │   └── app_spacing.dart
│   ├── constants/
│   │   └── supabase_tables.dart
│   └── utils/
│       ├── app_date_utils.dart
│       └── unit_conversion.dart
├── data/
│   ├── models/
│   │   ├── culture_info.dart
│   │   ├── tomato_status.dart
│   │   └── processor_info.dart
│   ├── repositories/
│   │   ├── culture_repository.dart
│   │   ├── tomato_repository.dart
│   │   └── processor_repository.dart
│   └── providers/
│       ├── supabase_provider.dart
│       └── refresh_provider.dart
├── features/
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── widgets/
│   │   │   ├── hero_status_card.dart
│   │   │   ├── metric_card.dart
│   │   │   ├── metric_grid.dart
│   │   │   └── recent_photos_row.dart
│   │   └── providers/
│   │       └── dashboard_provider.dart
│   ├── history/
│   │   ├── history_screen.dart
│   │   ├── widgets/
│   │   │   ├── date_range_selector.dart
│   │   │   ├── metric_line_chart.dart
│   │   │   ├── harvest_bar_chart.dart
│   │   │   └── raw_data_table.dart
│   │   └── providers/
│   │       └── history_provider.dart
│   ├── camera/
│   │   ├── camera_screen.dart
│   │   ├── widgets/
│   │   │   ├── photo_grid.dart
│   │   │   └── photo_viewer.dart
│   │   └── providers/
│   │       └── camera_provider.dart
│   ├── settings/
│   │   ├── settings_screen.dart
│   │   └── widgets/
│   │       └── processor_info_tile.dart
│   ├── processor_detail/
│   │   └── processor_detail_screen.dart
│   └── splash/
│       └── splash_screen.dart
└── shared/
    └── widgets/
        ├── app_shimmer.dart
        ├── status_dot.dart
        └── empty_state.dart
```

Also generate the **`pubspec.yaml`** file (with the packages above) and the **`analysis_options.yaml`** file.

---

## DETAILED FILE SPECIFICATIONS

### `main.dart`
- Load `.env` with `dotenv.load(fileName: ".env")`.
- Validate that `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` are non-empty. If missing, print an error and show a `MaterialApp` with a red error screen.
- Initialize Supabase: `await Supabase.initialize(url: url, anonKey: serviceKey)`.
- Wrap the app in `ProviderScope` from Riverpod.
- Call `runApp(const TomatoGrowerApp())`.

### `app.dart` — `TomatoGrowerApp`
- A `ConsumerWidget`.
- Reads a `themeModeProvider` (StateProvider<ThemeMode>, default `ThemeMode.dark`).
- Returns `MaterialApp.router` with:
  - `routerConfig` from `go_router`.
  - `theme` (light) and `darkTheme` (dark) from `app_theme.dart`.
  - `themeMode` from the provider.
- **GoRouter routes**:
  - `/splash` → `SplashScreen`
  - `/` → `MainShell` (StatefulShellRoute with 4 branches):
    - `/dashboard` → `DashboardScreen`
    - `/history` → `HistoryScreen`
    - `/camera` → `CameraScreen`
    - `/settings` → `SettingsScreen`
  - `/processor/:procId` → `ProcessorDetailScreen`
  - Initial location: `/splash`

### `refresh_provider.dart`
- A `refreshTriggerProvider` (a `StreamProvider` or a `StateProvider<int>` that increments).
- A `RefreshManager` class that:
  - Holds a `Timer.periodic(Duration(minutes: 10), ...)` that invalidates the dashboard/history/camera providers.
  - Implements `WidgetsBindingObserver` to cancel/restart the timer on `AppLifecycleState.paused` / `resumed`.
  - Is initialized once in the `MainShell`'s `initState`.

### `supabase_provider.dart`
- Exposes `supabaseClientProvider` → `Supabase.instance.client`.
- Exposes `supabaseBucketProvider` → `dotenv.env['SUPABASE_BUCKET'] ?? ''`.

### `supabase_tables.dart`
```dart
class SupabaseTables {
  static const cultureInfo = 'culture_info';
  static const tomatosStatus = 'tomatos_status';
  static const procInfo = 'proc_info';
}
```

### Models (plain Dart — NO freezed)

#### `culture_info.dart`
```dart
class CultureInfo {
  final DateTime date;
  final String procId;
  final double? temperature;
  final int? humidityAir;
  final int? humidityGround;
  final int? luminosity;
  final int? pressure;
  final String? error;

  CultureInfo({
    required this.date,
    required this.procId,
    this.temperature,
    this.humidityAir,
    this.humidityGround,
    this.luminosity,
    this.pressure,
    this.error,
  });

  factory CultureInfo.fromJson(Map<String, dynamic> json) {
    return CultureInfo(
      date: DateTime.parse(json['date'] as String),
      procId: json['proc_id'] as String,
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidityAir: json['humidity_air'] as int?,
      humidityGround: json['humidity_ground'] as int?,
      luminosity: json['luminosity'] as int?,
      pressure: json['pressure'] as int?,
      error: json['error'] as String?,
    );
  }
}
```

#### `tomato_status.dart`
```dart
class TomatoStatus {
  final DateTime date;
  final String procId;
  final int? ripeTomatos;
  final String? imgSupabaseUrl;

  TomatoStatus({
    required this.date,
    required this.procId,
    this.ripeTomatos,
    this.imgSupabaseUrl,
  });

  factory TomatoStatus.fromJson(Map<String, dynamic> json) {
    return TomatoStatus(
      date: DateTime.parse(json['date'] as String),
      procId: json['proc_id'] as String,
      ripeTomatos: json['ripe_tomatos'] as int?,
      imgSupabaseUrl: json['img_supabase_url'] as String?,
    );
  }
}
```

#### `processor_info.dart`
```dart
class ProcessorInfo {
  final String procId;
  final String? name;
  final String? latitude;
  final String? longitude;
  final int? wateringVolume;
  final int? cultivationSize;

  ProcessorInfo({
    required this.procId,
    this.name,
    this.latitude,
    this.longitude,
    this.wateringVolume,
    this.cultivationSize,
  });

  factory ProcessorInfo.fromJson(Map<String, dynamic> json) {
    return ProcessorInfo(
      procId: json['proc_id'] as String,
      name: json['name'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      wateringVolume: json['watering_volume'] as int?,
      cultivationSize: json['cultivation_size'] as int?,
    );
  }
}
```

### Repositories

Each repository class takes `SupabaseClient` as a constructor parameter. Every method returns `Future<List<Model>>` or `Future<Model?>` and wraps calls in try/catch, rethrowing as a custom `AppException(String message)` class (define it in `core/utils/`).

#### `culture_repository.dart`
- `fetchLatest(String procId)` → single latest `CultureInfo` for the given processor.
- `fetchHistory(String procId, DateTime from, DateTime to)` → list ordered by date ASC.
- `fetchLatestForAll()` → latest entry per processor (fetch all, group by proc_id, take latest from each group — or use a Supabase RPC if available).

#### `tomato_repository.dart`
- `fetchLatest(String procId)` → single latest `TomatoStatus`.
- `fetchAll(String procId)` → all entries ordered by date DESC.
- `getPublicImageUrl(String path)` → uses `Supabase.instance.client.storage.from(bucket).getPublicUrl(path)`.

#### `processor_repository.dart`
- `fetchAll()` → all processors.
- `fetchById(String procId)` → single processor.

### Providers (Riverpod)

#### `dashboard_provider.dart`
- `selectedProcessorProvider` — `StateProvider<ProcessorInfo?>`, defaults to the first processor.
- `processorsProvider` — `FutureProvider` that fetches all processors on init.
- `latestMetricsProvider` — `FutureProvider.family<CultureInfo?, String>` keyed by procId. Auto-refreshed by the refresh trigger.
- `latestTomatoStatusProvider` — `FutureProvider.family<TomatoStatus?, String>`.
- `recentPhotosProvider` — `FutureProvider.family<List<TomatoStatus>, String>` (latest 5).
- A `dashboardRefreshProvider` that invalidates all the above when called.

#### `history_provider.dart`
- `dateRangeProvider` — `StateProvider<DateTimeRange>`, default last 7 days.
- `selectedMetricsProvider` — `StateProvider<Set<String>>`, default all selected.
- `historyDataProvider` — `FutureProvider` that fetches `culture_info` for the selected processor + date range.
- `harvestDataProvider` — `FutureProvider` that fetches `tomatos_status` for the selected processor + date range.

#### `camera_provider.dart`
- `allPhotosProvider` — `FutureProvider` fetching all `tomatos_status` for the selected processor.

#### `settings_screen.dart` providers (can be inline or separate file)
- `themeModeProvider` — `StateProvider<ThemeMode>`, default dark.
- `temperatureUnitProvider` — `StateProvider<bool>` (true = Celsius, false = Fahrenheit).
- `refreshIntervalProvider` — `StateProvider<Duration>`, default 10 minutes.

### Screens

#### `splash_screen.dart`
- Full `soil900` background.
- Center column: a `PhosphorIconsBold.plant` icon (64dp, leafGreenLight) animated with `flutter_animate`: `.fadeIn(duration: 600.ms).scale(begin: Offset(0.5, 0.5), end: Offset(1, 1), curve: Curves.easeOutBack, duration: 800.ms)`.
- Below: "Tomato Grower" (`displayLarge`, `leafGreenLight`), fading in 200ms after the icon.
- Below: "Cultivate smarter." (`bodyMedium`, `clay`), fading in 400ms after the icon.
- After 2.5 seconds, navigate to `/dashboard` with `context.go('/dashboard')`.

#### `dashboard_screen.dart`
- A `ConsumerStatefulWidget` with `WidgetsBindingObserver`.
- Body: `RefreshIndicator` wrapping a `CustomScrollView` with `SliverList`/`SliverPadding`.
- Sections in order:
  1. Custom header row: "Dashboard" title + processor chip.
  2. `HeroStatusCard` — computes status from latest metrics (all non-null and in range → healthy; any null or out of range → warning; error present → critical).
  3. "Live Metrics" section header + refresh button.
  4. `MetricGrid` — 2-column grid of 6 `MetricCard` widgets.
  5. "Recent Photos" section header.
  6. `RecentPhotosRow` — horizontal `ListView` of `PhotoCard` widgets.
  7. `SizedBox(height: 80)` bottom spacer.
- On init: trigger initial fetch. The refresh timer is managed by `RefreshManager`.

#### `hero_status_card.dart`
- Takes `CultureInfo?`, `TomatoStatus?`, `ProcessorInfo?` as parameters.
- Displays a status icon (plant icon with color based on status), a status message, ripe tomato count, last watering info.
- Two buttons: "Water Now" (primary, currently shows a "Coming soon" SnackBar) and "View Photo" (secondary, navigates to camera tab).
- If all data is null, show a loading shimmer.

#### `metric_card.dart`
- Takes: `String title`, `IconData icon`, `String? value`, `String unit`, `Color metricColor`, `List<double>? sparklineData`, `String? status` (healthy/warning/critical).
- If `value` is null → display `"—"`.
- Sparkline: an `fl_chart` `LineChart` with `LineChartData`, no titles, no grid, 32dp height, 1.5dp stroke in `metricColor`, gradient fill below.
- Status dot: 8dp circle, pulsing animation if critical.

#### `metric_grid.dart`
- Builds 6 `MetricCard` widgets in a `Wrap` or `GridView.count(crossAxisCount: 2)`.
- Cards: Temperature (°C), Air Humidity (%), Ground Humidity (%), Luminosity (lux), Pressure (Pa), Error (text).
- The Error card: if no error → green checkmark + "All clear"; if error → red warning icon + error text truncated to 2 lines.

#### `history_screen.dart`
- `DateRangeSelector` at top (chips: 24h, 7d, 30d, Custom).
- Metric toggle chips row.
- `MetricLineChart` card (240dp).
- `HarvestBarChart` card (160dp).
- `RawDataTable` expandable section.
- All data fetched via `historyDataProvider`.

#### `metric_line_chart.dart`
- Uses `fl_chart` `LineChart`.
- One `LineChartBarData` per selected metric, colored per the mapping:
  - temperature → tomatoOrange, humidity_air → water, humidity_ground → leafGreen, luminosity → sunYellow, pressure → clay.
- Touch tooltip: soil700 bg, cream text, shows all visible metric values at that date.
- X axis: dates formatted with `intl` (e.g., "Mar 28").
- Y axis: auto-scaled per visible data.
- Handle empty data: show `EmptyState` widget.

#### `harvest_bar_chart.dart`
- Uses `fl_chart` `BarChart`.
- One bar per day/data point, tomatoRed fill, ghost bars in soil700 behind.
- Handle empty data: show `EmptyState` widget.

#### `camera_screen.dart`
- Title: "Gallery".
- Fetches `allPhotosProvider`.
- If empty → `EmptyState` with camera icon.
- If loaded → 2-column `MasonryGridView` of `PhotoCard` widgets.
- Tap on photo → opens `PhotoViewer` (full-screen dialog with `InteractiveViewer` for pinch-to-zoom, dark scrim, PageView for swipe between photos, ripe count overlay at bottom).

#### `settings_screen.dart`
- Processor list → `ProcessorInfoTile` for each.
- Theme toggle (`SwitchListTile`).
- Temperature unit (`SegmentedButton`).
- Refresh interval (`DropdownButton`).
- About section with version.

#### `processor_detail_screen.dart`
- AppBar with back arrow + processor name.
- Static map image via `CachedNetworkImage` (OpenStreetMap URL with lat/lon).
- Info key-value list (name, coordinates, watering volume, cultivation size).
- Recent 5 metrics from `culture_info` in a vertical timeline list.
- "Water Now" button (shows "Coming soon" SnackBar).

### Shared widgets

#### `app_shimmer.dart`
- A reusable shimmer loading placeholder. Takes `width`, `height`, `borderRadius`. Uses the `shimmer` package with base color `soil700` and highlight color `soil600`.

#### `status_dot.dart`
- An 8dp circle with color based on status string. If status is "critical", applies a pulsing scale animation (1.0 → 1.3 → 1.0, 1500ms, infinite repeat) using `flutter_animate`.

#### `empty_state.dart`
- Takes `IconData icon`, `String title`, `String subtitle`.
- Centers the icon (48dp, clay), title (`titleLarge`, parchment), subtitle (`bodyMedium`, clay) vertically.

---

## IMPORTANT IMPLEMENTATION NOTES

1. **Sparkline data**: for each metric on the dashboard, also fetch the last 24 hours of data (up to 24 points) from `culture_info` to feed the sparkline. Create a `sparklineDataProvider` that returns `Map<String, List<double>>` keyed by metric name. If fewer than 2 data points, hide the sparkline.

2. **Health status computation**: define a function `computeHealthStatus(CultureInfo? metrics, String? error)` in `core/utils/`:
   - If `metrics` is null → `"inactive"`
   - If `error` is non-null and non-empty → `"critical"`
   - If temperature is outside 10–40°C, or humidity_air outside 30–90%, or humidity_ground outside 20–80% → `"warning"`
   - Otherwise → `"healthy"`

3. **Number formatting**: use `intl` `NumberFormat` to format metric values (e.g., `12,450` lux). Temperature to 1 decimal. Humidity/luminosity/pressure as integers with thousands separator.

4. **Date formatting**: use `intl` `DateFormat`. Timestamps: "Mar 28, 2026 · 14:32". Chart X-axis: "Mar 28", "14:00" depending on range.

5. **Image loading**: always use `CachedNetworkImage` with a `shimmer` placeholder and an error widget (broken image icon).

6. **Responsive**: use `LayoutBuilder` or `MediaQuery` to determine column count for the MetricGrid: 2 on phones, 3 on tablets (>600dp), 4 on large tablets (>840dp).

7. **Theme switching**: toggling the theme in Settings should immediately apply (the provider is watched by `MaterialApp.router`).

---

## OUTPUT FORMAT

Output every file with its full path as a header, followed by the complete Dart (or YAML) source code. Do not skip any file. Do not use `// ...` or `// TODO`. Every file must be complete and functional.

Example output structure:
```
### `pubspec.yaml`
\`\`\`yaml
(complete content)
\`\`\`

### `lib/main.dart`
\`\`\`dart
(complete content)
\`\`\`

### `lib/app.dart`
\`\`\`dart
(complete content)
\`\`\`
(... continue for every file ...)
```

Generate all files now.
