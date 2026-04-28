# Cross-Platform QA Plan — 50% Phase

> **Project:** SoundCloud Clone (Flutter)  
> **Phase:** 50% Milestone  
> **Last Updated:** 2026-04-04  
> **Status:** Planning

---

## Overview

This document defines the test scenarios for the 50% development milestone. Scenarios are prioritized based on user impact and core functionality. All scenarios target cross-platform compatibility (iOS, Android, Web).

---

## Module: Auth

| ID       | Scenario                                                                                | Priority | Type       | Automation | Evidence                    | Status  |
| -------- | --------------------------------------------------------------------------------------- | -------- | ---------- | ---------- | --------------------------- | ------- |
| AUTH-001 | User launches app and sees welcome screen with "Create an account" and "Log in" buttons | P0       | Smoke      | ✅ Yes     | Screenshot                  | Planned |
| AUTH-002 | User creates account with valid email and password                                      | P0       | Functional | ✅ Yes     | Assert navigation to login  | Planned |
| AUTH-003 | User sees validation errors for empty signup fields                                     | P0       | Functional | ✅ Yes     | Assert error text visible   | Planned |
| AUTH-004 | User sees validation error for invalid email format                                     | P1       | Functional | ✅ Yes     | Assert error text           | Planned |
| AUTH-005 | User sees validation error when password < 8 characters                                 | P1       | Functional | ✅ Yes     | Assert error text           | Planned |
| AUTH-006 | User sees validation error when passwords do not match                                  | P1       | Functional | ✅ Yes     | Assert error text           | Planned |
| AUTH-007 | User cannot register with an already-registered email                                   | P0       | Functional | ✅ Yes     | Assert duplicate error      | Planned |
| AUTH-008 | User logs in with valid credentials                                                     | P0       | Functional | ✅ Yes     | Assert home screen visible  | Planned |
| AUTH-009 | User sees error for invalid login credentials                                           | P0       | Functional | ✅ Yes     | Assert error text           | Planned |
| AUTH-010 | User navigates to forgot password screen from login                                     | P1       | Functional | ✅ Yes     | Assert reset screen visible | Planned |
| AUTH-011 | User submits forgot password for registered email                                       | P1       | Functional | ✅ Yes     | Assert return to login      | Planned |
| AUTH-012 | User sees error for forgot password with unregistered email                             | P1       | Functional | ✅ Yes     | Assert error text           | Planned |
| AUTH-013 | User retries forgot password after initial failure                                      | P2       | Functional | ✅ Yes     | Assert success on retry     | Planned |
| AUTH-014 | User navigates back from signup to welcome screen                                       | P2       | Navigation | ✅ Yes     | Assert welcome visible      | Planned |
| AUTH-015 | User navigates back from login to welcome screen                                        | P2       | Navigation | ✅ Yes     | Assert welcome visible      | Planned |

---

## Module: Navigation

| ID      | Scenario                                                            | Priority | Type       | Automation | Evidence                      | Status  |
| ------- | ------------------------------------------------------------------- | -------- | ---------- | ---------- | ----------------------------- | ------- |
| NAV-001 | Logged-in user sees bottom navigation bar with 5 tabs               | P0       | Smoke      | ✅ Yes     | Assert all tabs visible       | Planned |
| NAV-002 | User taps Home tab and sees home content                            | P0       | Functional | ✅ Yes     | Assert "TODAY'S PICK" visible | Planned |
| NAV-003 | User taps Feed tab and sees Following/Discover sections             | P0       | Functional | ✅ Yes     | Assert section headers        | Planned |
| NAV-004 | User taps Search tab and sees search input                          | P0       | Functional | ✅ Yes     | Assert search field           | Planned |
| NAV-005 | User taps Library tab and sees library screen                       | P0       | Functional | ✅ Yes     | Assert library content        | Planned |
| NAV-006 | User taps Upgrade tab and sees subscription pitch                   | P1       | Functional | ✅ Yes     | Assert promo text             | Planned |
| NAV-007 | User can cycle through all tabs without app crash                   | P0       | Stability  | ✅ Yes     | No exceptions thrown          | Planned |
| NAV-008 | Tab selection state persists when switching tabs                    | P2       | Functional | ✅ Yes     | Assert active tab indicator   | Planned |
| NAV-009 | Deep content within a tab is preserved when switching away and back | P2       | Functional | ⚠️ Manual  | Observe scroll position       | Planned |

---

## Module: Search

