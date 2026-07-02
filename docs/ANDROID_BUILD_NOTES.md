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
- package id принят осознанно до публичной публикации;
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
Godot_v4.6.2-stable_win64_console.exe --display-driver windows --rendering-driver opengl3 --path . --export-debug Android build/RybnoeMesto_0.1.0-beta.3.apk
```

Перед экспортом проверено:

- `GameVersion.VERSION="0.1.0-beta.3"`.
- `GameVersion.BUILD_NAME="ZBT Cleanup Fixes"`.
- `GameVersion.BUILD_DATE="2026-06-23"`.
- `BuildConfig.IS_BETA_BUILD = true`.
- `BuildConfig.ENABLE_ALPHA_TESTER_BONUS = false`.
- `BuildConfig.ENABLE_DEBUG_PANEL = false`.
- `BuildConfig.ENABLE_VERBOSE_LOGS = false`.
- `BuildConfig.ENABLE_WATER_DEBUG_VISUALS = false`.
- `BuildConfig.SPINNING_ENABLED = false`.
- `BuildConfig.ENABLE_SPINNING_TEST_MODE = false`.
- Android preset обновлён на `version/name="0.1.0-beta.3"` и `version/code=547`.
- Android preset экспортирует `build/RybnoeMesto_0.1.0-beta.3.apk`.
- Android package id сейчас остаётся `com.tumanlake.game`.
- `exclude_filter` исключает неигровые папки и артефакты: `landing`, `tools`, `docs`, `build`, `saves`, source-only `assets/ui/cast_depth/psd_layers_raw`, неиспользуемые cast-depth промежуточные PNG, старые APK/AAB/IDSIG/keystore и future-scope spinning art.

Pre-release package id note:

- Если проект ещё не опубликован в Google Play, финальный package id стоит утвердить до первой публичной публикации. Рекомендуемый кандидат: `com.gaggerstudio.rybnoemesto`.
- Менять `package/unique_name` перед очередной beta без решения команды рискованно: Android будет считать новый package id другим приложением, установка поверх старой beta не сработает как обычное обновление.

После экспорта проверить:

- Godot export дошёл до `Signing debug APK` и `Verifying APK` без ошибки.
- APK существует по пути `build/RybnoeMesto_0.1.0-beta.3.apk`.
- Если `aapt2 dump badging` предупреждает про отсутствующий `res/mipmap-anydpi-v26/themed_icon.xml`, выполнить:
  `tools/patch_android_themed_icon.ps1 -ApkPath build/RybnoeMesto_0.1.0-beta.3.apk`.
- `apksigner verify --verbose --print-certs` проходит без ошибок.
- `aapt2 dump badging` показывает `versionName='0.1.0-beta.3'` и `versionCode='547'`.
- Установка на устройство и короткий tap-through остаются обязательной ручной проверкой перед отправкой тестерам.

## 11. 2026-06-30 beta.4 cast freeze hotfix export

Команда:

```bash
Godot_v4.6.2-stable_win64_console.exe --display-driver windows --rendering-driver opengl3 --path . --export-debug Android build/RybnoeMesto_0.1.0-beta.4.apk
```

Перед экспортом проверено:

- `GameVersion.VERSION="0.1.0-beta.4"`.
- `GameVersion.BUILD_NAME="Cast Freeze & Spinning Hotfix"`.
- `GameVersion.BUILD_DATE="2026-06-30"`.
- `BuildConfig.IS_BETA_BUILD = true`.
- `BuildConfig.ENABLE_ALPHA_TESTER_BONUS = false`.
- `BuildConfig.ENABLE_DEBUG_PANEL = false`.
- `BuildConfig.ENABLE_VERBOSE_LOGS = false`.
- `BuildConfig.SPINNING_ENABLED = true`.
- `BuildConfig.ENABLE_SPINNING_TEST_MODE = true`.
- Android preset обновлён на `version/name="0.1.0-beta.4"` и `version/code=548`.
- Android preset экспортирует `build/RybnoeMesto_0.1.0-beta.4.apk`.

Результат:

- APK собран: `build/RybnoeMesto_0.1.0-beta.4.apk`.
- Размер: `346581235` bytes.
- SHA-256: `21470A9F3725B7AB7221D43E638D338AA99E659501341C1B3272BC7B67DE59A1`.
- `aapt2 dump badging` показывает package `com.tumanlake.game`, `versionName='0.1.0-beta.4'`, `versionCode='548'`, `minSdkVersion='24'`, `targetSdkVersion='35'`.
- После экспорта выполнен `tools/patch_android_themed_icon.ps1 -ApkPath build/RybnoeMesto_0.1.0-beta.4.apk`.
- В APK присутствуют `res/mipmap-anydpi-v26/icon.xml` и `res/mipmap-anydpi-v26/themed_icon.xml`.
- `apksigner verify --verbose --print-certs` проходит без ошибок; подпись валидна по APK Signature Scheme v2/v3.

Ручная проверка перед отправкой:

- Установить APK на тестовое устройство.
- Проверить поплавочную ловлю: увеличенный поплавок, уход под воду, потерю крючка и длительную поклёвку без зависания нижнего меню.
- Проверить спиннинг: заброс, скорость подмотки 1-50, паузу, рывок, завершение поимки без старой окружности заброса и без отрыва катушки от удилища.

## 12. 2026-06-30 beta.5 catch reward layout hotfix export

Команда:

```bash
Godot_v4.6.2-stable_win64_console.exe --display-driver windows --rendering-driver opengl3 --path . --export-debug Android build/RybnoeMesto_0.1.0-beta.5.apk
```

Перед экспортом проверено:

- `GameVersion.VERSION="0.1.0-beta.5"`.
- `GameVersion.BUILD_NAME="Catch Reward Layout Hotfix"`.
- `GameVersion.BUILD_DATE="2026-06-30"`.
- `BuildConfig.IS_BETA_BUILD = true`.
- `BuildConfig.ENABLE_ALPHA_TESTER_BONUS = false`.
- `BuildConfig.ENABLE_DEBUG_PANEL = false`.
- `BuildConfig.ENABLE_VERBOSE_LOGS = false`.
- `BuildConfig.SPINNING_ENABLED = true`.
- `BuildConfig.ENABLE_SPINNING_TEST_MODE = true`.
- Android preset обновлён на `version/name="0.1.0-beta.5"` и `version/code=549`.
- Android preset экспортирует `build/RybnoeMesto_0.1.0-beta.5.apk`.

Результат:

- APK собран: `build/RybnoeMesto_0.1.0-beta.5.apk`.
- Размер: `359989623` bytes.
- SHA-256: `BF919974ABBB2248A9F87A1D025BE805067782E6B352FED5B091F61D79BC08C6`.
- `aapt2 dump badging` показывает package `com.tumanlake.game`, `versionName='0.1.0-beta.5'`, `versionCode='549'`, `minSdkVersion='24'`, `targetSdkVersion='35'`.
- После экспорта выполнен `tools/patch_android_themed_icon.ps1 -ApkPath build/RybnoeMesto_0.1.0-beta.5.apk`.
- В APK присутствуют `res/mipmap-anydpi-v26/icon.xml` и `res/mipmap-anydpi-v26/themed_icon.xml`.
- `apksigner verify --verbose --print-certs` проходит без ошибок; подпись валидна по APK Signature Scheme v2/v3.
- APK загружен в Vercel Blob: `https://82soys46zdxg7yh3.public.blob.vercel-storage.com/RybnoeMesto_0.1.0-beta.5.apk`.
- Лендинг собран через `npm run build` и задеплоен в production на Vercel; production bundle `https://fishingspotgame.com` содержит ссылку на APK beta.5.

