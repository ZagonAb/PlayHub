import QtQuick 2.15
import SortFilterProxyModel 0.2

ListView {
    id: favoriteList
    width: parent.width
    height: parent.height
    clip: true
    spacing: 8
    focus: true

    property var currentTheme
    property bool mouseNavigationEnabled: true
    property var theme: parent.parent.parent

    model: SortFilterProxyModel {
        sourceModel: api.allGames
        filters: ExpressionFilter {
            expression: {
                return model.favorite === true
            }
        }
        sorters: RoleSorter {
            roleName: "title"
            sortOrder: Qt.AscendingOrder
        }
    }

    delegate: Rectangle {
        width: favoriteList.width
        height: favoriteList.height / 3
        color: "transparent"
        radius: 8
        border.color: "transparent"
        border.width: 0

        opacity: (ListView.isCurrentItem && favoriteList.focus) ? 1.0 : 0.3

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Row {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            Rectangle {
                width: 80
                height: 80
                color: currentTheme.primary
                radius: 6
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.fill: parent
                    anchors.margins: 2
                    source: model.assets.boxFront || "assets/nofound.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }

                Text {
                    visible: !parent.children[0].source
                    text: "FAVORITE"
                    anchors.centerIn: parent
                    font.pixelSize: 8
                    font.bold: true
                    color: "#666666"
                    rotation: 0
                }
            }

            Column {
                width: parent.width - 92
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: model.title || "FAVORITE"
                    width: parent.width
                    font.pixelSize: 18
                    font.bold: true
                    elide: Text.ElideRight
                    color: "white"
                    maximumLineCount: 1
                }

                Text {
                    text: {
                        if (model.collections && model.collections.count > 0) {
                            return model.collections.get(0).name
                        }
                        return "FAVORITE"
                    }
                    width: parent.width
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    color: "#888888"
                    maximumLineCount: 1
                }

                Text {
                    text: model.lastPlayed ? "Last played: " + Qt.formatDateTime(model.lastPlayed, "dd/MM/yyyy") : ""
                    width: parent.width
                    font.pixelSize: 12
                    color: "#666666"
                    visible: text !== ""
                }
            }
        }

        Rectangle {
            visible: ListView.isCurrentItem && favoriteList.focus
            width: 6
            height: parent.height - 20
            color: "#4d99e6"
            radius: 3
            anchors {
                left: parent.left
                leftMargin: 4
                verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (mouseNavigationEnabled) {
                    favoriteList.currentIndex = index
                    favoriteList.forceActiveFocus()
                    if (typeof keyboard !== 'undefined') {
                        keyboard.resetKeyboard()
                    }
                    if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                }
            }
        }
    }

    header: Rectangle {
        width: favoriteList.width
        height: 35
        color: currentTheme.secondary
        radius: 8

        Text {
            text: "Favorites"
            anchors.centerIn: parent
            font.pixelSize: 16
            font.bold: true
            color: "#4d99e6"
        }
    }

    onFocusChanged: {
        if (focus && count > 0) {
            if (currentIndex < 0) {
                currentIndex = 0
            }
            var tempIndex = currentIndex
            currentIndex = -1
            currentIndex = tempIndex
            Qt.callLater(function() {
                if (focus && count > 0) {
                    positionViewAtIndex(currentIndex, ListView.Contain)
                }
            })
        }
    }

    Keys.onPressed: {
        if (!event.isAutoRepeat) {
            if (api.keys.isAccept(event)) {
                event.accepted = true
                soundEffects.play("launch");
                if (model && currentIndex >= 0) {
                    var game = model.get(currentIndex);
                    searchOverlay.parent.game = game;
                    searchOverlay.parent.launchTimer.start();
                }
            }
            else if (event.key === Qt.Key_Up) {
                if (currentIndex > 0) {
                    decrementCurrentIndex()
                    if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                }
                event.accepted = true
            }
            else if (event.key === Qt.Key_Down) {
                if (currentIndex < count - 1) {
                    incrementCurrentIndex()
                    if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                }
                event.accepted = true
            }
            else if (event.key === Qt.Key_Left) {
                keyboard.forceActiveFocus()
                if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                    event.accepted = true
            }
            else if (api.keys.isCancel(event)) {
                keyboard.forceActiveFocus()
                if (typeof soundEffects !== 'undefined') soundEffects.play("back")
                    event.accepted = true
            }
        }
    }

    function refreshCurrentItem() {
        if (count > 0 && currentIndex >= 0) {
            var tempIndex = currentIndex
            currentIndex = -1
            currentIndex = tempIndex
            positionViewAtIndex(currentIndex, ListView.Contain)
        }
    }
}
