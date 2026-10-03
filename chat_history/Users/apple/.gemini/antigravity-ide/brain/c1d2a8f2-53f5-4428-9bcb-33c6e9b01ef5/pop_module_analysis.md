# BSNL Survey Flutter — Project & POP Module Audit

> Audited: 2026-06-16 | Scope: full codebase review + POP module deep-dive

---

## Summary

The project is well-structured and follows established patterns (Provider, GoRouter, repository layer, shared widgets). The majority of the non-POP modules appear complete. **The POP module is partially done — routing and provider are wired correctly, but several form screens are placeholder stubs (`TODO` bodies) and there are a few logic inconsistencies that need fixing before the module can be considered complete.**

---

## 🔴 Critical Issues (must fix before release)

### 1. Stub / Placeholder Screens — 5 screens contain only `TODO` text

These screens are routed and reachable from the survey progress flow but show no actual form:

| Screen File | Route | Used For |
|---|---|---|
| `pop_ont_building_screen.dart` | `/pop-ont-building` | ONT type (5) & OLT type (6) — Building Data step |
| `pop_ont_power_screen.dart` | `/pop-ont-power` | ONT type (5), OLT type (6), BHQ type (1/4) — Power step |
| `pop_ont_information_sheet_screen.dart` | `/pop-ont-information-sheet` | ONT type (5) — Information step |
| `pop_bhq_information_sheet_screen.dart` | `/pop-bhq-information-sheet` | BHQ type (1/4) — Task Information step |
| `pop_information_sheet_screen.dart` | `/pop-information-sheet` | New GP (type 2) & OLT type (6) — Task Information step |

**Impact:** A field worker with an ONT, OLT, or BHQ survey cannot complete any information/power/building step — the form is just a `Center(child: Text('TODO …'))`.

> [!CAUTION]
> These 5 screens block real survey completions for ONT, OLT, and BHQ GP types.

---

### 2. Logic Bug — BHQ Progress Screen Uses Wrong `buildingCount` Getter

In `bhq_survey_screen.dart` and `survey_progress.dart` (type 1 or 4 branch), the **Building Data** step uses `survey?.ontBuildingCount` (the ONT building field-count getter) instead of a dedicated BHQ building counter. This means the progress indicator for the Building step is always wrong for BHQ surveys.

- **`bhq_survey_screen.dart` line 34:** `"count": survey?.ontBuildingCount ?? (0, 0, 0)`
- **`survey_progress.dart` line 88:** same issue in the type `1 || 4` branch

The `PopSurveyShots` model does store BHQ building data in `ontBuilding` (from `ont_building_store` endpoint), so the getter is technically mapping to the right JSON field — **but the naming is confusing and may break if the API field ever differs per type.** Needs a clarifying comment at minimum.

---

### 3. `survey_progress.dart` — BHQ Completion Flag Maps to Wrong Field (index 5)

In `survey_progress.dart` `completed()` for type `1 || 4`:
```dart
5 => survey?.isOltEquipmentDone,   // ← Uses OLT equipment flag
```
But in `bhq_survey_screen.dart` the same index 5 step is "Equipments in Building" routed to `popBhqEquipment`. The `isOltEquipmentDone` getter checks `oltEquipment != null` — this is likely correct since the BHQ equipment data maps to `olt_equipment` on the backend — but it should be verified. If the backend stores BHQ equipment under a different key, the completion badge will never turn green.

---

### 4. `filled` Getter — BHQ Does Not Include `isUploadDocumentsDone`

In `pop_survey_shots.dart` the `filled` getter for BHQ (type 4/1):
```dart
} else if (gp?.type == 4 || gp?.type == 1) {
  return isOntBuildingDone &&
      isPhysicalConditionDone &&
      isElectricalDone &&
      isOntPowerDone &&
      isInstallationRoomDone &&
      isOltEquipmentDone &&
      isInformationSheetDone;
      // ← Missing: isUploadDocumentsDone
}
```
But the BHQ survey screen (`bhq_survey_screen.dart`) **does include an Upload Documents step** (index 7, route `popOldGpUploadDoc`). The `Complete Survey` button will be enabled even if documents aren't uploaded.

---

## 🟠 Medium Issues

### 5. Duplicate Step Logic Between `survey_progress.dart` and `bhq_survey_screen.dart`

There are two separate screens (`SurveyProgress` and `BhqSruveyScreen`) that both define steps and a `completed()` function for BHQ types. The `popSurveyNotice` screen routes type `1 || 4` to `Routes.bhqSurvey`, but `survey_progress.dart` also has a branch for type `1 || 4`. This creates a maintenance risk — any change needs to be made in two places. Consider merging into one parameterised screen.

### 6. `completeSurvey` vs `completeOntSurvey` — ONT endpoint unused

