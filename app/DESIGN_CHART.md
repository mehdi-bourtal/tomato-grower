# Tomato Grower — Design Chart

> A premium, nature-oriented design system for a smart tomato cultivation monitor.
> Every value is Flutter-ready. Implement this chart as the single source of truth.

---

## 1. Design Philosophy

| Principle | Description |
|---|---|
| **Organic Premium** | Soft shapes, earthy tones, generous whitespace. The app should feel like opening a greenhouse journal crafted by a botanist. |
| **Data as Nature** | Charts and metrics are styled to look like living things — growth curves, pulsing indicators, leaf-shaped badges. |
| **Glanceable** | The dashboard must communicate plant health in < 2 seconds via color-coded status and a single hero illustration. |
| **Dark Earth Mode** | Dark mode is the *primary* theme — rich dark soil tones with luminous green accents. Light mode is warm parchment. |

---

## 2. Color Palette

### 2.1 Core Palette (Dark Theme — Primary)

```
Name                  Hex        RGB                 Usage
──────────────────────────────────────────────────────────────────
soil900               #0F1A0F    (15, 26, 15)        Scaffold background
soil800               #1A2B1A    (26, 43, 26)        Card backgrounds
soil700               #253825    (37, 56, 37)        Elevated surfaces / Sidebar
soil600               #34503A    (52, 80, 58)        Dividers / inactive borders
leafGreen             #4CAF50    (76, 175, 80)       Primary action / healthy status
leafGreenLight        #81C784    (129, 199, 132)     Primary text on dark / icon highlights
sprout                #C8E6C9    (200, 230, 201)     Badges / subtle highlights
tomatoRed             #E53935    (229, 57, 53)       Alerts / ripe tomato count / destructive
tomatoOrange          #FF7043    (255, 112, 66)      Warnings / semi-ripe indicators
sunYellow             #FFD54F    (255, 213, 79)      Luminosity accent / stars
cream                 #FFF8E1    (255, 248, 225)     Primary text on dark backgrounds
parchment             #F5F0E1    (245, 240, 225)     Secondary text on dark
clay                  #8D6E63    (141, 110, 99)      Tertiary text / timestamps
water                 #4FC3F7    (79, 195, 247)      Watering / humidity accent
waterDark             #0288D1    (2, 136, 209)       Watering active state
```

### 2.2 Light Theme Override

```
Name                  Hex        Usage
──────────────────────────────────────────────────────────────────
backgroundLight       #FBF8F0    Scaffold background (warm parchment)
surfaceLight          #FFFFFF    Card backgrounds
textPrimaryLight      #1B2E1B    Headings / primary text
textSecondaryLight    #4E6E4E    Body text
dividerLight          #D7CFC0    Dividers
```

### 2.3 Semantic Colors

```
Status        Dark Theme Hex   Light Theme Hex   Meaning
──────────────────────────────────────────────────────────────────
healthy       #4CAF50          #388E3C           All metrics nominal
warning       #FF7043          #E65100           One metric out of range
critical      #E53935          #C62828           Multiple metrics critical / error
info          #4FC3F7          #0288D1           Informational / watering events
inactive      #34503A          #D7CFC0           Offline / no data
```

### 2.4 Gradient Definitions

```
Name              Colors (top → bottom)           Usage
──────────────────────────────────────────────────────────────────
heroGradient      soil900 → soil800               Dashboard header background
cardGlow          leafGreen 12% → transparent     Healthy card glow overlay
sunriseBanner     sunYellow 20% → tomatoOrange 8% → transparent   Luminosity widget bg
waterFlow         water 30% → waterDark 10%       Watering animation overlay
```

---

## 3. Typography

Font family: **`Google Fonts — DM Sans`** (headings + body) paired with **`Google Fonts — DM Mono`** (data values / metrics).

