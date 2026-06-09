# Tuman Lake - beta audit report - 2026-06-09

Дата аудита: 2026-06-09
Фокус: текущая рабочая копия перед ЗБТ, без добавления новых фич и без переписывания UI.
Статусы: `OK`, `PARTIAL`, `BROKEN`, `MISSING`, `UNKNOWN`.

## Summary

- Всего проверено пунктов: 48
- `OK`: 25
- `PARTIAL`: 22
- `BROKEN`: 0
- `MISSING`: 1
- `UNKNOWN`: 0

Вывод: критических блокеров запуска Main-сцены не найдено. Godot smoke-запуск завершился с кодом `0`, без `SCRIPT ERROR` и без фатальных ошибок autoload. При этом текущая beta-ready картина не полностью чистая: есть несоответствия версий/документов/export preset, отсутствует заявленный tester guide, несколько заявленных UI-поведенческих пунктов реализованы только частично, а часть UI Kit-активов и скриптов сейчас лежит untracked.

Проверка выполнялась по текущему dirty worktree. Существующие изменения не откатывались и не чистились.

## Verification

- Проверены `README.md`, `docs/CHANGELOG.md`, `docs/BETA_CHECKLIST.md`, `docs/ANDROID_BUILD_NOTES.md`, `project.godot`, `export_presets.cfg`.
- Проверены основные скрипты HUD, карты, магазина, гавани, садка, инвентаря, снасти, Fishpedia, профиля, настроек, save/load, рыбалки и визуального окружения.
- Выполнен smoke-запуск:

```text
Godot_v4.6.2-stable_win64_console.exe --display-driver windows --rendering-driver opengl3 --path . --quit-after 2
```

Результат: exit code `0`. В логе есть много предупреждений `Nodes with non-equal opposite anchors...` по модальному слою и предупреждения/ошибки утечек ресурсов при завершении процесса. В рамках короткого `--quit-after` это не выглядело как блокер старта, но является техническим шумом, который стоит убрать до тестерского билда.

Android export не запускался: аудит ограничен статической проверкой preset, чтобы не создавать новый APK-артефакт в рамках report-first задачи.

## Critical Blockers

Критических блокеров не найдено.

Не обнаружено:
- фатального `SCRIPT ERROR` при запуске;
- падения autoload;
- отсутствия Android preset;
- полного отсутствия Main/HUD/карты/магазина/гавани/инвентаря/садка;
- включённых debug/alpha tester флагов в `BuildConfig`.

## Important Issues

1. Версии и артефакты не согласованы.
   `GameVersion` = `0.1.0-beta.2` с датой `2026-06-05`; `README` говорит `v0.1.0-beta.1`; changelog имеет `Next beta / unreleased` от `2026-06-09`; Android preset экспортирует `APK_TL_Alpha_0.5.4.4.apk` с `version/name="Alpha 0.5.4.4"`.

2. `docs/TESTER_GUIDE.md` заявлен в README и changelog beta.1, но файла в `docs` нет.

3. UI Kit v1 и связанные ассеты сейчас untracked.
   В рабочей копии есть `assets/ui/tuman_lake_ui_kit_v1*` и `scripts/ui/components/TumanLakeUIKit.gd`, но они не в git status как tracked. Clean checkout/build может потерять Inventory v2/UI Kit.

4. Тап по текущей снасти не является полноценным списком сохранённых/готовых снастей.
   Сейчас popup показывает заголовок `Готовая снасть`, текущую снасть и кнопку `Редактировать`. Списка пресетов/нескольких готовых rigs не найдено.

5. Садок больше не продаёт напрямую.
   Садок работает как просмотрщик улова; кнопка продажи/продать всё скрыта, а details-текст говорит, что продажа доступна в гавани. Если beta-чеклист ожидает продажу из садка, это расхождение.

6. Shop category `Расходники` скрыта в beta.
   Это выглядит осознанно через `BuildConfig.IS_BETA_BUILD`, но changelog в разделе "Что перепроверить" всё ещё просит проверять расходники в магазине.

7. День/ночь требует визуальной перепроверки.
   Профили окружения, луна, glow и отражение реализованы, но в `DayNightController.update_sun_position()` sprite солнца выставляется `visible = false` и alpha `0`. Это конфликтует с формулировками changelog про исправленную видимость солнца, если требуется именно видимый диск солнца.

