# Tournament Organizer

A Flutter web app for community tournaments, backed by Firebase Authentication and Cloud Firestore. Supports FIFA, Tekken, Carrom, and Pickleball, with team creation, groups, round-robin matches, score entry, standings, and player profiles.

## Midnight Court UI

The shared design lives in `lib/utils/theme_data.dart`:

| Role | Color |
| --- | --- |
| Background | `#101820` |
| Cards and menus | `#1B2732` |
| Primary action | `#D4F45B` |
| Primary text | `#F4F7EF` |
| Secondary text | `#A7B4C2` |
| Dividers | `#344453` |

Inter is used for UI text and Barlow Condensed for headings and scores. Fonts are bundled under `assets/fonts`; their Open Font Licenses are included there. Reusable layout, status, branding, and empty-state components are in `lib/widgets/court_widgets.dart`.

## Run locally

Requires Flutter compatible with Dart 3.8.1 or later.

```sh
flutter pub get
flutter run -d chrome
```

The app connects to the existing Firebase project configured in `lib/main.dart`. Use a development Firebase project before testing changes that write tournament data.

## Validate

```sh
flutter analyze
flutter test
```

Widget tests use local fixtures, covering responsive layouts at 320, 768, and 1280 pixels, form validation, tournament tabs, score-dialog cancellation, and grouping. They do not write to Firebase.

## GitHub Pages

Build with the repository's existing base path:

```sh
flutter build web --release --base-href /tournamentOrganizer/
```

After reviewing the build, publish it using the existing gh-pages dependency:

```sh
npm install
npx gh-pages -d build/web
```

Firebase initializes through Flutter. The web entry point only provides the app's initial background and loading state; it does not load a second Firebase SDK.
