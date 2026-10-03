# Notifications Feature Implementation Plan

We will implement a complete notifications system for the app, including a bell icon with an unread badge on the Home Screen, a dedicated Notifications list screen, and logic to hide notifications that have been read for more than 1 week.

## 1. Notification Provider & Repository

Since your `backend_urls.dart` already has the notification endpoints defined, I will create:
- **`NotificationRepository`**: Handles API calls to fetch the list, mark as read, mark all as read, and fetch the unread count.
- **`NotificationProvider`**: Manages the state of the notifications (unread count, list of notifications) and auto-filters out notifications that were read more than 7 days ago.

## 2. Notification Bell (Home Screen)

I will update the `_buildHeader` in `EmployeeHomeScreen` to include a bell icon next to the user's profile picture.
- It will feature a red badge showing the current `unreadCount`.
- Tapping the bell will navigate the user to the new Notifications Screen.

## 3. Notifications Screen

I will build a new screen (`NotificationsScreen`) that lists all notifications in a beautiful list.
- Unread notifications will have a distinct background color (e.g., light blue tint) or an indicator dot.
- Tapping a notification will mark it as read via the API and update the local state.
- A "Mark All as Read" button will be provided at the top.

## 4. "Disappear after 1 week" Logic

To fulfill your request of hiding opened notifications after 1 week:
- In the `NotificationProvider`, when fetching the list from the backend, I will filter the list locally.
- If a notification's `read_at` timestamp is not null, AND that timestamp is older than 7 days, it will be automatically hidden from the UI. 

> [!TIP]
> Alternatively, if your backend already filters out 1-week-old read notifications from the `/notifications` endpoint, the Flutter app won't need to do anything extra. I will implement the local filter just to be safe!

Does this sound good to you? Once approved, I'll start building the repository, provider, and screens!