```
Token               Font          Weight     Size   Height  Spacing  Usage
────────────────────────────────────────────────────────────────────────────
displayLarge        DM Sans       700        32 sp  40 sp   -0.5     Screen titles
displayMedium       DM Sans       700        24 sp  32 sp   -0.25    Section headers
titleLarge          DM Sans       600        20 sp  28 sp    0.0     Card titles
titleMedium         DM Sans       600        16 sp  24 sp    0.1     Subsection titles
bodyLarge           DM Sans       400        16 sp  24 sp    0.15    Descriptions / paragraphs
bodyMedium          DM Sans       400        14 sp  20 sp    0.25    Secondary descriptions
bodySmall           DM Sans       400        12 sp  16 sp    0.4     Captions / timestamps
labelLarge          DM Sans       600        14 sp  20 sp    0.1     Button labels
labelSmall          DM Sans       500        11 sp  16 sp    0.5     Badge text / chip labels
metricValue         DM Mono       700        28 sp  34 sp   -0.5    Big data number (e.g. "23.4°C")
metricUnit          DM Mono       400        14 sp  20 sp    0.0    Unit label (e.g. "°C")
metricSmall         DM Mono       500        16 sp  22 sp    0.0    Inline data values
```

---

## 4. Spacing & Layout

### 4.1 Spacing Scale (multiples of 4)

```
Token     Value    Usage
────────────────────────────────
xs        4 dp     Inline icon gap
sm        8 dp     Between label and value
md        12 dp    Card inner padding (compact)
lg        16 dp    Card inner padding (standard)
xl        24 dp    Between cards / sections
xxl       32 dp    Screen edge padding (horizontal)
xxxl      48 dp    Section separator vertical
```

### 4.2 Border Radius

```
Token         Value     Usage
────────────────────────────────
radiusSm      8 dp      Chips / badges / small buttons
radiusMd      16 dp     Cards / dialogs
radiusLg      24 dp     Bottom sheets / hero cards
radiusFull    999 dp    Circular avatars / FAB
```

### 4.3 Elevation & Shadows (Dark Theme)

Cards use **no Material elevation**. Instead use a subtle **1 dp border** of `soil600` and an optional `leafGreen` glow for active/healthy states:

```
Card border:          Border(soil600, 1.0)
Active card glow:     BoxShadow(color: leafGreen.withOpacity(0.08), blurRadius: 24, spreadRadius: 4)
Floating action:      BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))
```

---

## 5. Iconography

Use **custom nature-themed** icons from the **`Phosphor Icons`** package (`phosphor_flutter`).

```
Concept              Icon Name (Phosphor)         Fallback (Material)
────────────────────────────────────────────────────────────────────
Temperature          PhosphorIcons.thermometerSimple   Icons.thermostat
Air Humidity         PhosphorIcons.drop                Icons.water_drop
Ground Humidity      PhosphorIcons.plant               Icons.grass
Luminosity           PhosphorIcons.sun                 Icons.wb_sunny
Pressure             PhosphorIcons.gauge               Icons.speed
Tomato (ripe)        PhosphorIcons.orange_slice        Icons.circle (tomatoRed)
Watering             PhosphorIcons.dropHalf            Icons.opacity
Photo                PhosphorIcons.camera              Icons.camera_alt
Error                PhosphorIcons.warning             Icons.error_outline
Processor            PhosphorIcons.cpu                 Icons.memory
Location             PhosphorIcons.mapPin              Icons.location_on
Settings             PhosphorIcons.gear                Icons.settings
Calendar             PhosphorIcons.calendarBlank       Icons.calendar_today
Refresh              PhosphorIcons.arrowClockwise      Icons.refresh
Navigation: Home     PhosphorIcons.house               Icons.home
Navigation: History  PhosphorIcons.clockCounterClockwise  Icons.history
Navigation: Camera   PhosphorIcons.camera              Icons.camera
Navigation: Settings PhosphorIcons.gear                Icons.settings
```

Icon sizing: `20 dp` in nav, `24 dp` in cards, `32 dp` in hero/empty states, `48 dp` in onboarding.

---

## 6. Component Specifications

### 6.1 MetricCard (reusable)

A card displaying a single sensor metric. Used in a grid on the dashboard.

```
┌──────────────────────────────────┐
│  ☀  Luminosity          ● GOOD  │  ← icon (24dp, leafGreenLight) + title (titleMedium, cream) + status dot
│                                  │
│        12,450                    │  ← value (metricValue, cream)
│          lux                     │  ← unit  (metricUnit, clay)
│                                  │
│  ┄┄┄┄┄┄ mini sparkline ┄┄┄┄┄┄  │  ← 24h trend, 32dp tall, leafGreen stroke
└──────────────────────────────────┘

Background:    soil800
Border:        soil600, 1 dp
Border radius: radiusMd (16 dp)
Padding:       lg (16 dp)
Grid:          2 columns, xl (24 dp) gap
Status dot:    8 dp circle — healthy/warning/critical color
Mini sparkline: fl_chart LineChart, no axis labels, 1.5 dp stroke, gradient fill below
```

