# Рыбное Место — Android Build Notes

Этот документ описывает базовый порядок подготовки Android beta-билда для тестеров.

## 1. Перед сборкой

Перед каждой Android-сборкой пройти:

- `docs/BETA_PREFLIGHT.md`
- проверить `git status --short`
- проверить актуальность версии в `scripts/core/GameVersion.gd`
- проверить beta/debug флаги в `scripts/core/BuildConfig.gd`

Команды:

```bash
git status --short
git log --oneline -5
```

## 2. Версия и beta-флаги

Перед экспортом проверить:

- `GameVersion.VERSION` соответствует имени APK/AAB.
- `GameVersion.BUILD_NAME` соответствует текущему beta-билду.
- `GameVersion.BUILD_DATE` соответствует дате сборки.
- `BuildConfig.IS_BETA_BUILD = true`.
- `BuildConfig.ENABLE_ALPHA_TESTER_BONUS = false`.
- `BuildConfig.ENABLE_DEBUG_PANEL = false`.
- `BuildConfig.ENABLE_VERBOSE_LOGS = false`.

## 3. Export preset

В Godot открыть:

```text
Project -> Export
```

Проверить Android preset:

- выбран правильный Android export preset;
- включены нужные архитектуры;
- package name не изменён случайно;
- version/name соответствуют текущему beta-билду;
- основной запуск идёт через `res://scenes/intro/IntroCinematic.tscn`;
- build создаётся из актуальной ветки.

## 4. Подпись билда

Для debug-сборки:

- можно использовать debug signing;
- имя файла должно содержать номер версии.

Для release/internal beta:

- использовать правильный keystore;
- не коммитить keystore и пароли;
- после сборки проверить подпись APK/AAB.

## 5. Что не коммитить

Не добавлять в Git:

- `build/`
- `saves/`
- `.godot/`
- `.import/`
- `*.apk`
- `*.aab`
- `*.idsig`
- `*.keystore`
- локальные логи
- временные файлы редакторов/терминала

Эти правила должны оставаться в `.gitignore`.

## 6. После сборки

Проверить собранный APK/AAB:

- файл создан из правильного commit;
- имя файла содержит версию;
- размер файла выглядит ожидаемо;
- подпись проверяется без ошибок;
- билд устанавливается на тестовое устройство;
- старый билд корректно обновляется или удаляется перед установкой.

## 7. Smoke test на устройстве

После установки проверить:

- игра запускается без чёрного экрана;
- intro запускается или корректно пропускается;
- Main-сцена открывается;
- системное меню показывает версию;
- кнопка “Сообщить о баге” открывает инструкцию;
- Озеро Агамим доступно;
- можно выбрать точку ловли;
- можно сделать заброс;
- поклёвка и вываживание запускаются;
- пойманная рыба попадает в садок;
- магазин и инвентарь открываются;
- сохранение загружается после перезапуска.

## 8. Перед отправкой тестерам

- Обновить `docs/CHANGELOG.md`, если в билде есть новые изменения.
- Убедиться, что `docs/BETA_CHECKLIST.md` актуален.
- Передать тестерам номер версии и changelog.
- Напомнить тестерам, что основной beta-водоём — Озеро Агамим.
- Попросить прикладывать скриншот системного меню с версией при баг-репорте.

## 9. 2026-06-09 beta.2 debug export smoke

Команда:

```bash
Godot_v4.6.2-stable_win64_console.exe --display-driver windows --rendering-driver opengl3 --path . --export-debug Android build/RybnoeMesto_0.1.0-beta.2.apk
```

Результат:

- APK собран: `build/RybnoeMesto_0.1.0-beta.2.apk`.
- Размер: `324298967` bytes.
- Godot export дошёл до `Signing debug APK` и `Verifying APK` без ошибки.
- Android preset обновлён на `version/name="0.1.0-beta.2"` и `version/code=102`.
- `export_filter="all_resources"` оставлен включённым; UI Kit v1 ресурсы попали в APK как импортированные Godot resources.
- Установка на устройство и save/load на устройстве ещё требуют ручной проверки.

Примечание:

- Первый export внутри sandbox упал из-за недоступных путей Godot/AppData и Android SDK/editor templates; повтор вне sandbox успешно собрал APK.

## 10. 2026-06-23 beta.3 debug export prep

Команда:

```bash
Godot_v4.6.2-stable_win64_console.exe --display-driver windows --rendering-driver opengl3 --path . --export-debug Android build/RybnoeMesto_0.1.0-beta.3_v547.apk
```

Перед экспортом проверено:

- `GameVersion.VERSION="0.1.0-beta.3"`.
- `GameVersion.BUILD_NAME="HUD and Cast Control Refresh"`.
- `GameVersion.BUILD_DATE="2026-06-23"`.
- `BuildConfig.IS_BETA_BUILD = true`.
- `BuildConfig.ENABLE_ALPHA_TESTER_BONUS = false`.
- `BuildConfig.ENABLE_DEBUG_PANEL = false`.
- `BuildConfig.ENABLE_VERBOSE_LOGS = false`.
- Android preset обновлён на `version/name="0.1.0-beta.3"` и `version/code=547`.
- Android preset экспортирует `build/RybnoeMesto_0.1.0-beta.3_v547.apk`.
- `exclude_filter` исключает неигровые папки и артефакты: `landing`, `tools`, `docs`, `build`, `saves`, source-only `assets/ui/cast_depth/psd_layers_raw`, неиспользуемые cast-depth промежуточные PNG, старые APK/AAB/IDSIG/keystore и future-scope spinning art.

После экспорта проверить:

- Godot export дошёл до `Signing debug APK` и `Verifying APK` без ошибки.
- APK существует по пути `build/RybnoeMesto_0.1.0-beta.3_v547.apk`.
- `apksigner verify --verbose --print-certs` проходит без ошибок.
- `aapt2 dump badging` показывает `versionName='0.1.0-beta.3'` и `versionCode='547'`.
- Установка на устройство и короткий tap-through остаются обязательной ручной проверкой перед отправкой тестерам.

## 11. Blocker для отправки

Не отправлять билд, если:

- есть `SCRIPT ERROR`;
- игра не запускается;
- системное меню не открывается;
- версия билда не видна;
- не работает сохранение;
- нельзя начать рыбалку;
- собран не тот commit;
- APK/AAB не устанавливается на тестовое устройство.
