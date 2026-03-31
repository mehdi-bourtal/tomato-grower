# Platform Setup for Notifications & Background Tasks

After running `flutter create .` in the `app/` directory to generate platform folders, apply these changes.

---

## Android

### 1. `android/app/src/main/AndroidManifest.xml`

Add these permissions **inside** `<manifest>` (before `<application>`):

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### 2. `android/app/build.gradle`

Ensure `minSdkVersion` is at least **21** (should already be the case):

```groovy
defaultConfig {
    minSdkVersion 21
    // ...
}
```

### 3. Notification channel (auto-created)

The notification channel `tomato_grower_ripe` is created automatically by `flutter_local_notifications` on first use. No manual registration needed.

---

## iOS

### 1. `ios/Runner/AppDelegate.swift`

Add background fetch and notification registration:

```swift
import UIKit
import Flutter
import workmanager
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications setup
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // workmanager setup
    WorkmanagerPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    UIApplication.shared.setMinimumBackgroundFetchInterval(
      TimeInterval(24 * 60 * 60)  // 24 hours
    )

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 2. `ios/Runner/Info.plist`

Add inside `<dict>`:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>processing</string>
</array>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
  <string>com.tomatogrower.ripeTomatoCheck</string>
</array>
```

---

## Testing

To test the background task immediately without waiting 24h:

```dart
// Add temporarily in main.dart after registerPeriodicTask():
await Workmanager().registerOneOffTask(
  'test_ripe_check',
  'com.tomatogrower.ripeTomatoCheck',
);
```

This will trigger the task once as soon as possible. Remove after testing.
