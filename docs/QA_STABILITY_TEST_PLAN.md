# Light Stability & Stress Test Plan

> **Project:** Flutter Cross-Platform App  
> **Scope:** User-level repeated actions (not load testing)  
> **Last Updated:** 2026-04-04

---

## Overview

These scenarios simulate realistic user behavior patterns that may reveal memory leaks, state corruption, UI freezes, or crash bugs. Each test involves repeating an action 10-50 times in succession.

---

## STB-100: Repeated Navigation Across Tabs

| Attribute         | Value                                                                                                  |
| ----------------- | ------------------------------------------------------------------------------------------------------ |
| **Action**        | Tap through all 5 bottom tabs (Home → Feed → Search → Library → Upgrade) in sequence, repeat 20 cycles |
| **Type**          | ✅ Automated                                                                                           |
| **Evidence**      | Console log (no exceptions), memory snapshot before/after, final screenshot                            |
| **Pass Criteria** | No crash, no ANR, UI remains responsive, memory delta < 20MB                                           |

**Risks Caught:**

- Memory leak from widget rebuilds
- State not disposed properly on tab switch
- Navigator stack corruption
- Listener accumulation (stream subscriptions not cancelled)

**Automation Approach:**

```dart
for (var i = 0; i < 20; i++) {
  for (final tab in ['Feed', 'Search', 'Library', 'Upgrade', 'Home']) {
    await openBottomTab(tester, tab);
  }
}
expect(find.text('Home'), findsOneWidget);
```

---

## STB-101: Repeated Login Attempts (Invalid Credentials)

| Attribute         | Value                                                        |
| ----------------- | ------------------------------------------------------------ |
| **Action**        | Enter wrong password and tap "Log in" 15 times consecutively |
| **Type**          | ✅ Automated                                                 |
| **Evidence**      | Console log, screenshot of final state, error message count  |
| **Pass Criteria** | Error displays consistently, no crash, form remains usable   |

**Risks Caught:**

- Error state accumulation (multiple snackbars stacking)
- State not reset between attempts
- Memory buildup from error handling
- Rate limiting UI (if implemented) doesn't break UX

**Automation Approach:**

```dart
for (var i = 0; i < 15; i++) {
  await enterLoginCredentials(tester, email: 'test@gmail.com', password: 'wrong');
  await tapAndSettle(tester, actionButton('Log in'));
  expect(find.text('Invalid email or password'), findsOneWidget);
}
```

---

## STB-102: Repeated Search Query Changes

| Attribute         | Value                                                                        |
| ----------------- | ---------------------------------------------------------------------------- |
| **Action**        | Type query, wait for results, clear, repeat with different query — 25 cycles |
| **Type**          | ✅ Automated                                                                 |
| **Evidence**      | Console log, final screenshot, memory snapshot                               |
| **Pass Criteria** | Results update correctly each time, no stale results, no crash               |

**Risks Caught:**

- Debounce logic fails under rapid input
- Previous search results leak into new query
- TextEditingController not disposed
- ListView rebuild performance degradation
- Image cache overflow from result thumbnails

**Automation Approach:**

```dart
final queries = ['luther', 'plan', 'beat', 'a', 'xyz', 'drake'];
for (var i = 0; i < 25; i++) {
  final query = queries[i % queries.length];
  await tester.enterText(searchField, query);
  await tester.pumpAndSettle();
  await tester.enterText(searchField, ''); // clear
  await tester.pumpAndSettle();
}
```

---

## STB-103: Repeated Auth Screen Navigation (Back/Forward)

| Attribute         | Value                                                               |
| ----------------- | ------------------------------------------------------------------- |
| **Action**        | Welcome → Signup → Back → Login → Back → Signup → Back... 20 cycles |
| **Type**          | ✅ Automated                                                        |
| **Evidence**      | Console log, navigator stack state, final screenshot                |
| **Pass Criteria** | Navigator stack doesn't grow, back always returns to Welcome        |

**Risks Caught:**

- Navigator stack accumulation (pushing without popping)
- Form state persists incorrectly across navigation
- Route transition animations causing memory buildup
- Keyboard focus issues after repeated navigation

**Automation Approach:**

```dart
for (var i = 0; i < 20; i++) {
  await tapAndSettle(tester, actionButton('Create an account'));
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tapAndSettle(tester, outlinedActionButton('Log in'));
  await tester.pageBack();
  await tester.pumpAndSettle();
}
expect(find.text('Create an account'), findsOneWidget);
```

---

## STB-104: Repeated Forgot Password Flow

| Attribute         | Value                                                                            |
| ----------------- | -------------------------------------------------------------------------------- |
| **Action**        | Login → Forgot Password → Submit (invalid) → Back → Forgot Password... 10 cycles |
| **Type**          | ✅ Automated                                                                     |
| **Evidence**      | Console log, screenshot sequence                                                 |
| **Pass Criteria** | Error message clears on retry, navigation consistent                             |

**Risks Caught:**

- Error state persists across screen re-entry
- Form validation state corruption
- Snackbar/toast stacking
- TextField controller reuse issues

