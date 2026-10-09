#!/usr/bin/env bash
# Релизный архив: только рантайм-файлы плагина, ровно один manifest.json в корне.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$HERE/manifest.json")"
OUT="$HERE/../favorite-games-v${VERSION}.zip"
rm -f "$OUT"
cd "$HERE"
python3 - "$OUT" <<'PY'
import sys, zipfile
files = [
    "manifest.json", "README.md", "LICENSE", "qmldir",
    "Games.js", "GamesApi.qml", "GameRow.qml", "AddPanel.qml",
    "DesktopWidget.qml", "BarWidget.qml", "Launcher.qml", "Settings.qml",
]
with zipfile.ZipFile(sys.argv[1], "w", zipfile.ZIP_DEFLATED) as z:
    for f in files:
        z.write(f, f)
PY
echo "→ $OUT"
unzip -l "$OUT" | tail -3
