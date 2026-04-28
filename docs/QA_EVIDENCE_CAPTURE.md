# QA Evidence Capture Guide

> **Audience:** QA team, developers running tests  
> **Project:** Flutter Cross-Platform App  
> **Last Updated:** 2026-04-04

---

## 📁 Evidence Storage Locations

| Type                                 | Location                    | Notes                                 |
| ------------------------------------ | --------------------------- | ------------------------------------- |
| Flutter integration test screenshots | `build/test_outputs/`       | Created by `integration_test` package |
| Flutter test failure logs            | `build/test_results/`       | JSON/XML reports                      |
| iOS Simulator screenshots            | `~/Desktop/` or custom path | Via `xcrun simctl`                    |
| Android Emulator screenshots         | `build/screenshots/`        | Via `adb shell screencap`             |
| Screen recordings                    | `build/recordings/`         | Manual or CI artifacts                |
| CI artifacts                         | GitHub Actions artifacts    | Uploaded on failure                   |

---

## 📸 Capturing Flutter Integration Test Evidence

### Screenshot on Failure (in test code)

```dart
import 'package:integration_test/integration_test.dart';

final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

testWidgets('my test', (tester) async {
  // ... test steps ...

  // Capture screenshot (works on device/simulator)
  await binding.takeScreenshot('failure-state-name');
});
```

### Screenshot on Any Assertion Failure

```dart
testWidgets('critical flow', (tester) async {
  try {
    expect(find.text('Home'), findsOneWidget);
  } catch (e) {
    await binding.takeScreenshot('home-not-found');
    rethrow;
  }
});
```

---

## 📱 Simulator/Emulator Screenshots

### iOS Simulator

```bash
# Screenshot to file
xcrun simctl io booted screenshot ~/Desktop/failure_$(date +%s).png

# Screen recording (start)
xcrun simctl io booted recordVideo ~/Desktop/test_recording.mov

# Stop recording: Ctrl+C
```

### Android Emulator

```bash
# Screenshot
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png build/screenshots/

# Screen recording (max 180s)
adb shell screenrecord /sdcard/recording.mp4
# Stop: Ctrl+C, then pull
adb pull /sdcard/recording.mp4 build/recordings/
```

---

## 🔴 Evidence Required for Failed Scenarios

**All failures MUST include:**

| Evidence                    | Format   | Purpose                              |
| --------------------------- | -------- | ------------------------------------ |
| Screenshot at failure point | PNG      | Visual state when assertion failed   |
| Test console output         | Text/log | Stack trace + error message          |
| Steps to reproduce          | Text     | What the test was doing              |
| Device/platform info        | Text     | iOS version, Android API level, etc. |

**Template for failure report:**

```
Scenario: AUTH-008 User logs in with valid credentials
Status: FAILED
Platform: iOS 17.2 Simulator (iPhone 15 Pro)
Failure: Expected 'Home' but found nothing

Steps completed:
1. ✅ Launched app
2. ✅ Tapped 'Log in'
3. ✅ Entered credentials
4. ✅ Tapped submit
5. ❌ Home screen did not appear

Evidence:
- Screenshot: build/test_outputs/auth-008-failure.png
- Log: build/test_results/auth_test_output.log
```

---

## ✅ Evidence Recommended for Critical Passed Scenarios

**P0 (Critical) passes SHOULD include:**

| Evidence                  | When       | Purpose             |
| ------------------------- | ---------- | ------------------- |
| Screenshot of final state | On success | Proof of completion |
| Console log (no errors)   | Always     | Confirm no warnings |

**Scenarios requiring pass evidence:**

- AUTH-001: Welcome screen renders
- AUTH-002: Account creation succeeds
- AUTH-008: Login succeeds
- NAV-001: All tabs visible
- SRCH-002: Search returns results

**Capture pattern:**

```dart
testWidgets('critical: user logs in successfully', (tester) async {
  await launchApp(tester);
  await loginAsSeededUser(tester);

  expect(find.text('Home'), findsOneWidget);

  // Evidence for critical pass
  await binding.takeScreenshot('AUTH-008-pass-home-visible');
});
```

---

## 🤖 CI Integration (GitHub Actions)

```yaml
- name: Run integration tests
  run: flutter test integration_test --machine > test_results.json

- name: Upload failure evidence
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: test-failure-evidence
    path: |
      build/test_outputs/
      build/test_results/
      test_results.json
```

---

## Quick Reference

| Task                      | Command                                                       |
| ------------------------- | ------------------------------------------------------------- |
| Run all integration tests | `flutter test integration_test`                               |
| Run single test file      | `flutter test integration_test/authentication/auth_test.dart` |
| Run with verbose output   | `flutter test integration_test -v`                            |
| Generate coverage         | `flutter test --coverage`                                     |

---

## Checklist Before Submitting Test Results

- [ ] All P0 failures have screenshots attached
- [ ] Failure logs include full stack trace
- [ ] Platform/device info documented
- [ ] P0 passes have final-state screenshot
- [ ] Evidence files named with scenario ID (e.g., `AUTH-008-pass.png`)