### 6.2 HeroStatusCard

A large card at the top of the dashboard summarizing overall plant health.

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ╭─────╮                                                │
│  │     │  ← Tomato plant illustration (Lottie or SVG)   │
│  │ 🌱  │     animated: gentle sway                      │
│  ╰─────╯                                                │
│                                                         │
│  Your tomatoes are thriving!                            │  ← displayMedium, cream
│  3 ripe · 12 growing · Last watered 2h ago             │  ← bodyMedium, parchment
│                                                         │
│  ┌───────────┐  ┌────────────┐                          │
│  │ Water Now  │  │ View Photo │                          │  ← Buttons
│  └───────────┘  └────────────┘                          │
└─────────────────────────────────────────────────────────┘

Background:    heroGradient (soil900 → soil800)
Border:        soil600, 1 dp
Border radius: radiusLg (24 dp)
Padding:       xl (24 dp)
Status text dynamically changes:
  - healthy → "Your tomatoes are thriving!"  (leafGreenLight)
  - warning → "Needs attention"              (tomatoOrange)
  - critical → "Urgent care needed!"         (tomatoRed)
```

### 6.3 Buttons

#### Primary Button (Filled)
```
Background:    leafGreen
Text:          soil900, labelLarge
Border radius: radiusSm (8 dp)
Height:        48 dp
Padding H:     xl (24 dp)
Hover/Press:   leafGreen darkened 10%
Disabled:      soil600 background, clay text
```

#### Secondary Button (Outlined)
```
Background:    transparent
Border:        leafGreen, 1.5 dp
Text:          leafGreenLight, labelLarge
Border radius: radiusSm (8 dp)
Height:        48 dp
Hover/Press:   leafGreen.withOpacity(0.08) fill
```

#### Danger Button
```
Background:    tomatoRed
Text:          cream, labelLarge
Same dimensions as Primary
```

### 6.4 BottomNavigationBar

```
Style:         Custom — no Material elevation
Background:    soil800
Height:        64 dp + safe area
Items:         4 (Home, History, Camera, Settings)
Active icon:   leafGreen, 24 dp
Active label:  leafGreen, labelSmall
Inactive icon: clay, 24 dp
Inactive label: clay, labelSmall
Indicator:     Pill shape behind active icon, leafGreen.withOpacity(0.12), radiusFull
```

### 6.5 Charts (fl_chart package)

#### Line Chart (History Screen)
```
Background:       transparent (on soil800 card)
Grid lines:       soil600, 0.5 dp, dashed
X-axis labels:    bodySmall, clay (dates)
Y-axis labels:    bodySmall, clay (values)
Line stroke:      2 dp
Line color:       per-metric semantic color (see below)
Fill below:       same color at 10% opacity
Touch tooltip:    soil700 background, radiusSm, cream text
Dot on touch:     6 dp, white border 2 dp

Metric → Line Color mapping:
  Temperature     → tomatoOrange  #FF7043
  Air Humidity    → water         #4FC3F7
  Ground Humidity → leafGreen     #4CAF50
  Luminosity      → sunYellow     #FFD54F
  Pressure        → clay          #8D6E63
```

#### Bar Chart (Ripe Tomatoes Over Time)
```
Bar color:        tomatoRed
Bar radius:       top-left/top-right 4 dp
Bar width:        12 dp
Background bars:  soil700, same width (ghost bars)
```

### 6.6 PhotoCard (Tomato Status Image)

```
┌──────────────────────────────────┐
│  ┌────────────────────────────┐  │
│  │                            │  │
│  │      Photo from camera     │  │  ← ClipRRect, radiusMd, fit: cover
│  │                            │  │
│  └────────────────────────────┘  │
│                                  │
│  March 28, 2026 · 14:32         │  ← bodySmall, clay
│  🍅 3 ripe tomatoes detected    │  ← bodyLarge, tomatoRed icon + cream text
└──────────────────────────────────┘

