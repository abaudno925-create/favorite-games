// Общие действия плагина «Любимые игры»: список из настроек плагина, запуск,
// достижения. Синглтон рядом с qmldir (приватный синглтон плагина).
// Список живёт в настройках плагина, поэтому виджет на столе, кнопка на панели,
// лаунчер и страница настроек видят одно и то же.
pragma Singleton

import QtQuick
import Quickshell
import qs.config
import qs.services
import "Games.js" as Games

Singleton {
    id: root

    // games: plugin → [ { id, name, command, appId, icon, iconName, terminal } ]
    function gamesOf(plugin) {
        return plugin ? Games.normalize(plugin.get("games", [])) : [];
    }

    function appById(appId) {
        if (!appId)
            return null;
        const values = DesktopEntries.applications.values;
        for (let i = 0; i < values.length; i++)
            if (values[i].id === appId)
                return values[i];
        return DesktopEntries.heuristicLookup(appId) || null;
    }

    // Запуск через оболочку, как это делает «Пуск»: приложение получает окружение
    // angelOS. .desktop уходит предпочтительно, команда — запасной вариант.
    function launch(plugin, g) {
        if (!plugin || !g)
            return;
        if (g.appId) {
            const app = root.appById(g.appId);
            if (app) {
                if (app.runInTerminal)
                    Shell.exec(Shell.terminalArgv(app.command), app.workingDirectory, app.id);
                else if (app.command && app.command.length)
                    Shell.exec(app.command, app.workingDirectory, app.id);
                else
                    app.execute();
                root.note(plugin);
                return;
            }
        }
        if (!g.command)
            return;
        if (g.terminal || plugin.get("terminal", false))
            Shell.terminal(g.command);
        else
            Shell.sh(g.command);
        root.note(plugin);
    }

    function add(plugin, g) {
        if (!plugin || !g)
            return;
        plugin.set("games", root.gamesOf(plugin).concat([g]));
        if (!plugin.achieved("first-game"))
            plugin.achieve("first-game");
    }

    function remove(plugin, id) {
        if (!plugin)
            return;
        plugin.set("games", root.gamesOf(plugin).filter(x => x.id !== id));
    }

    function note(plugin) {
        if (!plugin)
            return;
        plugin.achieve("first-launch");
        plugin.progress("ten-launches", 1);
    }

    // Картинка значка для лаунчера (пустая строка — пусть рисует пиксельный значок).
    function iconPathOf(g) {
        if (!g)
            return "";
        const name = g.iconName || g.appId || g.icon || "";
        if (!name)
            return "";
        return Quickshell.iconPath(name, true) || "";
    }
}
