# Implementation Plan: Premium Holidays Module (Refined)

This document outlines the architecture and technical approach for building the Holidays feature as a first-class VHRMS feature that follows the existing PremiumPage, design tokens, localization, motion system, and Provider architecture.

## Goal
Build the Holidays module to seamlessly match the VHRMS ecosystem. The implementation avoids one-off UI patterns and creates reusable building blocks (like a global PremiumShimmer) so the rest of the application can adopt them over time.

## 1. Network & Data Layer

### `lib/constants/backend_urls.dart`
- [MODIFY] Add `static String get holidays => _url('/holidays');` inside `ApiEndpoints`.

### `lib/models/holiday_model.dart`
- [NEW] Create `HolidayModel` and `StateModel`.
- Parse the backend JSON response: `holiday_name`, `date`, `day_name`, `status`, `state`.

### `lib/repositories/holiday_repository.dart`
- [NEW] Create `HolidayRepository` using `Dio`.
- Implement `fetchHolidays({required int stateId, required int year})` which queries `GET /api/holidays?state_id=$stateId&year=$year`.
- *Architecture Note*: This follows the existing feature-based repository pattern (`AttendanceRepository`, `LeaveRepository`, etc.) found in `lib/repositories`.

### `lib/providers/holidays_provider.dart`
- [NEW] Create `HolidaysProvider` extending `ChangeNotifier`.
- **State**: `selectedStateId` (defaults to user's assigned state), `selectedYear` (defaults to current year), `isLoading`, `holidays` (List).
- **Future-Proof Grouping**: Group holidays by `year` -> `month` -> `List<HolidayModel>`. This ensures seamless scalability when displaying holidays across year boundaries.
- **Methods**: `fetchHolidays()`, `changeYear()`.

## 2. Reusable Building Blocks

### `lib/widgets/loading/premium_shimmer.dart`
- [NEW] Create a new `PremiumShimmer` component.
- This will act as the new global standard for skeleton loading states across the VHRMS app, allowing future migrations for Attendance, Leaves, Profile, and Documents away from `CircularProgressIndicator`.

## 3. UI Components & Screens

### `lib/view/home/screens/holidays_screen.dart`
- [MODIFY] Replace placeholder with `PremiumPage(title: "Holidays")`.
- **Layout**:
  1. Subtle hero card: "Official Holidays" (Subtitle: "Official company holidays for your assigned state.") using the `calendar_month` icon.
  2. Filter Row: 
     - **State**: Read-only premium chip (e.g., "[Tamil Nadu]").
     - **Year**: Premium dropdown (editable).
  3. `ListView.builder` for the grouped holidays.
- **Empty State**: `EmptyState.generic(...)` with Title: "No Holidays Available" and Message: "There are no official holidays for the selected year."
- **Loading State**: Uses the newly created `PremiumShimmer` (e.g., rendering skeleton `HolidayCard` shapes).
- **Motion**: Relies exclusively on `PremiumPage`'s built-in entrance animations. No custom staggered animations will be reinvented.

### `lib/view/home/widgets/holiday_card.dart`
- [NEW] Create a premium rounded card for individual holidays.
- **Design Layout**:
  - Left side: Large bold Date (`14`) with a smaller Month underneath (`JAN`).
  - Center: Holiday Name (`Republic Day`) and Day Name (`Monday`).
  - Status: ONLY shown if the status is unusual (e.g., "Restricted", "Optional", "Cancelled", "Half Day"). If "Active", the status badge is entirely hidden for a cleaner UI.

### `lib/view/home/widgets/month_header.dart`
- [NEW] Premium section header (e.g., "January 2026").
- **Design Layout**:
  - Left side: Month & Year (Weight 700).
  - Right side: Subtle holiday count (e.g., "3 Holidays") to reinforce the HRMS feel.

## 4. Localization & Formatting
- **Dates**: Use `intl` package.
- **Strings**: Ensure all strings (e.g., "Holidays", "Official Holidays", "No Holidays Available") are hardcoded gracefully in line with the current VHRMS UI patterns, or use `AppLocalizations` if standard keys exist.

## User Review Required
Please review the refined plan above. If this completely captures your architectural feedback and UI polish, approve this plan so I can begin execution immediately.