Aspect ratio:  16:10 for the image area
Card styling:  same as MetricCard
```

### 6.7 ProcessorInfoTile

```
┌──────────────────────────────────────────────────┐
│  🔲 Greenhouse Alpha           ● Online          │  ← CPU icon + name (titleLarge) + status
│  📍 45.7640° N, 4.8357° E                        │  ← location, bodyMedium, clay
│  💧 250 mL / watering · 6 plants                 │  ← watering info, bodyMedium, water color
└──────────────────────────────────────────────────┘
```

---

## 7. Screen Architecture & Navigation

```
App
├── SplashScreen (animated tomato sprout → full plant, 2s)
├── MainShell (BottomNavigationBar)
│   ├── Tab 0 — DashboardScreen
│   ├── Tab 1 — HistoryScreen
│   ├── Tab 2 — CameraScreen
│   └── Tab 3 — SettingsScreen
└── ProcessorDetailScreen (push route from Dashboard)
```

---

## 8. Screen-by-Screen Specification

### 8.1 SplashScreen

- Full-screen `soil900` background.
- Center: animated Lottie/Rive of a tomato seed sprouting into a small plant.
- Below animation: app name **"Tomato Grower"** in `displayLarge`, `leafGreenLight`.
- Tagline: *"Cultivate smarter."* in `bodyMedium`, `clay`.
- Auto-navigate to `MainShell` after 2.5 seconds or animation end.

### 8.2 DashboardScreen

**Layout (top → bottom, scrollable):**

1. **AppBar area** (no Material AppBar — custom):
   - Left: "Dashboard" (`displayLarge`, `cream`).
   - Right: processor name chip (`labelSmall`, `soil800` bg, `leafGreenLight` text, `radiusFull`).
   - If multiple processors → tappable chip opens a `BottomSheet` to switch.

2. **HeroStatusCard** (full width, spec 6.2).

3. **Section title**: "Live Metrics" (`displayMedium`, `cream`), with a refresh `IconButton`.

4. **MetricCard grid** (2 columns, 3 rows):
   - Temperature
   - Air Humidity
   - Ground Humidity
   - Luminosity
   - Pressure
   - (6th cell: "Last Error" card — shows last error text or "All clear" with a checkmark)

5. **Section title**: "Recent Photos" (`displayMedium`, `cream`).

6. **Horizontal scrollable list** of `PhotoCard` widgets (latest 5 photos).

7. **Bottom safe-area spacer** (80 dp for nav bar).

**Pull-to-refresh**: `RefreshIndicator` with `leafGreen` color.

### 8.3 HistoryScreen

**Layout:**

1. **AppBar area**: "History" (`displayLarge`, `cream`).

2. **Date Range Selector**: a horizontal row of pill-shaped chips:
   - "24h" | "7d" | "30d" | "Custom"
   - Active chip: `leafGreen` bg, `soil900` text.
   - Inactive chip: `soil700` bg, `parchment` text.
   - "Custom" opens a `DateRangePicker` dialog styled with theme.

3. **Metric Toggle Row**: horizontally scrollable chips to toggle which metrics are visible on the chart. Each chip has the metric icon + label.
   - Active: metric's semantic color border + fill at 12%.
   - Inactive: `soil700` bg.

4. **Line Chart Card** (fl_chart, spec 6.5):
   - Full width, height 240 dp.
   - Displays selected metrics over selected time range.
   - Pinch-to-zoom horizontally.

5. **Ripe Tomato Bar Chart Card**:
   - Title: "Harvest Tracker" (`titleLarge`, `cream`).
   - Bar chart showing ripe tomato counts over the selected period.
   - Height 160 dp.

6. **Data Table** (expandable):
   - Collapsed by default, "Show raw data" text button.
   - Expands to a styled `DataTable` with alternating row colors (`soil800` / `soil700`).

### 8.4 CameraScreen

**Layout:**

1. **AppBar area**: "Gallery" (`displayLarge`, `cream`).

2. **Grid of photos**: 2-column `MasonryGridView` (staggered).
   - Each item: `PhotoCard` (spec 6.6).
   - Tap opens **full-screen image viewer** with:
     - Pinch-to-zoom.
     - Dark scrim background.
     - Ripe tomato count overlay at bottom.
     - Swipe left/right for adjacent photos.

3. **Empty state** (no photos):
   - Large camera icon (48 dp, `clay`).
   - "No photos yet" (`titleLarge`, `parchment`).
   - "Photos will appear here once your processor captures them." (`bodyMedium`, `clay`).

### 8.5 SettingsScreen

**Layout:**

1. **AppBar area**: "Settings" (`displayLarge`, `cream`).

2. **Processor Section**:
   - `ProcessorInfoTile` (spec 6.7) for each registered processor.
   - Tap → `ProcessorDetailScreen`.

3. **Preferences Section**:
   - Theme toggle (Dark / Light) — `SwitchListTile`.
   - Temperature unit (°C / °F) — `SegmentedButton`.
   - Notification preferences — toggle switches.
   - Refresh interval — dropdown (30s, 1m, 5m, 15m).

4. **About Section**:
   - App version.
   - "Made with 🌱" centered, `bodySmall`, `clay`.

**List tile style:**
```
Leading icon:     24 dp, leafGreenLight
Title:            titleMedium, cream
Subtitle:         bodySmall, clay
Trailing widget:  Switch / Chevron icon (clay)
Divider:          soil600, 0.5 dp, indent 56 dp
```

### 8.6 ProcessorDetailScreen (push route)

**Layout:**

1. **AppBar**: back arrow + processor name (`titleLarge`).

2. **Map Card**: static map thumbnail showing processor location (use `flutter_map` + OpenStreetMap tiles or a static image URL). Height 180 dp, `radiusMd`.

3. **Info Section**: name, coordinates, watering volume, cultivation size — as a styled key-value list.

4. **Recent Metrics Section**: last 5 entries from `culture_info` in a compact timeline-style list.

5. **Watering Action**: large primary "Water Now" button (sends command).

---

## 9. Animations & Micro-interactions

```
Element                     Animation                              Duration  Curve
───────────────────────────────────────────────────────────────────────────────────
Screen transitions          Shared axis (vertical)                 300 ms    easeInOutCubic
Card appearance             FadeIn + SlideUp (staggered 50ms)      400 ms    easeOutCubic
Metric value change         AnimatedSwitcher + FadeIn              200 ms    easeIn
Status dot pulse            Infinite scale 1.0→1.3→1.0            1500 ms   easeInOut
Pull-to-refresh indicator   Lottie watering can                   —         —
Hero plant illustration     Gentle sway loop (Rive/Lottie)        —         —
Sparkline draw              Clip animation left → right            600 ms    easeOutCubic
Chart tooltip               FadeIn + ScaleFrom(0.95)              150 ms    easeOut
Photo grid load             Shimmer placeholder → FadeIn           300 ms    easeOut
Bottom nav switch           Pill indicator slide                   250 ms    easeInOutCubic
```

---

## 10. Illustrations & Assets

| Asset | Format | Description |
|---|---|---|
| `plant_healthy.json` | Lottie/Rive | Tomato plant swaying gently, green leaves, red tomatoes |
| `plant_warning.json` | Lottie/Rive | Same plant, slightly drooping, amber leaves |
| `plant_critical.json` | Lottie/Rive | Wilting plant, brown tones |
| `splash_sprout.json` | Lottie/Rive | Seed → sprout → small plant animation |
| `watering_can.json` | Lottie | Watering can pour animation (for refresh) |
| `empty_camera.svg` | SVG | Stylized camera + leaf outline for empty gallery |
| `app_icon.png` | PNG (1024x1024) | Tomato with a single leaf, flat design, soil900 bg circle |

---

## 11. Data Refresh Strategy

```
Scenario                  Method                          Interval
──────────────────────────────────────────────────────────────────
Dashboard live metrics    Supabase Realtime subscription  Live (on change)
                          OR periodic polling             Per user setting (default 1m)