8. Help и Settings покрывают не весь ожидаемый beta help/scope.
   Help в системном меню кратко описывает главный экран и быстрые действия, но не заменяет tester guide и не объясняет все ключевые beta-потоки. Settings содержит аудио/радио/vibration/intro, но не графику/управление/язык.

9. Android preset существует, но выглядит старым alpha preset.
   Есть package/icon/signing/arm64, но version/name/export_path не соответствуют текущей beta-линейке. Export/install/signature не проверялись в этом аудите.

## Minor Issues

- В `QuickTacklePanel.gd` есть mojibake-строка в сообщении о запрете смены снасти и дублирующийся guard `_can_change_tackle()`.
- В `WaterbodyVisualMapUI.gd` кнопке `waterbodies_button` дважды присваивается текст: сначала `Водоёмы`, затем `К водоёмам`.
- В `Main.gd` после `_open_profile()` есть старый недостижимый код после `return`.
- Godot smoke-запуск даёт много anchor warnings для модального слоя и окон. Не блокер, но засоряет лог тестера.
- Часть legacy UI-узлов всё ещё создаётся и скрывается runtime-логикой. Это нормально для совместимости, но усложняет аудит видимого состояния.

## Detailed Checklist

| Area | Feature | Status | Notes | Suggested action |
|---|---|---:|---|---|
| Startup | Project smoke launch | OK | Godot 4.6.2 запустил проект, Main `_ready` дошёл до HUD/UI setup, exit code `0`. | Оставить smoke в preflight; отдельно убрать warnings. |
| Beta config | Build flags | OK | `IS_BETA_BUILD=true`, alpha tester bonus/debug panel/verbose/water debug/spinning disabled. | Перед export перепроверить тем же списком. |
| Versioning | Version/docs consistency | PARTIAL | `GameVersion`, README, changelog и Android preset расходятся. | Синхронизировать перед APK. |
| Android | Export preset | PARTIAL | Android preset есть, arm64/icon/package/signing есть; version/name/export_path старые alpha. Export не запускался. | Обновить preset и выполнить export/install smoke. |
| Boot flow | Intro/Main scene | OK | `project.godot` запускает `IntroCinematic.tscn`; smoke дошёл до `Main.gd`. | Проверить skip/finish intro вручную на устройстве. |
| HUD | Left menu | OK | Runtime оставляет слева Inventory + Map; Shop/Harbor hidden и перенесены на карту. | Оставить. |
| HUD | Right menu | OK | Fishpedia, system menu, current rig, fishing action button формируются справа. | Проверить позиции на 960x540 и 1320x540. |
| HUD | Tuman FM/top clutter | OK | Tuman FM HUD создаётся скрытым, top legacy panels прячутся. | Оставить для beta. |
| Fishing button | Primary action states | PARTIAL | Есть `Заброс`/`Подсечь`/`Вытянуть`, guards от двойного действия и блокировка важных failure popup. Полный игровой цикл не прогонялся. | Ручной smoke: cast -> bite -> hook -> fight -> keep/release. |
| Cast | Charge, depth and distance | PARTIAL | Есть cast charge, проверка глубины падения, wind/float modifiers. Не проверено визуально. | Прогнать на разных точках и глубинах. |
| Current rig HUD | Label/update | OK | Кнопка показывает тип снасти и удочку, обновляется после quick/full tackle changes. | Оставить. |
| Current rig HUD | Tap quick list | PARTIAL | Тап открывает popup с текущей снастью и `Редактировать`, но не список нескольких готовых rigs/presets. | Либо реализовать preset list, либо переименовать/уточнить текст. |
| Current rig HUD | Long tap | OK | Long press вызывает `open_full_tackle_from_quick_panel()` и открывает сборку снасти. | Проверить на touch-device. |
| Quick rig | Quick component change | PARTIAL | `QuickTacklePanel` есть и умеет менять компоненты вне ловли, но это не сохранённые rigs. | Уточнить целевой UX быстрых снастей. |
| Rig builder | Full tackle builder | PARTIAL | Окно сборки, слоты, auto/equip/repair/discard/status есть; переход на универсальные слоты начат. Визуально не smoke-проверено. | Ручная проверка читаемости и сохранения смены. |
| Keepnet HUD | Counter/button | OK | Новый `KeepnetHudButton`, счётчик `inventory.size/max_items`, блокировка во время ловли. | Оставить. |
| Keepnet | Screen and fish details | PARTIAL | Садок открывается, показывает карточки/детали/пустое состояние. Прямая продажа скрыта, продажа перенесена в гавань. | Уточнить чеклист: садок = просмотр, гавань = продажа. |
| Catch result | Keep/release | OK | Рыба добавляется FishingManager, keep регистрирует stats, release удаляет из inventory, save вызывается. | Ручной smoke на catch popup. |
| Inventory | Inventory v2/UI Kit | PARTIAL | Новый шаблон и UI Kit используются, но UI Kit assets/scripts untracked. | Добавить в git или удалить зависимость перед билдом. |
| Inventory | Categories/filter/sort | OK | Категории, фильтры `Все/Надето/Не надето`, сортировка реализованы. | Оставить. |
| Inventory | Cards/details/actions | OK | Карточки, details panel, equip/repair/discard, status `Надето` реализованы. | Ручной visual pass. |
| Inventory | 5-6 cards/min two rows | PARTIAL | Код рассчитывает grid metrics и page size 24, но требование 5-6 в ряд/две строки не проверено скриншотами. | Проверить 960x540 и 1320x540. |
| Inventory | Fallback icons | OK | Есть fallback path/category и placeholder texture cache. | Оставить. |
| Shop | Open from waterbody map | OK | Map emits `shop_requested`, `WaterbodyUI` открывает `shop` через navigation/Main. | Проверить tap на карте. |
| Shop | Categories | PARTIAL | Наживки/удочки/лески/поводки/крючки/поплавки есть; `Расходники` hidden in beta. | Согласовать scope и changelog. |
| Shop | Scroll/no pager | OK | Pager скрывается, список в ScrollContainer, scroll reset after category switch. | Оставить. |
| Shop | Buy flow | OK | Проверка денег, списание, `PlayerData.add_owned_item`, save и notice реализованы. | Ручной buy smoke. |
| Harbor | Open from waterbody map | OK | Map emits `harbor_requested`, Main открывает `FishHarbor`. | Проверить tap на карте. |
| Harbor | Sale/buyers/contracts/reputation | PARTIAL | UI и сервисы продаж/контрактов/репутации есть, но end-to-end продажа не прогонялась. | Ручной smoke с рыбой в садке. |
| Waterbody map | Markers/current/select | OK | Карта водоёма, markers, `Вы тут`, info buttons, select flow через `PlayerData.set_current_*`. | Проверить все точки Агамима. |
| Global map | Future waterbodies | OK | Глобальная карта показывает locked/in-development reason и не меняет на недоступный водоём. | Оставить. |
| Spot info | Details/recommendations | OK | Глубина, тип, рыба, рекомендуемые поплавки/наживки/особенности выводятся. | Оставить. |
| Fishpedia | Open/filters/progress | OK | Фильтры caught/missing/common/rare/legendary, progress stats, modal flow есть. | Проверить после нескольких уловов. |
| Fishpedia | Data/images/details | OK | FishDatabase содержит описания/rarity/trophy/record/baits; unknown entries скрыты как `???`. | Оставить. |
| Profile | Progress/profile | PARTIAL | Профиль, навыки, помощь, рекорды/трофеи есть; отдельные achievements/news не найдены. | Не считать blocker, если не входит в beta scope. |
| Settings | Settings screen | PARTIAL | Есть источник музыки, музыка, radio, sfx, vibration, intro toggle. Нет графики/управления/языка. | Расширять только если требуется ЗБТ. |
| Help | System menu Help | PARTIAL | Краткое описание HUD/current rig/action есть. Нет полного tester guide и части подсказок по shop/harbor/keepnet/save. | Добавить tester-oriented help или восстановить guide. |
| System menu | Menu items | OK | В видимом меню профиль/settings/help; лишние achievements/news не видны. | Оставить. |
| Level-up | Reward popup | PARTIAL | Очередь наград, claim, save и блокировка закрытия есть. Не trigger-проверено. | Прогнать level-up и old save. |
| Save/load | Data coverage | PARTIAL | SaveManager сохраняет location, items, tackle, inventory, economy, audio/radio/gameplay, time. Restart test не выполнялся. | Обязательный device restart smoke. |
| Save/load | Old save and beta migration | OK | Старые/битые локации нормализуются, spinning items скрываются/чистятся из видимых списков. | Оставить. |
| Fishing loop | Bite/fight/catch/fail code | PARTIAL | FishingManager содержит cast/bite/fight/fail/catch flow; не прогонялся вручную. | Full gameplay smoke. |
| Failure popup | Break/loss acknowledgement | OK | LINE/LEADER/ROD and lost tackle data require explicit `Понятно`; fish button brings popup to front. | Оставить. |
| Environment | Spot visual profiles | PARTIAL | Для точек Агамима есть profile assets, sky/background/water/foreground settings. Визуально не проверено. | Screenshot pass per spot. |
| Day/night | Sun/moon/sky/reflection | PARTIAL | Moon/stars/tint/glow/reflection есть, но sun sprite currently forced invisible. | Проверить требование: sun disc или only glow. |
| Water/cast visual | Water, bobber distance | PARTIAL | Cast area profiles, clamp, perspective scale, bobber alpha/scale by distance реализованы. Визуально не проверено. | Smoke cast near/far on several spots. |
| Weather | Rain/storm/audio | PARTIAL | Weather effects controller есть, rain/lightning/audio fade реализованы. Не проверено сменой погоды. | Прогнать weather states. |
| Docs | Tester guide | MISSING | `docs/TESTER_GUIDE.md` заявлен, но отсутствует. | Восстановить или убрать ссылки. |

