pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.widgets
import "."
import "Games.js" as Games

// «games.exe» — виджет на рабочем столе: любимые игры, клик — запуск, наведение —
// убрать, «+» — добавить. Рамку (окно «.exe» в пиксельной теме, стеклянную карточку в
// macOS, адскую в аду) рисует хост; здесь только содержимое.
Item {
    id: root

    property var plugin
    property string screenName
    property var widget          // { uid, x, y, settings } этого экземпляра

    readonly property bool hell: Theme.hell
    readonly property bool mac: Skin.macWidgets
    readonly property color ink: root.hell ? Theme.hellFlame : Skin.text
    readonly property color dimInk: root.hell ? Theme.hellTextDim : Skin.textDim
    readonly property color edge: root.hell ? Theme.hellEdge : Skin.separator

    // список живёт в настройках плагина: страница настроек, панель и лаунчер видят его же
    readonly property var games: GamesApi.gamesOf(root.plugin)
    readonly property bool empty: root.games.length === 0
    // окна niri — для точки «запущено»
    readonly property var windows: Niri.windows

    property bool adding: false

    implicitWidth: Math.max(col.implicitWidth, root.mac ? DesktopWidgets.mpx(250) : Skin.px(190))
    implicitHeight: col.implicitHeight

    function launch(g) {
        GamesApi.launch(root.plugin, g);
    }
    function addGame(g) {
        GamesApi.add(root.plugin, g);
        root.adding = false;
    }
    function removeGame(id) {
        GamesApi.remove(root.plugin, id);
    }

    Column {
        id: col
        width: parent.width
        spacing: Skin.px(4)

        // заголовок: значок, имя, справа — «+»
        Item {
            id: head
            width: parent.width
            implicitHeight: Math.max(headRow.implicitHeight, Skin.px(22))
            Row {
                id: headRow
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Skin.px(4)
                PxIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "gamepad"
                    pixel: Theme.u
                    ink: root.ink
                }
                PxText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, head.width - Skin.px(40))
                    text: I18n.t("Любимые игры", "Favorite games")
                    kind: root.mac ? "title" : "body"
                    font.bold: true
                    elide: Text.ElideRight
                    color: root.ink
                }
            }
            PxButton {
                id: addBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                compact: true
                flat: true
                checked: root.adding
                hell: root.hell
                icon: "plus"
                onClicked: root.adding = !root.adding
            }
        }

        Rectangle {
            width: parent.width
            height: Math.max(1, Skin.px(1))
            color: root.edge
        }

        // игры
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
                    onLaunch: g => root.launch(g)
                    onRemove: g => root.removeGame(g ? g.id : "")
                }
            }
        }

        PxText {
            visible: root.empty && !root.adding
            width: parent.width
            wrapMode: Text.Wrap
            text: I18n.t("Пока пусто. Нажми «+» и добавь любимые игры.", "Nothing yet. Press “+” and add your favorite games.")
            kind: "tiny"
            color: root.dimInk
        }

        AddPanel {
            visible: root.adding
            width: parent.width
            hell: root.hell
            onAdded: g => root.addGame(g)
            onCancelled: root.adding = false
        }

        // подсказка внизу
        PxText {
            visible: !root.empty && !root.adding
            width: parent.width
            text: I18n.t("Клик — запустить, наведи — убрать", "Click — launch, hover — remove")
            kind: "tiny"
            elide: Text.ElideRight
            color: root.dimInk
        }
    }
}