Ограничения проверки:

- `adb devices -l` не показал подключённых Android-устройств, поэтому физическая установка APK и ручной tap-through в этом проходе не выполнялись.
- Godot smoke test завершился с кодом 0 без `SCRIPT ERROR`, но старые warnings про anchors и RID/resource leaks на выходе остаются.

Ручная проверка перед отправкой:

- Установить APK на Android-устройство.
- Проверить карточку пойманной рыбы на 960x540 и широком экране: пропорции 4:3, кнопки зачёта/отпускания, отсутствие перекрытий текста.
- Пройти короткий маршрут: запуск -> заброс -> поклёвка -> вываживание -> карточка улова -> зачёт или отпускание.

## 13. 2026-07-02 beta.6 spinning gear and tackle cleanup export

Команда:

```bash
Godot_v4.6.2-stable_win64_console.exe --display-driver windows --rendering-driver opengl3 --path . --export-debug Android build/RybnoeMesto_0.1.0-beta.6.apk
```

Перед экспортом проверено:

- `GameVersion.VERSION="0.1.0-beta.6"`.
- `GameVersion.BUILD_NAME="Spinning Gear & Tackle Cleanup"`.
- `GameVersion.BUILD_DATE="2026-07-02"`.
- `BuildConfig.IS_BETA_BUILD = true`.
- `BuildConfig.ENABLE_ALPHA_TESTER_BONUS = false`.
- `BuildConfig.ENABLE_DEBUG_PANEL = false`.
- `BuildConfig.ENABLE_VERBOSE_LOGS = false`.
- `BuildConfig.SPINNING_ENABLED = true`.
- `BuildConfig.ENABLE_SPINNING_TEST_MODE = false`.
- Android preset обновлён на `version/name="0.1.0-beta.6"` и `version/code=550`.
- Android preset экспортирует `build/RybnoeMesto_0.1.0-beta.6.apk`.

