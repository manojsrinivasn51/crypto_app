# 1-on-1 Employee Chat UI Skeleton

This plan outlines the creation of a fully navigable, self-contained 1-on-1 employee chat UI in Flutter, using static/mock in-memory data as requested.

## Proposed Changes

We will create a new self-contained feature folder at `lib/features/employee_chat` (or `lib/view/employee_chat` if you prefer to keep it inside the `view` layer) which will contain its own models, mock data, screens, and widgets.

### Models & Mock Data
- **`lib/features/employee_chat/models/chat_models.dart`**: 
  - `Conversation` and `ChatMessage` model classes.
  - Both will include `fromJson` factory constructors ready for real JSON parsing later.
- **`lib/features/employee_chat/data/mock_chat_data.dart`**: 
  - Hardcoded list of `Conversation` and `ChatMessage` objects.
  - Include TODOs where real API calls/WebSocket listeners will be implemented.

### Screens
- **`lib/features/employee_chat/screens/chat_list_screen.dart`**: 
  - Displays all 1-on-1 conversations.
  - Includes a search bar to filter by name/role.
  - Shows avatar, name, role, last message preview, timestamp, unread count badge, and online/offline indicator.
- **`lib/features/employee_chat/screens/chat_screen.dart`**: 
  - Displays a single conversation.
  - App bar with the colleague's avatar, name, and online status.
  - Scrollable list of message bubbles.
  - Message input bar (attachment icon, text field, send button).
  - Implements optimistic UI to append messages immediately to the in-memory list without real delivery.

### Widgets
- **`lib/features/employee_chat/widgets/conversation_tile.dart`**: A reusable list tile for the chat list screen.
- **`lib/features/employee_chat/widgets/message_bubble.dart`**: A widget for individual chat messages (styled differently for sent vs. received, with timestamp and delivery status indicators).
- **`lib/features/employee_chat/widgets/chat_input_bar.dart`**: The message input area.

## Open Questions

1. **Folder Location:** I plan to place this in `lib/features/employee_chat/` to perfectly match your "self-contained feature folder" requirement. Is this acceptable, or would you prefer it under `lib/view/employee_chat/`?
2. **State Management:** For the optimistic UI (appending a new message instantly), I will just use a `StatefulWidget`'s `setState` on the local mock data since it's UI-only. Let me know if you prefer a specific state management approach (like Riverpod or Provider) even for the mock layer.

## Verification Plan
- Ensure all screens are fully navigable and look visually complete.
- Verify the search bar filters conversations properly based on mock data.
- Verify sending a message in the chat screen adds a new message bubble to the list immediately.
- Check that TODOs are placed properly for future backend integration.
