# Backend Requirements: Birthday Feature (API & Notification)

The local check for birthdays has been completely **removed** from the Flutter app. 
To trigger both the Birthday Popup and the standard system notification, the backend must now handle the logic entirely via a Daily Cron Job that sends a Firebase Cloud Messaging (FCM) Push Notification.

---

## 1. Daily Scheduled Task (Cron Job)
The backend must run a daily scheduled task (e.g., at 8:00 AM) that queries for all employees whose birthday is today.

### A. Notification to the Birthday Employee (Triggers Popup)
Send an FCM push notification directly to the employee. 
**Crucial Requirement:** The data payload must include `"type": "birthday_popup"`. When the Flutter app receives this specific type, it will automatically show the custom Birthday Dialog overlay. 

You can also pass dynamic data in the `data` payload to customize the dialog (e.g., the user's avatar, initials, or a custom message).

**Example FCM Payload:**
```json
{
  "message": {
    "token": "<employee_fcm_token>",
    "notification": {
      "title": "Happy Birthday!",
      "body": "Wishing you a fantastic birthday filled with joy and success!"
    },
    "data": {
      "type": "birthday_popup",
      "imageUrl": "https://example.com/avatar.png",
      "initials": "M",
      "title": "Happy Birthday, Manoj!",
      "message": "Wishing you a fantastic year ahead filled with joy, success, and new adventures."
    }
  }
}
```

### B. Notification to Super Admins (Optional Reminder)
Send a standard Firebase push notification to all users with the Super Admin role to remind them.

**Example FCM Payload:**
```json
{
  "message": {
    "token": "<super_admin_fcm_token>",
    "notification": {
      "title": "Birthday Reminder \ud83c\udf82",
      "body": "Today is Manoj's birthday!"
    }
  }
}
```
