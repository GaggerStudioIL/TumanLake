# Tuman Lake BETA_PREFLIGHT

Дата: 2026-06-09
Версия: v0.1.0-beta.2
Commit: 3663b56 (`docs: add zbt readiness audit`) - build/preflight commit before this docs-only report
APK: `TumanLake_0.1.0_beta2_debug.apk`

## Result

CONDITIONAL PASS

## Checks

- Repository clean: PASS. `master` fetched and matches `origin/master`; working tree was clean before generating this report.
- Version synced: PASS. `GameVersion.VERSION=0.1.0-beta.2`; Android APK metadata reports `versionName=0.1.0-beta.2`, `versionCode=102`.
- BuildConfig beta flags: PASS. `IS_BETA_BUILD=true`, `ENABLE_DEBUG_PANEL=false`, `ENABLE_VERBOSE_LOGS=false`, `ENABLE_SPINNING_FEATURES=false`.
- Godot smoke: PASS. Normal project smoke start exited with code `0`; no `SCRIPT ERROR` found. Main scene startup path did not fail or hang in the local smoke run.
- Android export: PASS. Fresh debug/beta APK exported successfully; Godot export reached signing and verification; `apksigner verify --verbose --print-certs` passes with v2/v3 signatures.
- Android install smoke: ANDROID TAP-THROUGH NOT EXECUTED. `adb devices -l` reported no attached Android device or running emulator.
- Full route tap-through: ANDROID TAP-THROUGH NOT EXECUTED. The full route was not manually run on Android in this preflight.
- Save/load after restart: ANDROID TAP-THROUGH NOT EXECUTED. Save/load was not verified on Android after process restart in this preflight.

APK details:

- Path: `C:\Games\TumanLake\TumanLake_0.1.0_beta2_debug.apk`
- Size: `324298967` bytes
- SHA-256: `18306421F964ABA5E69E7122E3FBF4DAD6EB06B90B8A1E94CD04D5C26AC34BA7`
- Package: `com.tumanlake.game`
- Label: `Tuman Lake`
- Native code: `arm64-v8a`
- Min/target SDK: `24` / `35`

## Blockers

none found in repository/version checks, Godot smoke, Android export, APK metadata, or APK signature verification.

Important condition: Android install smoke and full tap-through were not executed because no device/emulator was available through adb.

## Non-blocking risks

- Godot smoke still prints existing anchor warnings and resource/RID leak messages on exit with `--quit-after`. The run exits with code `0` and no `SCRIPT ERROR`, so this is logged as noise/risk rather than a beta blocker.
- `aapt2 dump badging` succeeds but warns about a missing `mipmap/themed_icon` path. APK export/signature verification still pass.
- Visible sun disc remains intentionally hidden in the current beta-safe day/night composition; lighting/glow/reflection are used instead.
- Android gameplay route still needs one real-device manual smoke before tester distribution.

## Decision

Можно ли отправлять APK тестерам:
YES, but only after manual Android smoke

Этот билд можно отдавать тестерам только после короткой ручной проверки на Android, потому что репозиторий, версия, beta-флаги, Godot smoke, APK export, metadata и подпись прошли, но установка APK и полный tap-through на устройстве в этом preflight не выполнялись.
