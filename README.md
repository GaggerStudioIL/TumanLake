# Рыбное Место

Рыбное Место — мобильная игра про рыбалку на Godot 4.
Текущий фокус проекта: подготовка к закрытому бета-тесту первого рабочего водоёма — Озеро Агамим.

## Текущий статус

Статус: Closed Beta preparation
Текущая версия: v0.1.0-beta.2
Основной рабочий водоём: Озеро Агамим

В текущем beta scope:
- рыбалка на Озере Агамим;
- выбор точек ловли;
- заброс;
- поклёвка;
- вываживание;
- садок как просмотр улова;
- продажа рыбы через Рыбную гавань;
- инвентарь;
- магазин;
- карта водоёмов;
- системное меню;
- инструкция “Сообщить о баге”.

Будущие водоёмы могут отображаться на карте как “в разработке”, но не считаются готовым игровым контентом.

## Требования

- Godot 4.6.x
- Режим проекта: Mobile
- Основная сцена запускается через intro:
  res://scenes/intro/IntroCinematic.tscn

## Как открыть проект

1. Установить Godot 4.6.x.
2. Открыть Godot Project Manager.
3. Импортировать папку проекта TumanLake.
4. Открыть project.godot.
5. Запустить проект кнопкой Play.

## Важные файлы

- project.godot — настройки проекта и autoload.
- scripts/core/BuildConfig.gd — beta/debug flags.
- scripts/core/GameVersion.gd — версия билда.
- scripts/managers/SaveManager.gd — сохранение/загрузка.
- scripts/managers/FishingManager.gd — логика рыбалки.
- scripts/data/FishDatabase.gd — база рыбы.
- scripts/data/WaterbodyDatabase.gd — база водоёмов.
- scripts/data/SpotDatabase.gd — база точек ловли.
- scripts/ui/SystemMenuUI.gd — системное меню и инструкция “Сообщить о баге”.

## Документация для ЗБТ

- docs/BETA_CHECKLIST.md — подробный чек-лист проверки.
- docs/TESTER_GUIDE.md — инструкция для тестеров и начальника ЗБТ.
- docs/CHANGELOG.md — список изменений по beta-версиям.

## Правила beta scope

В текущей beta-версии основным рабочим водоёмом является Озеро Агамим.

Не считаются обязательным контентом текущей beta:
- будущие водоёмы;
- онлайн;
- турниры;
- передача предметов;
- Google Play-интеграция;
- финальный баланс всей игры;
- финальная графика всех локаций.

## Версии

Версия хранится в:
scripts/core/GameVersion.gd

Для нового beta-билда нужно обновить:
- VERSION
- BUILD_NAME
- BUILD_DATE

Пример:
v0.1.0-beta.2
v0.1.0-beta.3
v0.1.1-beta.1

## BuildConfig

Файл:
scripts/core/BuildConfig.gd

Используется для beta/debug флагов:
- IS_BETA_BUILD
- ENABLE_ALPHA_TESTER_BONUS
- ENABLE_DEBUG_PANEL
- ENABLE_VERBOSE_LOGS

Перед beta-сборкой убедиться, что:
- ENABLE_ALPHA_TESTER_BONUS = false
- ENABLE_DEBUG_PANEL = false
- ENABLE_VERBOSE_LOGS = false

## Перед отправкой билда тестерам

Проверить:

1. git status clean.
2. Версия билда обновлена.
3. Игра запускается без SCRIPT ERROR.
4. Системное меню показывает версию.
5. Кнопка “Сообщить о баге” работает.
6. Агамим доступен.
7. Будущие водоёмы не открываются как рабочие.
8. Рыбалка запускается.
9. Сохранение работает после перезапуска.
10. APK/AAB собран из актуальной ветки.

## Git

Не коммитить:
- build/
- saves/
- .godot/
- .import/
- *.apk
- *.aab
- *.keystore
- локальные логи и временные файлы

Эти правила уже должны быть указаны в .gitignore.
