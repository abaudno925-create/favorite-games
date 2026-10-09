pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.widgets
import qs.modules.bar
import "."
import "Games.js" as Games

// Кнопка на панели: геймпад. Пиксельная панель — плоская кнопка, клик открывает
// попап со списком; в macOS — «menu bar extra» одним цветом в чернилах панели.
Item {
    id: root

    property var plugin
    property string screenName
    property var barWindow
    // крюки пиксельной панели (BarItem): её отступы и чернила адской панели
    property int hpad: -1
    property bool barInk: false

    readonly property var games: GamesApi.gamesOf(root.plugin)
    readonly property var windows: Niri.windows
    readonly property bool mac: Skin.mac
    readonly property bool barOpen: popup.visible

    implicitWidth: mac ? macRow.implicitWidth : btn.implicitWidth
    implicitHeight: mac ? Skin.px(18) : btn.implicitHeight

    PxButton {
        id: btn
        visible: !root.mac
        anchors.fill: parent
        compact: true
        flat: true
        hpad: root.hpad
        barInk: root.barInk
        icon: "gamepad"
        text: root.games.length > 0 ? String(root.games.length) : ""
        checked: popup.visible
        onClicked: popup.toggle()
    }

    Row {
        id: macRow
        visible: root.mac
        anchors.centerIn: parent
        spacing: Skin.px(3)
        MacIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: "gamepad"
            size: Skin.px(16)
            stroke: 2
            color: Skin.ink(root.screenName)
        }
    }
    MouseArea {
        visible: root.mac
        anchors.fill: parent
        onClicked: popup.toggle()
    }

    BarPopup {
        id: popup
        panelId: "favorite-games"
        anchorItem: root
        above: BarLayout.bottom && !root.mac
        title: Skin.title(Skin.mac ? I18n.t("Любимые игры", "Favorite games") : "favorite-games")
        icon: "gamepad"
        contentWidth: Skin.px(240)
        contentHeight: Skin.px(300)
        PxScroll {
            anchors.fill: parent
            contentHeight: listCol.implicitHeight
            Column {
                id: listCol
                width: parent.width
                spacing: Skin.px(2)
                Repeater {
                    model: root.games
                    delegate: GameRow {
                        required property var modelData
                        width: listCol.width
                        game: modelData
                        running: Games.isRunning(modelData, root.windows)
                        onLaunch: g => GamesApi.launch(root.plugin, g)
                        onRemove: g => GamesApi.remove(root.plugin, g ? g.id : "")
                    }
                }
                PxText {
                    visible: root.games.length === 0
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: I18n.t("Пока пусто — добавь игры в виджете на столе.", "Nothing yet — add games in the desktop widget.")
                    kind: "tiny"
                    dim: true
                }
            }
        }
    }
}
