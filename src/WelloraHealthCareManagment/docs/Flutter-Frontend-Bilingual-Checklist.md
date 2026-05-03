# Flutter Frontend Bilingual Implementation Checklist

## 1. Goal

This checklist is for the Flutter team.

Its purpose is to make the Flutter app work correctly with the bilingual backend that now supports:

- saved user language preference
- Arabic and English API messages
- Arabic and English notifications
- Arabic and English emails
- Arabic and English backend formatting

The Flutter app must now handle:

- interface translation
- RTL/LTR switching
- font switching
- language persistence in app state
- syncing with backend language preference

---

## 2. Backend Contract

Flutter should use these backend behaviors:

### Get current language

```http
GET /api/settings/language
Authorization: Bearer <token>
```

Example response:

```json
{
  "language": "ar",
  "isRightToLeft": true,
  "supportedLanguages": ["en", "ar"]
}
```

### Update current language

```http
PUT /api/settings/language
Authorization: Bearer <token>
Content-Type: application/json

{
  "language": "en"
}
```

### Optional for unauthenticated requests

Flutter should send:

- `Accept-Language`
- or `X-App-Language`

Example:

```http
Accept-Language: ar
X-App-Language: ar
```

---

## 3. Flutter Package Checklist

Install or confirm:

- `flutter_localizations`
- `intl`
- state management package already used by your app:
  - `provider`
  - `riverpod`
  - `bloc`
  - or equivalent
- local persistence package:
  - `shared_preferences`
  - or secure/local storage already used in the project

Optional but useful:

- `easy_localization`

If your project already has a localization pattern, keep it. Do not introduce a second competing system.

---

## 4. Translation Resource Checklist

