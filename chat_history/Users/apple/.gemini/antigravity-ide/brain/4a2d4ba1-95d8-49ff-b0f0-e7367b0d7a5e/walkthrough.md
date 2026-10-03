# 1-on-1 Employee Chat UI Walkthrough

I have fully implemented the 1-on-1 employee chat UI skeleton, leveraging the project's color palette (`AppColors`) as requested.

## Summary of Changes

The entire feature has been enclosed in a clean, self-contained architecture at `lib/features/employee_chat/`. 

### 1. Models
Created [chat_models.dart](file:///Users/apple/Desktop/veremax_hrm_flutter/lib/features/employee_chat/models/chat_models.dart):
- Defined the `Conversation` and `ChatMessage` models.
- Both include `fromJson` and `toJson` methods to easily adapt to the backend contract when it is finalized.

### 2. Mock Data & TODOs
Created [mock_chat_data.dart](file:///Users/apple/Desktop/veremax_hrm_flutter/lib/features/employee_chat/data/mock_chat_data.dart):
- Contains dummy conversations and messages.
- Added explicit `// TODO:` comments inside the repository simulator and inside `ChatScreen`'s `_sendMessage` method indicating where WebSocket subscriptions or API network calls should be dropped in.

### 3. UI Widgets (Themed)
Created modular UI components, strictly adhering to `AppColors.of(context)` to match your palette dynamically:
- [conversation_tile.dart](file:///Users/apple/Desktop/veremax_hrm_flutter/lib/features/employee_chat/widgets/conversation_tile.dart): Displays the colleague avatar, name, role, last message, unread badge (using `colors.primary`), and an online status indicator (using `colors.success`).
- [message_bubble.dart](file:///Users/apple/Desktop/veremax_hrm_flutter/lib/features/employee_chat/widgets/message_bubble.dart): Handles sent vs received logic, styling outgoing messages with `colors.primary` and incoming with `colors.surface`, along with sent/delivered/read checkmarks.
- [chat_input_bar.dart](file:///Users/apple/Desktop/veremax_hrm_flutter/lib/features/employee_chat/widgets/chat_input_bar.dart): Contains the text field for sending messages and an attachment icon.

### 4. Screens
Created the primary navigation screens:
- **Chat List Screen** ([chat_list_screen.dart](file:///Users/apple/Desktop/veremax_hrm_flutter/lib/features/employee_chat/screens/chat_list_screen.dart)): Includes a functional search bar that filters the mock conversations by name and role.
- **Chat Screen** ([chat_screen.dart](file:///Users/apple/Desktop/veremax_hrm_flutter/lib/features/employee_chat/screens/chat_screen.dart)): Manages the state for the optimistic UI. When you send a message, it immediately appends to the in-memory array and automatically scrolls to the bottom.

## Verification
- [x] Folder is completely self-contained within `lib/features/employee_chat`.
- [x] `AppColors` is used consistently across all widgets for seamless light/dark mode support.
- [x] The UI works natively using mock data, and sending messages updates the view instantly.
- [x] Clear TODOs have been added for the API integration steps.

You can now test this out by navigating to `ChatListScreen()` from anywhere in your app!
