# ♡ Любимые игры (favorite-games)

Плагин-виджет **angelOS** для любимых игр: добавить, убрать и запустить в один клик.

A desktop widget plugin for **angelOS** that keeps your favorite games one click away.

## Что умеет / What it does

| Русский | English |
| --- | --- |
| Виджет `games.exe` на рабочем столе: список игр, клик по строке — запуск | `games.exe` desktop widget: the game list, click a row to launch |
| «+» — добавить: имя и командная строка, или выбор из установленных `.desktop`-игр | «+» — add: name + command line, or pick from installed `.desktop` games |
| Наведение на строку — кнопка убрать | Hover a row — the remove button |
| Точка рядом с игрой — она уже запущена (по окнам niri) | A dot beside a game — it is already running (by niri's windows) |
| Кнопка геймпада на панели — тот же список в попапе | Gamepad panel button — the same list in a popup |
| `games <название>` в лаунчере (Mod+Space) | `games <name>` in the launcher (Mod+Space) |
| Страница в Настройки → Плагины — полный редактор списка | Settings → Plugins page — the full list editor |
| Обе темы (Pixel и macOS/Golden Gate) и ад (`Theme` API, без своих цветов) | Both looks (Pixel and macOS/Golden Gate) and hell (Theme API, no hard-coded colours) |

## Как запускаются игры / How games launch

У игры два способа запуска, `.desktop` предпочтительнее:

- **`appId`** — id `.desktop`-файла (его подставляет выбор «Из игр…»): запуск идёт
  через оболочку, как из «Пуска», — игра получает правильное окружение angelOS;
- **`command`** — командная строка для `sh -c`: `steam steam://rungameid/367520`,
  `lutris lutris:rungameid/1`, `wine ~/Games/Тишина/Tishina.exe` — что угодно.

Если `.desktop` пропал, используется `command`; команду можно включить в терминале
(«Настройки → Плагины → Любимые игры → Запуск → Команды — в терминале»).

## Установка / Install

Через **Настройки → Плагины → Community Plugins** (после одобрения в реестре) или
вручную — скопировать папку в пользовательский каталог плагинов:

```bash
mkdir -p ~/.config/angelos/plugins
cp -a favorite-games ~/.config/angelos/plugins/favorite-games
```

Затем ПКМ по обоям → **Вид → Виджеты → «Любимые игры»** (или Settings → Plugins, чтобы
включить плагин). Compiled: ничего не нужно, это обычный QML.

## Разработка / Development

```bash
jq empty favorite-games/manifest.json                                  # манифет валиден
jq -e '.id and .name and .version' favorite-games/manifest.json         # обязательные поля
cp -a favorite-games ~/.config/angelos/plugins/favorite-games           # копия для разработки
```

Плагин перезагружается сам при правке QML. Проверено на angelOS 0.8.x (Quickshell 0.3):
Pixel, macOS (Golden Gate), ад — все три образа.

## Лицензия / License

MIT, © 2026 erocode. Своих чужих файлов не содержит: значки берутся из тем иконок и
`.desktop`-файлов системы, всё оформление — из Theme API самой angelOS.