Результат:

- APK собран: `build/RybnoeMesto_0.1.0-beta.6.apk`.
- Размер: `364361682` bytes.
- SHA-256: `AFE609F3E037ED2FB6958A5AC7A0BF1FED8D4BA9F8B4C37C5D4E0108E83805E0`.
- `aapt2 dump badging` показывает package `com.tumanlake.game`, `versionName='0.1.0-beta.6'`, `versionCode='550'`, `minSdkVersion='24'`, `targetSdkVersion='35'`.
- После экспорта выполнен `tools/patch_android_themed_icon.ps1 -ApkPath build/RybnoeMesto_0.1.0-beta.6.apk`.
- В APK присутствуют `res/mipmap-anydpi-v26/icon.xml` и `res/mipmap-anydpi-v26/themed_icon.xml`.
- `apksigner verify --verbose` проходит без ошибок; подпись валидна по APK Signature Scheme v2/v3.
- APK загружен в Vercel Blob: `https://82soys46zdxg7yh3.public.blob.vercel-storage.com/RybnoeMesto_0.1.0-beta.6.apk`.
- HEAD-проверка APK URL вернула `200`, `Content-Length=364361682`, `Content-Type=application/vnd.android.package-archive`.
- Лендинг собран через `npm run build` и задеплоен в production на Vercel; production bundle `https://fishingspotgame.com` содержит ссылку на APK beta.6 и не содержит ссылку beta.5.

Ограничения проверки:

- `adb devices -l` не показал подключённых Android-устройств, поэтому физическая установка APK и ручной tap-through в этом проходе не выполнялись.
- Godot smoke test завершился с кодом 0 без `SCRIPT ERROR`, но старые warnings про anchors и RID/resource leaks на выходе остаются.
- `vercel build --prebuilt` на локальном Windows-окружении упал на `spawn cmd.exe ENOENT`; production deploy выполнен обычным `vercel deploy --prod`, remote build завершился успешно.

Ручная проверка перед отправкой:

- Установить APK на Android-устройство.
- Проверить магазин: вкладки “Удочки”, “Приманки”, “Катушки”, спиннинговые удилища, наборы приманок и level-lock.
- Проверить сборку спиннинга: удилище, катушка, леска, поводок и приманка; неподходящая катушка должна давать предупреждение/штрафы.
- Проверить спиннинг: заброс, пустая проводка без улова, возврат к нормальному UI и возможность сменить снасть.
- Проверить инвентарь: полностью сломанная неремонтируемая снасть удаляется и не остаётся экипированной.
- Проверить верхнюю XP-панель на телефоне: тап открывает таблицу уровня.

## 14. Blocker для отправки

Не отправлять билд, если:

- есть `SCRIPT ERROR`;
- игра не запускается;
- системное меню не открывается;
- версия билда не видна;
- не работает сохранение;
- нельзя начать рыбалку;
- собран не тот commit;
- APK/AAB не устанавливается на тестовое устройство.