| ID       | Scenario                                           | Priority | Type       | Automation | Evidence               | Status  |
| -------- | -------------------------------------------------- | -------- | ---------- | ---------- | ---------------------- | ------- |
| SRCH-001 | User sees search input field on Search tab         | P0       | Smoke      | ✅ Yes     | Assert field present   | Planned |
| SRCH-002 | User types query and sees filtered results         | P0       | Functional | ✅ Yes     | Assert matching tracks | Planned |
| SRCH-003 | Search results update as user types (debounced)    | P1       | Functional | ✅ Yes     | Assert list changes    | Planned |
| SRCH-004 | Search shows "no results" for unmatched query      | P1       | Functional | ✅ Yes     | Assert empty state     | Planned |
| SRCH-005 | Clearing search input resets results list          | P1       | Functional | ✅ Yes     | Assert default state   | Planned |
| SRCH-006 | Search is case-insensitive                         | P2       | Functional | ✅ Yes     | Assert same results    | Planned |
| SRCH-007 | User can tap a search result to view track details | P1       | Functional | ⚠️ Partial | Assert navigation      | Planned |

---

## Module: Widget Tests

| ID      | Scenario                                           | Priority | Type  | Automation | Evidence               | Status  |
| ------- | -------------------------------------------------- | -------- | ----- | ---------- | ---------------------- | ------- |
| WGT-001 | App launches and renders SoundCloudApp root widget | P0       | Smoke | ✅ Yes     | Assert widget tree     | Planned |
| WGT-002 | Welcome screen displays tagline text               | P0       | Smoke | ✅ Yes     | Assert text present    | Planned |
| WGT-003 | ElevatedButton renders with correct label          | P2       | Unit  | ✅ Yes     | Assert button text     | Planned |
| WGT-004 | OutlinedButton renders with correct label          | P2       | Unit  | ✅ Yes     | Assert button text     | Planned |
| WGT-005 | TextField displays hint text correctly             | P2       | Unit  | ✅ Yes     | Assert hint visible    | Planned |
| WGT-006 | Social login buttons render (Google, Facebook)     | P1       | Smoke | ✅ Yes     | Assert buttons present | Planned |
| WGT-007 | MiniPlayer widget renders when track is active     | P1       | Unit  | ⚠️ Partial | Assert player visible  | Planned |

---

## Module: Stability / Regression

| ID      | Scenario                                              | Priority | Type           | Automation | Evidence         | Status  |
| ------- | ----------------------------------------------------- | -------- | -------------- | ---------- | ---------------- | ------- |
| STB-001 | App cold start completes within 5 seconds             | P0       | Performance    | ⚠️ Manual  | Stopwatch / logs | Planned |
| STB-002 | No unhandled exceptions during full auth flow         | P0       | Regression     | ✅ Yes     | No crash logs    | Planned |
| STB-003 | No unhandled exceptions during tab navigation cycle   | P0       | Regression     | ✅ Yes     | No crash logs    | Planned |
| STB-004 | App handles rapid tab switching without crash         | P1       | Stress         | ✅ Yes     | No exceptions    | Planned |
| STB-005 | App recovers gracefully from network timeout (mocked) | P1       | Error Handling | ⚠️ Partial | Assert error UI  | Planned |
| STB-006 | Memory does not leak during extended search usage     | P2       | Performance    | ⚠️ Manual  | DevTools profile | Planned |
| STB-007 | App state survives backgrounding and foregrounding    | P2       | Stability      | ⚠️ Manual  | Observe state    | Planned |

---

## Summary

| Module       | Total  | P0     | P1     | P2     | Automatable |
| ------------ | ------ | ------ | ------ | ------ | ----------- |
| Auth         | 15     | 5      | 5      | 5      | 15          |
| Navigation   | 9      | 4      | 1      | 4      | 8           |
| Search       | 7      | 2      | 4      | 1      | 6           |
| Widget Tests | 7      | 2      | 2      | 3      | 6           |
| Stability    | 7      | 3      | 2      | 2      | 4           |
| **Total**    | **45** | **16** | **14** | **15** | **39**      |

---

## Legend

| Symbol     | Meaning                               |
| ---------- | ------------------------------------- |
| P0         | Critical — must pass for release      |
| P1         | High — important user flow            |
| P2         | Medium — edge case or polish          |
| ✅ Yes     | Fully automatable                     |
| ⚠️ Partial | Requires manual verification or setup |
| ⚠️ Manual  | Cannot be automated reliably          |

---

## Next Steps

1. Review and approve scenario list
2. Map existing tests to scenario IDs
3. Identify gaps and create new test stubs
4. Execute P0 scenarios first
5. Track pass/fail status per platform (iOS, Android, Web)
