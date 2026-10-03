# Technical Work Experience Guide: Veremax HRM System

This document translates the code, architecture, and features of your **Veremax HRM Flutter** project into professional bullet points and technical skill sets. You can use this as a reference guide for your resume, LinkedIn profile, or to prepare for technical interviews.

---

## 🚀 Core Technologies & Skill Stack
When discussing this project, these are the core skills and tools you have successfully demonstrated:

*   **Framework:** Flutter & Dart (SDK 3.10+)
*   **Architecture Pattern:** Feature-Driven Architecture & Provider-based MVVM/MVCS
*   **State Management:** `provider` (Multi-provider setups, scoped state, reactive UI)
*   **Routing & Navigation:** Deep-linking and declarative routing via `go_router`
*   **Networking & API Integration:** `dio` (Interceptors, robust error handling, multipart file uploads)
*   **Data Modeling & Code Generation:** `freezed`, `json_serializable`, `build_runner` (Immutable states, deep copying, type-safe JSON parsing)
*   **Local Storage & Security:** `flutter_secure_storage` (Token management), `shared_preferences`
*   **Hardware & OS APIs:** `geolocator`, `camera`, `permission_handler`, `image_picker`
*   **Media Processing:** `flutter_image_compress`, `image_cropper`
*   **UI/UX:** `flutter_screenutil` (Responsive design), Slivers (Complex scrollable layouts), Custom Theming (Dark/Light mode)

---

## 💼 Resume Bullet Points

*Pick and choose the bullet points that best fit the role you are applying for:*

**Architecture & Code Quality**
*   Designed and implemented a highly modular, feature-first architecture in a large-scale Flutter application, separating logic across Models, Repositories, Providers, and Views to ensure scalability and ease of maintenance.
*   Utilized `freezed` and `json_serializable` for robust, type-safe data modeling, ensuring immutable state structures and eliminating runtime parsing errors.
*   Implemented declarative navigation and authentication guarding using `go_router`, strictly controlling user access based on dynamic authentication states.

**UI/UX & Frontend Development**
*   Engineered complex, highly performant UI layouts utilizing advanced Flutter mechanics such as `CustomScrollView`, `SliverMainAxisGroup`, and `SliverPersistentHeader` to build grouped, sticky-header directory lists.
*   Developed a responsive and pixel-perfect design system utilizing `flutter_screenutil`, centralized typography (`AppTypography`), and dynamic palettes supporting seamless Light/Dark mode transitions.
*   Built dynamic and complex multi-step forms (e.g., self-registration) with cross-field validation, conditional UI rendering, and localized error handling.

**Backend Integration & Optimization**
*   Built a robust API networking layer using `Dio`, handling multipart form data for document uploads, intercepting requests for token injection, and providing unified error catching.
*   Implemented custom search and filtering algorithms with intelligent relevance-scoring (prioritizing exact starting-letter matches) to provide a lightning-fast directory search experience on the client side.
*   Optimized application performance and bandwidth usage by integrating on-device image processing (`flutter_image_compress`, `image_cropper`) before transmitting media payloads to the backend.

**Device Features & Security**
*   Integrated native hardware features seamlessly, managing OS-level permissions via `permission_handler` to utilize camera access and GPS (`geolocator`) for secure attendance tracking.
*   Secured sensitive user data and authentication tokens persistently on the device using `flutter_secure_storage` utilizing encrypted keystores/keychains.

---

## 🎤 Interview Talking Points

If asked about your experience in an interview, here is how you can explain specific techniques you used in this project:

### 1. "How do you handle State Management?"
> "In my HRM project, I used `Provider` because it's native-feeling and scalable. I abstracted my logic into a Repository layer (for external API calls via Dio) and a Provider layer (to hold `isLoading` states and data). The UI strictly watches the provider. For instance, in the multi-step employee registration, the provider tracks the progress, cross-validates mobile numbers internally, and only signals the UI to advance when all conditions are met."

### 2. "Explain a time you built a complex UI."
> "I built the Employee Directory screen which lists employees grouped by their company. To make this performant and native-feeling, I couldn't just use standard ListViews. I utilized `CustomScrollView` with mapped `SliverMainAxisGroup` and `SliverPersistentHeader` delegates. This allowed me to create sticky headers for company names that smoothly push each other out of the way as the user scrolls, while keeping the overall tree flat and memory-efficient."

### 3. "How do you handle search / filtering locally?"
> "I wrote a custom relevance-based scoring algorithm. Rather than just filtering by `contains()`, which brings up chaotic results (like searching a name and getting someone else because their job title matched), my algorithm assigns points. If the string starts with the query, it gets 4 points. If it contains it, 3 points. If it matches an ID, 2 points. The list is then sorted descending by score. This resulted in a significantly better UX where direct name matches always float to the top."

### 4. "How do you handle forms and media?"
> "For profile photos and documents, I don't just send raw files to the server. I built a pipeline using `image_picker`, then routed the image to `image_cropper` for standardized aspect ratios, and finally ran it through `flutter_image_compress` to keep payloads under limits (e.g., 5MB). This pipeline happens entirely asynchronously before the `Dio` multipart upload triggers."