---

## STB-105: Rapid Button Taps (Double/Triple Submit)

| Attribute         | Value                                                                  |
| ----------------- | ---------------------------------------------------------------------- |
| **Action**        | Tap "Create account" or "Log in" button 5 times rapidly (within 500ms) |
| **Type**          | ✅ Automated                                                           |
| **Evidence**      | Console log, network call count (if mocked), final state               |
| **Pass Criteria** | Only one action triggered, no duplicate navigation                     |

**Risks Caught:**

- Duplicate form submissions
- Multiple navigation pushes to same route
- Race condition in async handlers
- Loading state not blocking re-tap

**Automation Approach:**

```dart
// Fill valid form first
await tester.enterText(emailField, 'test@gmail.com');
await tester.enterText(passwordField, '12345678');
await tester.pump();

// Rapid taps
for (var i = 0; i < 5; i++) {
  await tester.tap(actionButton('Log in'));
  await tester.pump(const Duration(milliseconds: 50));
}
await tester.pumpAndSettle();

// Should only navigate once
expect(find.text('Home'), findsOneWidget);
```

---

## STB-106: Repeated Modal/Dialog Open-Close

| Attribute         | Value                                                           |
| ----------------- | --------------------------------------------------------------- |
| **Action**        | Open profile completion card action → dismiss → repeat 15 times |
| **Type**          | ⚠️ Manual (no modal dialogs confirmed in current UI)            |
| **Evidence**      | Screen recording, memory profiler screenshot                    |
| **Pass Criteria** | Modal opens/closes cleanly, no overlay artifacts                |

**Risks Caught:**

- Overlay accumulation (barriers not removed)
- Animation controller disposal issues
- Focus trap persistence after dismiss
- GestureDetector conflicts

**Manual Steps:**

1. Login and navigate to Profile
2. Tap "Add photo" button
3. Dismiss dialog (tap outside or X)
4. Repeat steps 2-3 fifteen times
5. Observe: UI responsive? Any ghost overlays?

---

## STB-107: Repeated Home Screen Refresh

| Attribute         | Value                                                                             |
| ----------------- | --------------------------------------------------------------------------------- |
| **Action**        | Pull-to-refresh on Home screen (if implemented), or tab away and back — 15 cycles |
| **Type**          | ⚠️ Manual (pull-to-refresh not confirmed)                                         |
| **Evidence**      | Screen recording, memory snapshot                                                 |
| **Pass Criteria** | Content reloads correctly, no duplicate items                                     |

**Risks Caught:**

- List items duplicating on refresh
- Scroll position jumping unexpectedly
- Image cache not clearing stale entries
- API call accumulation (if not cancelled)

---

## STB-108: Full Session Flow (End-to-End Stability)

| Attribute         | Value                                                                             |
| ----------------- | --------------------------------------------------------------------------------- |
| **Action**        | Login → Visit all tabs → Search 3 queries → Return home → Logout → Repeat 5 times |
| **Type**          | ✅ Automated                                                                      |
| **Evidence**      | Full console log, memory snapshots at each cycle, final screenshot                |
| **Pass Criteria** | All 5 cycles complete, app returns to clean Welcome state                         |

**Risks Caught:**

- Session state leaking across logout/login
- Memory growth over extended use
- Provider/Riverpod state not reset on logout
- Audio player not stopping on logout

---

## Summary Table

| ID      | Scenario                   | Type   | Priority | Est. Time |
| ------- | -------------------------- | ------ | -------- | --------- |
| STB-100 | Tab navigation × 20        | Auto   | P0       | 2 min     |
| STB-101 | Failed login × 15          | Auto   | P0       | 1 min     |
| STB-102 | Search queries × 25        | Auto   | P0       | 2 min     |
| STB-103 | Auth nav back/forward × 20 | Auto   | P1       | 2 min     |
| STB-104 | Forgot password flow × 10  | Auto   | P1       | 1 min     |
| STB-105 | Rapid button taps          | Auto   | P1       | 30 sec    |
| STB-106 | Modal open/close × 15      | Manual | P2       | 3 min     |
| STB-107 | Home refresh × 15          | Manual | P2       | 3 min     |
| STB-108 | Full session × 5           | Auto   | P0       | 5 min     |

---

## Evidence Checklist

**For all automated stability tests:**

- [ ] Console log saved (verify zero exceptions)
- [ ] Memory snapshot before first cycle
- [ ] Memory snapshot after last cycle
- [ ] Delta calculated (flag if > 20MB growth)
- [ ] Final UI screenshot

**For manual stability tests:**

- [ ] Screen recording of full session
- [ ] Notes on any UI glitches observed
- [ ] DevTools memory tab screenshot (if accessible)

---

## When to Run

| Trigger              | Scenarios                                        |
| -------------------- | ------------------------------------------------ |
| Every PR             | STB-100, STB-101, STB-102                        |
| Weekly regression    | All automated (STB-100 through STB-105, STB-108) |
| Pre-release          | All scenarios including manual                   |
| After major refactor | Full suite with extended cycles (2x normal)      |
