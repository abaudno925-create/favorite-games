import QtQuick
import qs.config
import qs.services
import qs.widgets
import "Games.js" as Games

// Одна игра в списке: значок приложения (или пиксельный), имя, точка — пока игра
// запущена; клик по строке запускает, при наведении показывается кнопка «убрать».
// Одна и та же строка в виджете на столе и в попапе панели.
Item {
    id: root

    property var game
    property bool running: false

    property bool hell: Theme.hell
    property bool mac: Skin.macWidgets

    signal launch(var game)
    signal remove(var game)

    readonly property bool useApp: Games.usesAppIcon(root.game)
    readonly property color ink: root.hell ? Theme.hellText : Skin.text
    readonly property color dimInk: root.hell ? Theme.hellTextDim : Skin.textDim

    implicitWidth: Math.max(inner.implicitWidth + Skin.px(10), Skin.px(130))
    implicitHeight: Math.max(Skin.px(24), inner.implicitHeight + Skin.px(6))

    // подложка под курсором
    Rectangle {
        anchors.fill: parent
        visible: hover.containsMouse
        color: root.hell ? Qt.alpha(Theme.hellEmber, 0.18) : Skin.hover
        radius: Skin.radius
    }

    Row {
        id: inner
        anchors.centerIn: parent
        spacing: Skin.px(6)

        Item {
            width: Skin.px(18)
            height: Skin.px(18)
            anchors.verticalCenter: parent.verticalCenter
            AppIcon {
                anchors.fill: parent
                visible: root.useApp
                appId: root.game ? root.game.appId : ""
                iconName: root.game ? root.game.iconName : ""
            }
            PxIcon {
                anchors.centerIn: parent
                visible: !root.useApp
                name: Games.pixelIcon(root.game)
                pixel: Theme.u
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            PxText {
                width: Math.min(implicitWidth, Skin.px(150))
                text: root.game ? root.game.name : ""
                elide: Text.ElideRight
                color: root.ink
            }
            // команда — только в маковской карточке, у пиксельных строк одна линия
            PxText {
                visible: root.mac
                width: Skin.px(110)
                text: Games.subtitle(root.game)
                kind: "tiny"
                elide: Text.ElideRight
                color: root.dimInk
            }
        }

        // точка: игра запущена
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: Skin.px(5)
            height: width
            radius: width / 2
            visible: root.running
            color: root.hell ? Theme.hellAccent : Skin.ok
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.launch(root.game)
    }

    PxButton {
        anchors.right: parent.right
        anchors.rightMargin: Skin.px(2)
        anchors.verticalCenter: parent.verticalCenter
        visible: hover.containsMouse
        compact: true
        flat: true
        danger: true
        hell: root.hell
        icon: "trash"
        onClicked: root.remove(root.game)
    }
}
