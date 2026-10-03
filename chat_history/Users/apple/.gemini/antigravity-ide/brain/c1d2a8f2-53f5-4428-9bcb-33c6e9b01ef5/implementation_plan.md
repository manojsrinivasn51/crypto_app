# Integration of `gp_image_store` & Verification of `ont_power_store`

This plan details the steps required to verify the integration of `/ont_power_store` and implement the binary file/media upload system for the POP survey module targeting the `/gp_image_store` endpoint.

## User Review Required

> [!IMPORTANT]
> The shared components `ImagePickerList`, `VideoPicker`, and `SingleImagePicker` are shared with other modules (such as Installation & Commissioning, Trench, etc.). 
> To integrate the POP upload system without breaking these modules, we will:
> 1. Refactor these widgets to accept optional `onUpload` callback overrides and `isUploading` flags.
> 2. Introduce a safe fallback: if `onUpload` is null but `popProvider.currentSurvey != null`, they automatically route the upload to `PopRepository().uploadPopImage` and watch `PopProvider.isUploadingDocument`.
> 3. This ensures POP screens get automatic upload capability without modifying 70+ calling widget locations, while other modules maintain their existing behaviors.

## Proposed Changes

### POP Repositories & Utilities

#### [MODIFY] [pop_repository.dart](file:///Users/apple/Desktop/bsnl_survey_flutter/lib/repositories/pop_repository.dart)
- Implement `uploadPopImage` method:
  - Takes `ImageData` as input, gets `survey_id`, `latitude`, `longitude`, `file` binary data, and optional `type` parameter.
  - Builds `dio.FormData` and POSTs to `pop/gp_image_store` endpoint.
  - Updates `popProvider.isUploadingDocument` during execution to handle loading state.
- Ensure `ont_power_store` is correctly mapped via `saveForm(payload, '/ont_power_store')` which routes to `pop/ont_power_store`.

---

### Common Reusable Widgets

#### [MODIFY] [image_picker_list.dart](file:///Users/apple/Desktop/bsnl_survey_flutter/lib/common/widgets/image_picker_list.dart)
- Refactor the constructor and helper builders to accept optional `onUpload` and `isUploading` parameters.
- Inside `_ImagePickerContent`, retrieve uploading status using a reactive builder:
  - If `isUploading` is passed, use it.
  - Otherwise, fallback: if `popProvider.currentSurvey != null` is true, use `context.watch<PopProvider>().isUploadingDocument`. Else, default to `context.watch<IcProvider>().isUploadingDoc`.
- Automatically resolve the upload method on new photo selection:
  - If `onUpload` is provided, use it.
  - Otherwise, fallback: if `popProvider.currentSurvey != null` is true, use `PopRepository().uploadPopImage`.

#### [MODIFY] [video_picker.dart](file:///Users/apple/Desktop/bsnl_survey_flutter/lib/common/widgets/video_picker.dart)
- Refactor the constructor and `_VideoPickerContent` to support optional `onUpload` and `isUploading`.
- Update progress/loading spinner to check for `isUploading` or use reactive fallback matching `ImagePickerList`.
- In `_handleVideoCapture`, trigger `onUpload` callback or the fallback POP upload method on captured videos.

#### [MODIFY] [single_image_picker.dart](file:///Users/apple/Desktop/bsnl_survey_flutter/lib/common/widgets/single_image_picker.dart)
- Refactor the constructor and `_SingleImagePickerContent` to accept optional `onUpload` and `isUploading`.
- Display a progress loader inside the preview container when `isUploading` or the POP fallback upload is active.
- In `_capturePhoto`, upload the captured image immediately before invoking the parent callback.

---

### POP Forms

#### [MODIFY] [pop_old_gp_upload_doc_screen.dart](file:///Users/apple/Desktop/bsnl_survey_flutter/lib/features/pop/view/forms/old_gp/pop_old_gp_upload_doc_screen.dart)
- Pass `onUpload: (img) => PopRepository().uploadPopImage(img, type: '8001')` to the `ImagePickerList` widget to mark these uploads as survey documents.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to verify compilation correctness and ensure no lint errors are introduced.

### Manual Verification
- We will inspect the code paths to verify that `saveForm(..., '/ont_power_store')` calls `pop/ont_power_store` correctly.
- Check that picker widgets correctly read from `PopProvider` when `popProvider.currentSurvey` is non-null.
