import QtQuick
import qs.config
import qs.services
import "."
import "Games.js" as Games

// «games запрос» в лаунчере (Mod+Space; в macOS — Spotlight): любимые игры по имени.
// Без префикса строка ищется, только если имя игры начинается с набранного — в общем
// поиске плагин не лезет первым.
QtObject {
    id: root

    property var plugin
    property string pluginId
    readonly property string prefix: "games"
    readonly property bool global: true
    signal changed

    readonly property var games: GamesApi.gamesOf(root.plugin)

    // text — запрос без префикса, prefixed — набран ли префикс
    function query(text, prefixed) {
        const q = String(text || "").trim().toLowerCase();
        if (!prefixed && q.length < 2)
            return [];
        const rows = [];
        for (const g of root.games) {
            const s = Games.score(g, q);
            if (prefixed ? s > 0 : s >= 90)
                rows.push({
                    "id": g.id,
                    "title": g.name,
                    "subtitle": Games.subtitle(g) || I18n.t("запустить", "launch"),
                    "icon": Games.pixelIcon(g),
                    "image": GamesApi.iconPathOf(g),
                    "score": prefixed ? 100 : 70
                });
        }
        return rows;
    }

    function activate(id) {
        const g = root.games.find(x => x.id === id);
        GamesApi.launch(root.plugin, g);
        return true;    // лаунчер остаётся открытым
    }
}
