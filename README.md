# Property Listing

A Flutter property listing prototype with separate user and property-owner
experiences. The app uses deterministic local data while keeping the
presentation and domain layers independent from the storage implementation so
the local sources can later be replaced with a backend.

## Features

### Users

- Sign in with the demo user account.
- Browse 10 seeded properties.
- Search by property name or location.
- Filter by location, property type, price, area, status, and bedrooms.
- Sort by newest, price, or area.
- View property details by property ID.
- Submit an interest enquiry with validation.
- Save and remove favourite properties.

### Property owners

- Sign in with the demo owner account.
- View owner-specific property statistics.
- View owned properties and received enquiries.
- Add, edit, and delete owned properties.
- See persisted user interests for matching properties only.

## Architecture

The project follows feature-first Clean Architecture:

```text
Presentation (Pages, Widgets, BLoCs)
        |
        v
Domain (Entities, Repository Contracts, Use Cases)
        |
        v
Data (Repository Implementations, Models, Mappers, Data Sources)
        |
        v
Infrastructure (SharedPreferences, Secure Storage, Injectable)
```

Important boundaries:

- BLoCs depend on use cases rather than concrete repositories.
- Domain entities do not depend on Flutter, JSON models, or storage packages.
- Models are converted to entities through explicit mappers.
- SharedPreferences is accessed through `PreferencesService`.
- Sensitive session values are accessed through `SecureStorageService`.
- Dependency injection is configured with `get_it` and `injectable`.
- Navigation is handled by `go_router` with role-aware route guards.
- State management uses `flutter_bloc` BLo classes only; no Cubit is used.

## Technology stack

- Flutter 3.44.6 / Dart 3.12.2
- `flutter_bloc`
- `go_router`
- `get_it` and `injectable`
- `shared_preferences`
- `flutter_secure_storage`
- `equatable`
- `uuid`
- `intl`
- `dio` as a future networking boundary
- `bloc_test`, `mocktail`, and Flutter test utilities

## Folder structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   └── router/
├── core/
│   ├── constants/
│   ├── di/
│   ├── error/
│   ├── storage/
│   ├── theme/
│   └── widgets/
└── features/
    ├── auth/
    ├── favourites/
    ├── interests/
    ├── owner_dashboard/
    └── properties/
```

## Prerequisites

- Flutter SDK compatible with Dart 3.12.2.
- [FVM](https://fvm.app/) installed and available as `fvm`.
- Android Studio or Xcode, depending on the target platform.

The project has been validated with Flutter 3.44.6. To use that SDK through
FVM:

```bash
fvm install 3.44.6
fvm use 3.44.6
```

If the project is opened on a machine with a different compatible Flutter
version, use the corresponding FVM version consistently for all commands.

## Setup

```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
```

Generated Injectable files should be regenerated after changing dependency
registrations. Do not edit generated files manually.

## Run the app

```bash
fvm flutter run
```

The app seeds the local property collection only when no property collection
has been initialized. Existing properties, interests, and favourites are not
reset on every launch.

## Demo credentials

Select the matching role on the login screen.

| Role | Email | Password |
| --- | --- | --- |
| User | `user@propertydemo.com` | `User@123` |
| Property Owner | `owner@propertydemo.com` | `Owner@123` |

These credentials and all application data are for local demonstration only.
Passwords are never persisted. Session tokens are stored in secure storage.

## Testing and quality checks

Run the analyzer and test suite with FVM:

```bash
fvm flutter analyze
fvm flutter test
```

The current suite covers:

- Authentication and session restoration.
- Role-aware routing.
- Storage wrappers and dependency injection.
- Property seed data, models, mappers, repositories, and use cases.
- Search, filtering, and sorting.
- Property detail and form flows.
- Interest validation, persistence, and owner visibility.
- Favourites persistence.
- User and owner page/widget behavior.

The blueprint also calls for an end-to-end integration test covering user
login, property browsing, interest submission, logout, owner login, and owner
interest visibility. That integration test remains a follow-up deliverable;
the current automated coverage is unit and widget based.

## Release build

```bash
fvm flutter build apk --release
```

The generated Android APK is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Local data structure

The prototype uses these storage boundaries:

- `properties_json` — seeded and owner-managed properties.
- `interests_json` — submitted interest enquiries.
- `favourite_property_ids` — user favourite property IDs.
- Secure storage — access token, user ID, and role.
- Preferences — display name and other non-sensitive local values.

All storage keys are centralized in the core constants layer. Replacing the
local data sources with REST or database implementations should not require
changes to the presentation or domain contracts.

## Assumptions

1. All property and customer information is dummy data.
2. Authentication is simulated locally.
3. Only `USER` and `PROPERTY_OWNER` roles are required.
4. Owner `O001` owns enough seeded properties to demonstrate owner filtering.
5. Interests and favourites persist on the same device/app installation.
6. There is no real backend synchronization.
7. SharedPreferences is used for the assignment prototype behind abstractions.
8. Secure storage is used for session-sensitive values.
9. Property images are bundled placeholder assets.
10. In production, backend authorization must enforce ownership and access.

## Release APK Link

https://betadrop.app/app/n46ni8.

## Known prototype limitations

- Authentication is local and does not contact a real identity provider.
- Property and interest data is device-local and is not synchronized between
  devices.
- The integration test flow described by the blueprint has not yet been added.
- Images are bundled placeholders rather than remotely managed media.

## Future backend migration

The intended migration path is:

```text
DummyAuthDataSource       -> AuthRemoteDataSource
PropertyLocalDataSource   -> PropertyRemoteDataSource
InterestLocalDataSource   -> InterestRemoteDataSource
SharedPreferences records -> API or local database
Dummy access token        -> JWT/OAuth-backed session
```

The repository contracts, domain entities, use cases, and BLoCs are designed
to remain stable while those data-source implementations change.