## Implemented But Not Visible

- Legacy HUD buttons `ShopButton`, `HarborButton`, `ProfileButton`, `BasketButton`, `NavFishButton` существуют/обрабатываются, но runtime-слой скрывает или заменяет их.
- Прямая продажа из садка (`BasketSellAllButton`, old sell handlers) осталась в коде, но кнопки скрыты; продажа перенесена в гавань.
- `SystemMenuUI` создаёт `atlas_item` и `forecast_item`, но в видимый список меню добавлены только Profile, Settings, Help.
- Tuman FM HUD создаётся, но скрыт в основном HUD.
- Legacy inventory list/details/tackle cards остаются, но Inventory v2 скрывает их и использует tile grid/details panel.
- Quick component panel существует, но tap по current rig не показывает список сохранённых rig presets.
- Debug panel и verbose logs отключены через `BuildConfig`.

## Claimed In Changelog But Not Found

- `docs/TESTER_GUIDE.md` - заявлен в beta.1 docs и README, файла нет.
- `HUD текущей снасти справа: тап открывает быстрый список` - найден popup текущей снасти + edit, но не найден полноценный список готовых снастей/пресетов.
- `Исправлена видимость солнца поверх sky-backgrounds` - код динамического солнца выставляет sprite невидимым; возможно, видимость заменена glow/reflection, но это надо визуально подтвердить.
- `Магазин: расходники` в списке "Что перепроверить" - beta code скрывает расходники.
- `Inventory grid 5-6 cards / минимум две строки` - код пытается обеспечить layout, но без визуального smoke это не подтверждено.

