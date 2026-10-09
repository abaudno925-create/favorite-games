#!/usr/bin/env bash
# Публикация favorite-games в Community Registry angelOS.
# Нужен один раз: sudo pacman -S github-cli && gh auth login
set -euo pipefail

NAME="favorite-games"
VERSION="v1.0.0"
ZIP="../${NAME}-${VERSION}.zip"
REGISTRY_URL="https://github.com/futureUnd1ground/angelos-community-registry"
HERE="$(cd "$(dirname "$0")" && pwd)"

command -v gh >/dev/null || { echo "нет gh: sudo pacman -S github-cli && gh auth login"; exit 1; }
gh auth status >/dev/null || { echo "gh не авторизован: gh auth login"; exit 1; }

GH_USER="$(gh api user --jq .login)"
echo "→ аккаунт: $GH_USER"

# ссылки в записи реестра — на твой аккаунт
sed -i "s|https://github.com/USERNAME/favorite-games|https://github.com/$GH_USER/favorite-games|g" "$HERE/registry-entry.json"

# 1. репозиторий плагина + тег
cd "$HERE"
gh repo create "$NAME" --public --source=. --remote=origin --push \
  || git remote add origin "https://github.com/$GH_USER/$NAME.git"
git push -u origin main
git push origin "$VERSION"

# 2. релиз с архивом
gh release create "$VERSION" "$ZIP" \
  --title "Любимые игры ${VERSION#v}" \
  --notes "Виджет «Любимые игры»: список игр на рабочем столе, клик — запуск, «+» — добавить (имя и команда, или .desktop из установленных). Кнопка на панели, «games …» в лаунчере, страница настроек. Тема 1: Pixel и macOS, ад; проверено на angelOS 0.8.x."

# 3. форк реестра с записью
WORK="$(mktemp -d)"
gh repo fork "$REGISTRY_URL" --clone=true -- "$WORK/registry"
cd "$WORK/registry"
python3 - "$HERE/registry-entry.json" <<'PY'
import json, sys
entry = json.load(open(sys.argv[1], encoding="utf-8"))
path = "plugins.json"
doc = json.load(open(path, encoding="utf-8"))
assert not any(p["id"] == entry["id"] for p in doc["plugins"]), "запись уже есть"
doc["plugins"].append(entry)
json.dump(doc, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
open(path, "a", encoding="utf-8").write("\n")
print("добавлено:", entry["id"])
PY
git checkout -q -b "add-favorite-games"
git add plugins.json
git commit -q -m "Add favorite-games: desktop widget for favorite games"
git push -q origin HEAD
gh pr create --repo "$REGISTRY_URL" \
  --title "Add favorite-games: favorite games widget" \
  --body "$(cat <<MD
**What it does.** A desktop widget for favorite games: add, remove and launch in one click. \`.desktop\` entries launch through the shell like Start does; any \`sh -c\` command works too (steam, lutris, wine). A bar button with the same list, \`games <name>\` in the launcher, a full editor in Settings → Plugins. A dot marks a running game (niri windows).

**Tested on.** angelOS 0.8.x (Quickshell 0.3), both Pixel and macOS (Golden Gate) themes and hell (Theme API only, no hard-coded colours).

**Assets.** https://github.com/$GH_USER/favorite-games and release \`v1.0.0\` → \`favorite-games-v1.0.0.zip\` (root-level manifest.json).

**Requirements.** None beyond angelOS itself; games are user-installed.

**License.** MIT (own code only; icons come from the system icon theme / \`.desktop\` files).
MD
)"
echo "→ готово, PR открыт"