History charts            Fetch on screen enter +         On pull-to-refresh
                          cache locally (Hive/Isar)
Photos                    Fetch latest 20 on enter        On pull-to-refresh
Processor info            Fetch once on app start         On pull-to-refresh in Settings
```

---

## 12. Flutter Package Recommendations

```
Package                   Purpose
────────────────────────────────────────────────
supabase_flutter          Supabase client + Realtime
fl_chart                  Line charts, bar charts, sparklines
phosphor_flutter          Nature-friendly icon set
google_fonts              DM Sans + DM Mono
cached_network_image      Photo loading + caching
shimmer                   Loading placeholders
flutter_animate           Declarative animations
lottie / rive             Animated illustrations
go_router                 Declarative routing
flutter_riverpod          State management
intl                      Date formatting + i18n
flutter_map + latlong2    OpenStreetMap for processor location
hive_flutter              Local caching
```

---

## 13. Responsive Breakpoints

```
Breakpoint      Width          Layout adaptation
──────────────────────────────────────────────────────────
compact         < 600 dp       Phone — 2-column metric grid, bottom nav
medium          600–840 dp     Tablet portrait — 3-column grid, bottom nav
expanded        > 840 dp       Tablet landscape — NavigationRail + 4-column grid
```

---

## 14. Accessibility

- All interactive elements: minimum touch target **48 x 48 dp**.
- Color contrast ratio: minimum **4.5:1** for text (WCAG AA). Verified:
  - `cream` (#FFF8E1) on `soil800` (#1A2B1A) → **12.4:1** ✓
  - `leafGreenLight` (#81C784) on `soil800` (#1A2B1A) → **6.8:1** ✓
  - `clay` (#8D6E63) on `soil800` (#1A2B1A) → **3.6:1** — used only for non-essential info (timestamps).
- `Semantics` widgets for all charts (screen-reader description of trends).
- Animated elements respect `MediaQuery.disableAnimations`.

---

## 15. Dark / Light Theme Token Map (Flutter ThemeData)

```dart
// These values map directly to ThemeData and ColorScheme construction.

