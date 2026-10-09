pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets
import "."
import "Games.js" as Games

// Настройки → Плагины → Любимые игры: полный редактор списка. Тот же список, что у
// виджета на столе и попапа на панели (настройки плагина).
Column {
    id: root

    property var plugin
    readonly property var games: GamesApi.gamesOf(root.plugin)
    readonly property var installed: {
        const out = [];
        const values = DesktopEntries.applications.values;
        for (let i = 0; i < values.length; i++) {
            const app = values[i];
            if (!app.noDisplay && Games.isGameApp(app))
                out.push(app);
        }
        return out.sort((a, b) => String(a.name || "").localeCompare(String(b.name || "")));
    }

    width: parent ? parent.width : 400
    spacing: Skin.px(10)

    function patch(i, values) {
        if (!root.plugin)
            return;
        const list = root.games.slice();
        list[i] = Object.assign({}, list[i], values);
        root.plugin.set("games", list);
    }
    function remove(i) {
        if (root.plugin)
            root.plugin.set("games", root.games.filter((g, j) => j !== i));
    }
    function add() {
        if (root.plugin)
            root.plugin.set("games", root.games.concat([{ "name": "", "command": "" }]));
    }

    PxGroup {
        title: I18n.t("Список игр", "Game list")
        icon: "gamepad"
        width: parent.width

        Repeater {
            model: root.games
            delegate: Column {
                required property var modelData
                width: parent.width
                spacing: 0
                readonly property int at: model.index

                SettingRow {
                    label: I18n.t("Название", "Name")
                    PxField {
                        width: parent.width
                        text: modelData.name
                        placeholder: "Hollow Knight"
                        onEdited: root.patch(at, { "name": text })
                    }
                }
                SettingRow {
                    label: I18n.t("Команда", "Command")
                    PxField {
                        width: parent.width
                        text: modelData.command
                        placeholder: "steam steam://rungameid/367520"
                        onEdited: root.patch(at, { "command": text })
                    }
                }
                SettingRow {
                    label: I18n.t("Значок", "Icon")
                    hint: I18n.t("пиксельный значок, имя из темы или путь к картинке", "a pixel icon, a theme name or a path to a picture")
                    PxField {
                        width: parent.width
                        text: modelData.iconName || modelData.icon
                        placeholder: "gamepad"
                        onEdited: root.patch(at, { "icon": text, "iconName": "" })
                    }
                }
                SettingRow {
                    label: I18n.t("Из установленных", "From installed")
                    hint: I18n.t("подставит .desktop по имени — запуск как из «Пуска»", "fills the .desktop by name — launched like from Start")
                    PxField {
                        width: parent.width
                        text: modelData.appId
                        placeholder: "steam"
                        onEdited: root.patch(at, { "appId": text })
                    }
                }
                SettingRow {
                    label: I18n.t("Убрать", "Remove")
                    PxButton {
                        text: I18n.t("Убрать из списка", "Remove from the list")
                        danger: true
                        compact: true
                        onClicked: root.remove(at)
                    }
                }
            }
        }

        SettingRow {
            label: I18n.t("Добавить игру", "Add a game")
            PxButton {
                text: "+"
                accent: true
                compact: true
                onClicked: root.add()
            }
        }
    }

    PxGroup {
        title: I18n.t("Запуск", "Launching")
        icon: "play"
        width: parent.width
        SettingRow {
            label: I18n.t("Команды — в терминале", "Commands in a terminal")
            hint: I18n.t("для консольных игр", "for console games")
            PxToggle {
                checked: root.plugin ? root.plugin.get("terminal", false) : false
                onToggled: checked => {
                    if (root.plugin)
                        root.plugin.set("terminal", checked);
                }
            }
        }
    }

    PxGroup {
        title: I18n.t("Как пользоваться", "How to use")
        icon: "info"
        width: parent.width
        PxText {
            width: parent.width
            wrapMode: Text.Wrap
            text: I18n.t(
                "Виджет «games.exe» на рабочем столе: правый клик по обоям → Вид → Виджеты → «Любимые игры». Клик по строке запускает игру, наведи на строку — появится кнопка убрать. «+» — добавить: имя и командная строка, или выбор из установленных игр. В лаунчере (Mod+Space) набери «games» и имя игры. Кнопка на панели открывает тот же список.",
                "The “games.exe” widget on the desktop: right-click the wallpaper → View → Widgets → “Favorite games”. Click a row to launch, hover a row for the remove button. “+” adds one: a name and a command line, or pick from the installed games. In the launcher (Mod+Space) type “games” and the game's name. The panel button opens the same list.")
        }
    }
}
