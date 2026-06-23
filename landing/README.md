# Рыбное Место — landing page

Отдельное web-приложение для лендинга мобильной игры «Рыбное Место». Игровой Godot-проект не используется как часть сборки сайта.

## Локальный запуск

```bash
npm install
npm run dev
```

По умолчанию Vite откроет сайт на `http://localhost:5173`.

## Проверка сборки

```bash
npm run build
```

Готовая статическая сборка появится в `dist/`.

## Деплой на Vercel

1. Импортировать репозиторий в Vercel.
2. В настройках проекта указать Root Directory: `landing`.
3. Framework Preset: `Vite`.
4. Build Command: `npm run build`.
5. Output Directory: `dist`.
6. Добавить переменные окружения из списка ниже.
7. Запустить Deploy.

## Переменные окружения

Vite настроен на чтение `NEXT_PUBLIC_*`, чтобы ссылки можно было задавать теми же именами, что указаны в ТЗ.

```bash
NEXT_PUBLIC_APK_URL=
NEXT_PUBLIC_TELEGRAM_URL=
NEXT_PUBLIC_BUG_REPORT_URL=
NEXT_PUBLIC_VK_URL=
NEXT_PUBLIC_YOUTUBE_URL=
NEXT_PUBLIC_PRIVACY_URL=
```

Если ссылка не задана, кнопка ведет на секцию `#zbt`, поэтому интерфейс не ломается.

## Ассеты

Реальные горизонтальные скриншоты лежат в `public/screenshots/`:

- `gameplay-reeling.jpg`
- `agamin-map.jpg`
- `night-fishing.jpg`
- `fish-encyclopedia.jpg`
- `shop-baits.jpg`
- `shop-rods.jpg`
- `float-depth-night.jpg`
- `tuman-fm-settings.jpg`
- `skill-tree.jpg`