Create localization files:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`

Minimum required categories:

- auth
- onboarding
- settings
- home
- doctor profile
- patient profile
- appointments
- reminders
- notifications
- payments
- reviews
- support tickets
- admin if frontend includes admin screens
- common buttons and dialogs
- loading and empty states

Example:

```json
{
  "@@locale": "en",
  "settingsLanguage": "Language",
  "settingsEnglish": "English",
  "settingsArabic": "Arabic",
  "loginTitle": "Login",
  "emailLabel": "Email",
  "passwordLabel": "Password",
  "saveButton": "Save",
  "cancelButton": "Cancel"
}
```

```json
{
  "@@locale": "ar",
  "settingsLanguage": "اللغة",
  "settingsEnglish": "الإنجليزية",
  "settingsArabic": "العربية",
  "loginTitle": "تسجيل الدخول",
  "emailLabel": "البريد الإلكتروني",
  "passwordLabel": "كلمة المرور",
  "saveButton": "حفظ",
  "cancelButton": "إلغاء"
}
```

Checklist:

- no hardcoded visible UI text remains
- each screen uses translation keys only
- no mixed Arabic/English labels unless intentional

---

## 5. App Architecture Checklist

Create one app-wide language controller.

Recommended responsibilities:

- current locale
- current text direction
- selected language code
- loading/saving from local storage
- syncing with backend after login
- switching locale at runtime

Recommended structure:

- `LanguageState`
- `LanguageController` or `LanguageNotifier`
- `LanguageRepository`
- `SettingsApiService`

Checklist:

- one source of truth for locale
- no screen manages its own locale separately
- locale changes trigger full rebuild at app level

---

## 6. MaterialApp Configuration Checklist

Your root app should configure:

- `locale`
- `supportedLocales`
- `localizationsDelegates`
- generated localization delegate

Checklist:

- `Locale('en')`
- `Locale('ar')`
- Flutter localization delegates included
- app rebuilds when language changes

Expected behavior:

1. user changes language
2. root locale changes
3. whole app re-renders
4. text direction updates automatically

---

## 7. Startup Flow Checklist

On app startup:

### Before login

1. load locally saved language from device storage
2. use it immediately for splash/bootstrap
3. if none exists:
   - use device locale if supported
   - otherwise fallback to English

### After login

1. call `GET /api/settings/language`
2. compare backend language with local app locale
3. if different:
   - update app locale to backend language
4. save backend language locally too

Checklist:

- no visible language flicker after login
- no app restart required
- backend language wins for authenticated users

---

## 8. Language Switch Screen Checklist

In Flutter settings screen:

- add a language tile or section
- allow:
  - English
  - العربية

When user changes language:

1. update app locale immediately
2. update font theme immediately
3. update direction immediately
4. call backend `PUT /api/settings/language`
5. save selected language locally

If backend call fails:

- keep UI consistent
- show localized error
- optionally retry or revert based on product decision

Checklist:

- switch works without restart
- switch updates all open screens
- switch survives app relaunch

---

## 9. API Client Checklist

Flutter API layer should send language headers consistently.

For every request, send:

- `Accept-Language`
- `X-App-Language`

Value:

- `en`
- `ar`

Checklist:

- attach language header in shared HTTP client or interceptor
- do not set language manually per screen
- after user changes language, all future requests use the new header automatically

This helps:

- public endpoints
- unauthenticated endpoints
- backend message consistency

---

## 10. Backend Message Handling Checklist

The backend now returns localized `message` and `error` values.

Flutter should:

- display backend success messages as returned
- display backend error messages as returned
- avoid re-translating backend business messages

Do:

- show snackbar/dialog/toast with backend `message`
- show form/server errors using returned backend `error`

Do not:

- map backend English text to local Flutter text manually
- hardcode assumptions about backend messages

Checklist:

- booking flow displays backend localized messages
- payment flow displays backend localized messages
- verification flow displays backend localized messages
- moderation/support flows display backend localized messages

---

## 11. RTL Checklist

Arabic requires RTL support.

Flutter usually helps automatically, but the app still needs visual review.

Checklist:

- `Directionality` follows locale
- `TextAlign` is correct where custom widgets override defaults
- custom rows/cards still look correct in RTL
- back arrows and leading/trailing icon placement are correct
- drawers and side menus behave correctly
- tab bars and segmented controls remain readable
- forms look correct in Arabic
- search bars and chips align properly
- tables and horizontally scrollable lists remain usable

Pay extra attention to:

- custom `Row`
- `Alignment.centerLeft`
- `EdgeInsets.only(left: ...)`
- icon padding based on left/right instead of start/end

Prefer:

- `EdgeInsetsDirectional`
- `AlignmentDirectional`
- `TextAlign.start`

---

## 12. Font Checklist For Flutter

Recommended font pair:

- English: `Inter`
- Arabic: `Cairo`

Alternative Arabic fonts:

- `Tajawal`
- `Noto Sans Arabic`

Checklist:

- define both fonts in `pubspec.yaml`
- load them through app theme
- switch font family based on locale
- keep font change centralized in theme layer

Example strategy:

- English locale uses `Inter`
- Arabic locale uses `Cairo`

Font behavior checklist:

- Arabic text not clipped
- Arabic buttons not overflowing
- headings not truncated after switch
- line height comfortable in Arabic
- tables remain readable

Recommended typography rule:

- English body line-height around `1.4` to `1.6`
- Arabic body line-height around `1.6` to `1.8`

---

## 13. Theme Checklist

Flutter should derive theme from locale.

Recommended:

- one base color system
- one locale-aware typography theme
- locale-aware font family

Checklist:

- language switch updates `ThemeData`
- locale switch updates typography cleanly
- no mixed fonts in same screen unless intentional

If the app supports dark mode too:

- test Arabic in both light and dark themes

---

## 14. Screen Conversion Checklist

Convert screens in this order:

1. authentication screens
2. splash/onboarding
3. home
4. search
5. doctor profile
6. patient profile
7. appointments
8. reminders
9. payments
10. notifications
11. support tickets
12. settings
13. admin screens if included

For each screen:

1. replace hardcoded text
2. verify Arabic translation
3. verify English translation
4. verify RTL layout
5. verify font rendering
6. verify backend messages display correctly

---

## 15. Forms And Validation Checklist

Flutter frontend should localize:

- required field messages
- email validation messages
- password rules
- confirmation messages
- dialog buttons

If validation is local:

- use Flutter translation resources

If validation comes from backend:

- display backend message as-is

Checklist:

- no English-only validation left in Arabic mode
- no Arabic-only validation left in English mode

---

## 16. Notifications Checklist

If Flutter app has:

- push notifications
- in-app notification center
- real-time notification toasts

Then:

1. display notification title/body exactly as backend sends them
2. do not rebuild notification wording on client
3. apply correct text direction and font

Checklist:

- Arabic notification title renders in Arabic font
- English notification title renders in English font
- notification list items align correctly in RTL

---

## 17. Date, Time, And Number Checklist

Backend already localizes many generated strings.

Flutter should decide this rule:

### If backend returns formatted display text

- show it exactly as returned

### If backend returns raw values only

- Flutter formats them according to current locale

Be consistent.

Checklist:

- do not format the same value twice
- do not mix backend-formatted and frontend-formatted styles randomly
- define one rule per field type

Examples to standardize:

- appointment time
- reminder time
- dashboard chart labels
- payment amounts
- ticket timestamps

---

## 18. Offline And Persistence Checklist

Flutter should cache selected language locally.

Checklist:

- language survives app restart
- language survives token refresh
- app opens in last selected language before network calls finish

If user logs out:

Decide product behavior:

Option 1:

- keep last selected device language locally

Option 2:

- reset to device default

Recommended:

- keep last selected language locally for smoother UX

---

## 19. Testing Checklist For Flutter QA

### Functional

- language switch changes immediately
- app restarts in last selected language
- backend preference stays in sync
- public endpoints respect `Accept-Language`

### UI

- Arabic screens fully RTL
- English screens fully LTR
- no clipped Arabic text
- no overflow in buttons/cards/tabs
- no broken spacing after switch

### Content

- backend messages appear in selected language
- notifications appear in selected language
- email-triggering flows tested from backend side

### Regression

- login flow still works
- registration flow still works
- booking flow still works
- payment flow still works
- ticket flow still works
- profile completion flow still works

---

## 20. Suggested Flutter File Structure

Example only:

```text
lib/
  l10n/
    app_en.arb
    app_ar.arb
  core/
    localization/
      language_controller.dart
      language_state.dart
      app_locale.dart
    theme/
      app_theme.dart
      app_typography.dart
  data/
    services/
      settings_api_service.dart
    repositories/
      language_repository.dart
  presentation/
    settings/
      language_settings_tile.dart
```

Keep this aligned with your existing architecture if you already have a structure in place.

---

## 21. Final Flutter Implementation Order

Recommended order:

1. add localization framework
2. add ARB files
3. add global language state
4. wire `MaterialApp` locale
5. add local persistence
6. add backend sync with `/api/settings/language`
7. add request language headers
8. add RTL-safe layout utilities
9. add locale-based font switching
10. convert screens one by one
11. run bilingual QA pass

---

## 22. Definition Of Done

Flutter side is considered complete when:

1. all visible UI text is localized
2. Arabic layout is RTL-correct
3. English layout is LTR-correct
4. locale switches without restart
5. language persists between sessions
6. backend messages display in correct language
7. notifications display in correct language
8. fonts switch correctly with locale
9. Arabic typography is readable and not clipped
10. no major flow breaks after localization
