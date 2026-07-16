# SoloS (Flutter)

**SoloS (Solid OS)** — The Decentralized User Space & Runtime for the Solid Web.

This is the Flutter/Dart port of the original React app, so the same codebase runs
on **web, Windows, macOS, Linux, Android, and iOS**.

> Note: like the original React version, this is currently a UI prototype with
> in-memory (mock) state — there is no real Solid/WebID backend wired up yet.

## Run

```bash
# from this folder (solos_flutter/)

# Web (Chrome)
flutter run -d chrome

# Windows desktop
flutter run -d windows

# List available devices (phones, emulators, etc.)
flutter devices
flutter run -d <device-id>
```

## Build

```bash
flutter build web        # output in build/web
flutter build windows    # output in build/windows
flutter build apk        # Android
```

## Project structure

| File | Ports from React |
|------|------------------|
| `lib/main.dart` | `App.tsx` + `main.tsx` — root state (user / personas / installed apps) |
| `lib/theme.dart` | Tailwind color palette → Flutter `Color`s |
| `lib/models.dart` | `types.ts` — `Persona`, `SolidApp`, `InstalledApp` |
| `lib/data.dart` | `data.ts` — the repository app catalog |
| `lib/screens/login.dart` | `Login.tsx` |
| `lib/screens/dashboard.dart` | `Dashboard.tsx` |
| `lib/screens/repository.dart` | `Repository.tsx` |
| `lib/screens/app_runtime.dart` | `AppRuntime.tsx` |

## Test

```bash
flutter test
flutter analyze
```
