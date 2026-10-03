# Integrate Employee Birthdays API

The backend team has provided a new endpoint `api/birthdays/today` specifically for fetching today's birthdays from the employee's perspective. This endpoint will be used to show the birthday popup on the Employee Dashboard.

## Proposed Changes

### 1. API Endpoint and Models
- Add `birthdaysToday` endpoint to `lib/constants/backend_urls.dart`.
- Create a new Freezed model `lib/models/employee_birthday_model.dart` to represent the JSON structure:
  - `EmployeeBirthdayResponse` (contains `success`, `count`, `birthdays`)
  - `EmployeeBirthday` (contains `id`, `name`, `first_name`, `last_name`, `department`, `position`, `company`, `profile_image_url`, `is_current_user`, `date_of_birth`, `dob_formatted`)

### 2. Repository and Provider
- Currently, employee-related data like notifications or profile might be in different repos. We will add `fetchTodaysBirthdays()` to `lib/repositories/profile_repository.dart` (or create a dedicated `dashboard_repository` if more appropriate).
- Update the state management (e.g., `EmployeeProvider` or `ProfileProvider`) to call this endpoint on initialization and store the list of birthdays.

### 3. UI Integration
- Recreate/Update `lib/view/home/widgets/birthday_popup_dialog.dart` to consume the new `EmployeeBirthday` model. Note: this is for the employee view, distinct from the Super Admin view which has `turning_age` and advanced stats.
- Update `lib/view/home/screens/employee_home_screen.dart` to fetch the data on `initState` and automatically show the dialog if `count > 0`.

## Open Questions for User
- Should the popup appear for the employee *themselves* if `is_current_user` is true (e.g., "Happy Birthday to you!"), or should we filter out the current user and only show colleagues' birthdays?
- Which repository/provider should own the `fetchTodaysBirthdays` call on the employee side? (I plan to use `AuthRepository` or `ProfileRepository` unless you specify otherwise).

## Verification Plan
- Run `build_runner` to generate the new model code.
- Hot restart the app and login as an employee to verify the popup triggers correctly.
