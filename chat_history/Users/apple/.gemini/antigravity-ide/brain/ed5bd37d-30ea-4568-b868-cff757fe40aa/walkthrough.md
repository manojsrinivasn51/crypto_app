# Notification System Implementation Complete

I have successfully added the entire notifications infrastructure and UI exactly as we planned.

## 1. Top Bar Notification Bell
The Home Screen (`EmployeeHomeScreen`) now features a bell icon right next to the user's profile picture. 
- It actively listens to the `NotificationProvider` for the `unreadCount`.
- If there are unread notifications, a bold red badge (e.g., `3` or `99+`) is displayed on top of the bell.
- Clicking the bell navigates you smoothly to the new `NotificationsScreen`.

## 2. Dedicated Notifications Screen
I built a brand new list screen that displays the user's notifications.
- **Unread** notifications are styled with bold text, a highlighted background tint, and a small blue indicator dot so they are instantly recognizable.
- **Read** notifications fade slightly into the background.
- It includes a "Mark All Read" button at the top.
- Tapping any unread notification will instantly mark it as read and remove its highlight!

## 3. The 1-Week Disappearance Rule
As requested, opened (read) notifications will automatically disappear from the app after exactly 1 week!
Inside `NotificationProvider`, when the notifications are fetched from the Laravel API, a local filter iterates through them:
```dart
      _notifications = rawList.where((n) {
        if (n.readAt != null) {
          final difference = now.difference(n.readAt!);
          if (difference.inDays >= 7) {
            return false; // Automatically hides it
          }
        }
        return true;
      }).toList();
```
Even if your backend retains old notifications forever, the Flutter app ensures the user only sees read notifications from the past 7 days!

> [!TIP]
> The unread count is fetched automatically alongside your attendance when the app opens, meaning the red badge will always be up-to-date!