`pop_repository.dart` has `completeOntSurvey()` which calls `pop/olt_complete_survey`, but both `survey_progress.dart` and `bhq_survey_screen.dart` call `PopRepository().completeSurvey()` (the generic endpoint) for **all** GP types including ONT and OLT. The `completeOntSurvey()` method is currently dead code. If the backend requires a different endpoint for ONT/OLT completion, this will silently use the wrong endpoint.

### 7. `saveBuilding` / `saveElectrical` / `saveEquipment` Unused Methods

`pop_repository.dart` contains `saveBuilding`, `saveElectrical`, `saveEquipment`, `saveNewGpBuilding`, `saveNewGPInstallationRoom`, `saveNewGpElectrical`, `saveOTDR`, `saveInformationSheet` — all older dedicated methods. All the actual screens now use the unified `saveForm(payload, endpoint)` method instead. These older methods are dead code but still call `getAssigned()` without `await`, which can cause race conditions if they ever get used again.

### 8. `providers.dart` — `AppPermissionProvider` Registered Twice

```dart
_createProvider(() => AppPermissionProvider()),  // line 42
_createProvider(() => AppPermissionProvider()),  // line 48 (duplicate)
```
This creates two separate instances. The `appPermissionProvider` global reference only points to one of them. The duplicate registration wastes memory and could cause subtle state-sync issues.

---

## 🟡 Minor / Polish Issues

### 9. `pop_ont_building_screen.dart` — BHQ Building Uses `ontBuilding` JSON Key

`PopBhqBuildingScreen._loadData()` reads from `popProvider.currentSurvey?.ontBuilding` and posts to `/ont_building_store`. This is shared with ONT building data. Since the model differs between ONT and BHQ, reading a BHQ building entry with the ONT model (or vice versa) could corrupt data if the same GP changes type. Needs a comment and ideally separate JSON keys per type.

### 10. `pop_survey_notice_screen.dart` — Hardcoded English Notice Points

The 17 survey notice bullet points are hardcoded English strings in Dart, not in ARB files. This breaks the localization promise (`context.l10n` everywhere else) and cannot be translated to Hindi/Kannada without code changes.

### 11. `survey_progress.dart` — Missing Equipment Step for New GP `filled` Check

In `filled` for New GP (type 2):
```dart
return isBuildingDone &&
    isPhysicalConditionDone &&
    isInstallationRoomDone &&
    isElectricalDone &&
    isUploadDocumentsDone;   // ← Missing isInformationSheetDone
```
But the New GP steps include an Information Sheet step. The Complete button becomes prematurely enabled.

### 12. `todo.md` — Pending Tasks

The project's own `documentations/todo.md` records several pending items:
- Background location flow
- Location in Team
- Stop location tracking on invalid token / day complete
- My Service Zones static (should use API)
- FCM for Manual Ticket
- Incident changes for FRT & Patroller

---

## ✅ What Is Fully Done and Wired Correctly

| Area | Status |
|---|---|
| POP routes (all 15 routes) | ✅ Registered in `navigation.dart` |
| `PopProvider` registered globally | ✅ In `providers.dart` |
| `PopRepository` — fetch, saveForm, uploadDoc, complete | ✅ Complete |
| `PopScreen` (list) | ✅ Fully implemented |
| `PopSurveyNoticeScreen` | ✅ Functional (minor l10n issue) |
| `SurveyProgress` for Old GP (type 3) | ✅ All steps + completion logic |
| `BhqSurveyScreen` for BHQ (type 1/4) | ✅ Steps wired; completion logic has issue #4 |
| Old GP forms (Building, Physical, Electrical, Installation, Equipment, Upload, Info Sheet) | ✅ All 7 fully implemented |
| BHQ forms (Building, Electrical, Equipment) | ✅ 3/4 implemented — Info Sheet is stub |
| ONT Equipment screen | ✅ Fully implemented |
| OLT Equipment screen | ✅ Fully implemented |
| `PopSurveyShots` model & JSON parsing | ✅ Complete with all field getters |
| Navigation / GoRouter wiring | ✅ All routes registered |
| `refreshCurrentSurvey()` after form save | ✅ Present in all screens |
| Read-only mode when survey is status 3 (Completed) | ✅ Implemented via `AbsorbPointer` |

---

## Recommended Fix Order

1. **Implement the 5 stub form screens** — ONT Building, ONT Power, ONT Information, BHQ Information Sheet, shared Information Sheet (highest impact)
2. **Fix `filled` getter** — add `isUploadDocumentsDone` to BHQ branch and `isInformationSheetDone` to New GP branch
3. **Fix `completeOntSurvey` usage** — call it for ONT/OLT types instead of the generic endpoint
4. **Remove duplicate `AppPermissionProvider` registration** in `providers.dart`
5. **Move notice bullet points to ARB files**
6. **Verify BHQ/OLT completion flag mapping** (issue #3) against the backend contract
