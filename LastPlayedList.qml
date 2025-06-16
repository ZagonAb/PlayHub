import QtQuick 2.15
import SortFilterProxyModel 0.2

ListView {
    id: lastPlayedList
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
                return model.lastPlayed !== undefined && model.lastPlayed !== null
            }
        }
        sorters: RoleSorter {
            roleName: "lastPlayed"
            sortOrder: Qt.DescendingOrder
        }
    }

    delegate: Rectangle {
        width: lastPlayedList.width
        height: 65
        color: (ListView.isCurrentItem && lastPlayedList.focus) ? currentTheme.secondary : currentTheme.primary
        radius: 8
        border.color: (ListView.isCurrentItem && lastPlayedList.focus) ? "#4d99e6" : "transparent"
        border.width: 2

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }

        Row {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            Rectangle {
                width: 50
                height: 50
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
                    text: "LISTVIEW"
                    anchors.centerIn: parent
                    font.pixelSize: 8
                    font.bold: true
                    color: "#666666"
                    rotation: 0
                }
            }

            Column {
                width: parent.width - 62
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: model.title || "LISTVIEW"
                    width: parent.width
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    color: (ListView.isCurrentItem && lastPlayedList.focus) ? currentTheme.textSelected : currentTheme.text
                    maximumLineCount: 1
                }

                Text {
                    text: {
                        if (model.collections && model.collections.count > 0) {
                            return model.collections.get(0).name
                        }
                        return "LISTVIEW"
                    }
                    width: parent.width
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    color: "#888888"
                    maximumLineCount: 1
                }

                Text {
                    text: model.lastPlayed ? Qt.formatDateTime(model.lastPlayed, "dd/MM/yyyy") : ""
                    width: parent.width
                    font.pixelSize: 9
                    color: "#666666"
                    visible: text !== ""
                }
            }
        }

        Rectangle {
            visible: ListView.isCurrentItem && lastPlayedList.focus
            width: 4
            height: parent.height - 10
            color: "#4d99e6"
            radius: 2
            anchors {
                left: parent.left
                leftMargin: 2
                verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (mouseNavigationEnabled) {
                    lastPlayedList.currentIndex = index
                    lastPlayedList.forceActiveFocus()
                    if (typeof keyboard !== 'undefined') {
                        keyboard.resetKeyboard()
                    }
                    if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                }
            }
        }
    }

    header: Rectangle {
        width: lastPlayedList.width
        height: 35
        color: currentTheme.secondary
        radius: 8

        Text {
            text: "Play History"
            anchors.centerIn: parent
            font.pixelSize: 12
            font.bold: true
            color: "#4d99e6"
        }
    }

    onFocusChanged: {
        if (focus && count > 0) {
            if (currentIndex < 0) {
                currentIndex = 0
            }

            Qt.callLater(function() {
                if (focus && count > 0) {
                    var tempIndex = currentIndex
                    currentIndex = -1
                    currentIndex = tempIndex
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
            else if (event.key === Qt.Key_Right) {
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
}