// === DARK (primary) ===
ColorScheme.dark(
  brightness: Brightness.dark,
  primary:        Color(0xFF4CAF50),  // leafGreen
  onPrimary:      Color(0xFF0F1A0F),  // soil900
  primaryContainer:   Color(0xFF1A2B1A),  // soil800
  onPrimaryContainer: Color(0xFFC8E6C9),  // sprout
  secondary:      Color(0xFF4FC3F7),  // water
  onSecondary:    Color(0xFF0F1A0F),
  secondaryContainer: Color(0xFF0288D1), // waterDark
  onSecondaryContainer: Color(0xFFE1F5FE),
  error:          Color(0xFFE53935),  // tomatoRed
  onError:        Color(0xFFFFF8E1),  // cream
  surface:        Color(0xFF1A2B1A),  // soil800
  onSurface:      Color(0xFFFFF8E1),  // cream
  surfaceContainerHighest: Color(0xFF253825), // soil700
  outline:        Color(0xFF34503A),  // soil600
  outlineVariant: Color(0xFF34503A),
)

// === LIGHT ===
ColorScheme.light(
  brightness: Brightness.light,
  primary:        Color(0xFF388E3C),
  onPrimary:      Color(0xFFFFFFFF),
  primaryContainer:   Color(0xFFC8E6C9),
  onPrimaryContainer: Color(0xFF1B2E1B),
  secondary:      Color(0xFF0288D1),
  onSecondary:    Color(0xFFFFFFFF),
  error:          Color(0xFFC62828),
  onError:        Color(0xFFFFFFFF),
  surface:        Color(0xFFFFFFFF),
  onSurface:      Color(0xFF1B2E1B),
  surfaceContainerHighest: Color(0xFFF5F0E1),
  outline:        Color(0xFFD7CFC0),
)
```

---

## 16. File & Folder Structure (Recommended)

```
lib/
├── main.dart
├── app.dart                          // MaterialApp + GoRouter + Theme
├── core/
│   ├── theme/
│   │   ├── app_colors.dart           // All color constants from §2
│   │   ├── app_typography.dart       // All text styles from §3
│   │   ├── app_theme.dart            // ThemeData construction from §15
│   │   └── app_spacing.dart          // Spacing constants from §4
│   ├── constants/
│   │   └── supabase_tables.dart      // Table & column name constants
│   └── utils/
│       ├── date_utils.dart
│       └── unit_conversion.dart      // °C ↔ °F, Pa ↔ hPa
├── data/
│   ├── models/
│   │   ├── culture_info.dart         // Freezed model for culture_info
│   │   ├── tomato_status.dart        // Freezed model for tomatos_status
│   │   └── processor_info.dart       // Freezed model for proc_info
│   ├── repositories/
│   │   ├── culture_repository.dart
│   │   ├── tomato_repository.dart
│   │   └── processor_repository.dart
│   └── providers/
│       └── supabase_provider.dart    // Riverpod provider for Supabase client
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

---

*End of Design Chart — version 1.0*
