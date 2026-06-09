# Tuman Lake — Beta Stabilization Follow-up

Дата: 2026-06-09

## Scope

Follow-up к `docs/beta_audit_report_2026_06_09.md`. Цель прохода — закрыть must-fix перед tester APK без новых больших фич, редизайна Inventory, rig presets или изменения баланса.

## Fixed

- Синхронизирована версия beta.2: `GameVersion.BUILD_DATE`, README, changelog и Android export preset.
- Android APK export path приведён к `build/TumanLake_0.1.0-beta.2_2026-06-09.apk`; Android `version/name` больше не использует старую Alpha-строку.
- Добавлен `docs/TESTER_GUIDE.md` с обязательными сценариями ЗБТ и форматом баг-репорта.
- Help screen обновлён под текущий beta flow: магазин/Рыбная гавань через карту, садок как просмотр улова, продажа через Рыбную гавань.
- HUD текущей снасти больше не обещает список готовых снастей: тап показывает текущую снасть, долгий тап открывает сборку.
- Popup текущей снасти оставлен в минимальном виде: `Редактировать` и `Закрыть`.
- В QuickTacklePanel убран дублированный guard с mojibake-текстом.
- В садке уточнён visible hint: продажа улова доступна в Рыбной гавани.
- В checklist/changelog зафиксировано, что садок не продаёт рыбу, расходники скрыты в beta scope, а текущая day/night-композиция не обещает видимый диск солнца.
- Убран мёртвый код после `profile_ui.open()` в `_open_profile()`.
- Убрано двойное присваивание текста кнопки `К водоёмам`; добавлен TODO для будущего глобального map naming.

## UI Kit / Export Inclusion

- `TumanLakeUIKit.gd` использует runtime root `res://assets/ui/tuman_lake_ui_kit_v1/`.
- Проверены 32 базовые runtime-текстуры, используемые адаптером Inventory/UI Kit.
- Preview-файл `tuman_lake_ui_kit_v1_preview.png` не используется runtime-кодом.
- `export_filter="all_resources"` оставлен включённым.
- В APK найдены импортированные UI Kit resources, включая `window_large`, `btn_primary_normal` и `slot_selected`.

## Android APK

- Godot smoke: exit code `0`, без SCRIPT ERROR.
- Android export: success.
- Output: `build/TumanLake_0.1.0-beta.2_2026-06-09.apk`.
- Size: `324298967` bytes.
- Export log: `Signing debug APK` и `Verifying APK` пройдены.

## Still Needs Manual Test

- Установка APK на Android-устройство.
- Запуск после установки и прохождение intro/Main.
- Полный цикл ловли: заброс -> поклёвка -> подсечка -> вываживание -> садок.
- Садок как viewer и продажа через Рыбную гавань.
- Save/load после покупки, смены снасти и поимки рыбы.
- Inventory v2 на 960x540 и широком окне.
- Магазин/Рыбная гавань через карту водоёма.

## Deferred

- Saved rig presets / список готовых снастей.
- Переименование глобальной карты в `Карта мира` / `Мир`.
- Видимый диск солнца как отдельный визуальный слой, если он будет нужен по design intent.

## New Blockers

- Новых blocker-ов после прохода не найдено.
- В Godot smoke остаются существующие warnings про anchors и ресурсы при `--quit-after`; export APK они не заблокировали.