## Recommended Next Tasks

### Must before tester APK

1. Синхронизировать версии: `GameVersion`, README, changelog, Android preset `version/name`, export path и имя APK.
2. Решить missing `docs/TESTER_GUIDE.md`: восстановить файл или убрать/заменить ссылки.
3. Добавить/закоммитить UI Kit assets/scripts либо убрать зависимость от untracked файлов.
4. Выполнить Android export из текущей ветки, проверить подпись, установку и запуск на устройстве.
5. Провести ручной full smoke: intro -> Main -> map -> shop/harbor -> inventory -> tackle -> cast -> bite/fight -> catch -> keep/release -> save/load.
6. Принять решение по current rig tap: нужен настоящий preset list или текущая формулировка должна быть изменена.
7. Принять решение по садку: продажа только в гавани или прямые sell-actions должны вернуться в садок.

### Should before wider beta

1. Убрать anchor warnings в модальном слое и основных окнах.
2. Проверить и поправить видимость солнца/луны/sky на реальных spot backgrounds.
3. Расширить Help под beta tester flow: shop/harbor через карту, keepnet, save/load, bug-report данные, текущая версия.
4. Проверить Inventory v2 на 960x540 и 1320x540 скриншотами.
5. Добавить локальный smoke script для навигации: inventory, map, shop, harbor, Fishpedia, tackle, settings/help.
6. Исправить mojibake в `QuickTacklePanel.gd`.

### Can wait

1. Achievements/news, если они не входят в beta scope.
2. Forecast/atlas пункты внутри system menu, если отдельная Fishpedia кнопка остаётся целевым UX.
3. Future waterbodies beyond locked/in-development state.
4. Полная weather polish и визуальные тонкие эффекты после базового device smoke.
5. Расширенные настройки графики/управления/языка, если ЗБТ не требует их сразу.
