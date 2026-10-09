pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets
import "."
import "Games.js" as Games

// Форма «добавить игру»: имя, командная строка (необязательна, если выбрана игра
// из установленных) и список установленных игр для выбора. Enter в поле — добавить.
Item {
    id: root

    property bool hell: Theme.hell
    // показан ли список установленных игр
    property bool picking: false

    // выбранная .desktop-игра: { appId, iconName }
    property var picked: ({ "appId": "", "iconName": "" })

    signal added(var game)
    signal cancelled()

    // игры из .desktop: в категориях есть «Game»
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

    implicitWidth: Math.max(col.implicitWidth, Skin.px(170))
    implicitHeight: col.implicitHeight

    function submit() {
        const name = nameField.text.trim();
        const command = commandField.text.trim();
        if (!name || (!command && !root.picked.appId))
            return;
        root.added({
            "id": "",
            "name": name,
            "command": command,
            "appId": root.picked.appId,
            "icon": "",
            "iconName": root.picked.iconName,
            "terminal": false
        });
        root.reset();
    }

    function reset() {
        nameField.text = "";
        commandField.text = "";
        root.picked = { "appId": "", "iconName": "" };
        root.picking = false;
    }

    // клик по установленной игре: имя и .desktop заполняются сами
    function pick(app) {
        nameField.text = String(app.name || "");
        root.picked = { "appId": String(app.id || ""), "iconName": String(app.icon || "") };
        root.picking = false;
    }

    Column {
        id: col
        width: parent.width
        spacing: Skin.px(4)

        PxField {
            id: nameField
            width: parent.width
            placeholder: I18n.t("Название", "Name")
            onAccepted: root.submit()
        }
        PxField {
            id: commandField
            width: parent.width
            placeholder: I18n.t("Команда (необязательно)", "Command (optional)")
            onAccepted: root.submit()
        }

        // кнопки переносятся на вторую строку, если панель узкая
        Flow {
            spacing: Skin.px(4)
            PxButton {
                text: I18n.t("Добавить", "Add")
                accent: true
                compact: true
                onClicked: root.submit()
            }
            PxButton {
                text: I18n.t("Отмена", "Cancel")
                compact: true
                flat: true
                hell: root.hell
                onClicked: {
                    root.reset();
                    root.cancelled();
                }
            }
            PxButton {
                visible: root.installed.length > 0
                text: root.picking ? I18n.t("Скрыть", "Hide") : I18n.t("Из игр…", "From games…")
                icon: "gamepad"
                compact: true
                hell: root.hell
                onClicked: root.picking = !root.picking
            }
        }

        Column {
            visible: root.picking
            width: parent.width
            spacing: Skin.px(1)
            Repeater {
                model: root.installed
                delegate: Item {
                    required property var modelData
                    width: parent.width
                    height: Skin.px(20)
                    Row {
                        anchors.fill: parent
                        spacing: Skin.px(4)
                        AppIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            appId: modelData.id
                            size: Skin.px(16)
                        }
                        PxText {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - Skin.px(26)
                            text: modelData.name
                            elide: Text.ElideRight
                            color: root.hell ? Theme.hellText : Skin.text
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        visible: rowHover.containsMouse
                        color: root.hell ? Qt.alpha(Theme.hellEmber, 0.18) : Skin.hover
                        radius: Skin.radius
                    }
                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.pick(modelData)
                    }
                }
            }
        }
    }

    // фокус в первое поле при показе: как только форма открылась
    onVisibleChanged: if (visible)
        nameField.focusField()
}
