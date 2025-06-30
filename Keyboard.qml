import QtQuick 2.15

FocusScope {
    id: keyboard
    width: parent.width
    height: parent.height

    property var onKeySelected: function(key) {}
    property var onCloseRequested: function() {}
    signal closeRequested()
    property int currentRow: 0
    property int currentCol: 0
    property var currentTheme
    property bool mouseNavigationEnabled: true
    property real keyboardWidthScale: 0.9

    property var allKeys: ["A", "B", "C", "D", "E", "F",
    "G", "H", "I", "J", "K", "L",
    "M", "N", "O", "P", "Q", "R",
    "S", "T", "U", "V", "W", "X",
    "Y", "Z", "0", "1", "2", "3",
    "4", "5", "6", "7", "8", "9"]

    function resetKeyboard() {
        currentRow = 0;
        currentCol = 0;
    }

    function transferFocusToSearchResults() {
        if (typeof searchResultsView !== 'undefined' && searchResultsView.count > 0) {
            if (searchResultsView.currentIndex < 0) {
                searchResultsView.currentIndex = 0
            }
            searchResultsView.forceActiveFocus()
            if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
        }
    }

    function transferFocusToLastPlayed() {
        if (typeof lastPlayedList !== 'undefined' && lastPlayedList.count > 0) {
            if (lastPlayedList.currentIndex < 0) {
                lastPlayedList.currentIndex = 0
            }
            lastPlayedList.forceActiveFocus()
            if (typeof lastPlayedList.refreshCurrentItem === 'function') {
                Qt.callLater(lastPlayedList.refreshCurrentItem)
            }
            if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
        }
    }

    function transferFocusToFavorites() {
        if (typeof favoriteList !== 'undefined' && favoriteList.count > 0) {
            if (favoriteList.currentIndex < 0) {
                favoriteList.currentIndex = 0
            }
            favoriteList.forceActiveFocus()
            if (typeof favoriteList.refreshCurrentItem === 'function') {
                Qt.callLater(favoriteList.refreshCurrentItem)
            }
            if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
        }
    }

    function navigate(direction) {
        var oldRow = currentRow
        var oldCol = currentCol
        var maxCol = (currentRow === 6) ? 2 : 5

        switch(direction) {
            case "up":
                if (currentRow > 0) {
                    currentRow--
                } else if (currentRow === 0) {
                    currentRow = 6
                    currentCol = Math.min(currentCol, 2)
                }
                break
            case "down":
                if (currentRow < 5) {
                    currentRow++
                } else if (currentRow === 5) {
                    currentRow = 6
                    currentCol = Math.min(currentCol, 2)
                } else if (currentRow === 6) {
                    transferFocusToSearchResults()
                    return
                }
                break
            case "left":
                if (currentCol > 0) {
                    currentCol--
                } else if (currentCol === 0 && currentRow < 6) {
                    transferFocusToLastPlayed()
                    return
                } else if (currentRow > 0 && currentRow < 6) {
                    currentRow--
                    currentCol = 5
                } else if (currentRow === 6 && currentCol > 0) {
                    currentCol--
                }
                break
            case "right":
                var maxCol = (currentRow === 6) ? 2 : 5
                if (currentCol < maxCol) {
                    currentCol++
                } else if (currentCol === 5 && currentRow < 6) {
                    transferFocusToFavorites()
                    return
                } else if (currentRow < 5) {
                    currentRow++
                    currentCol = 0
                } else if (currentRow === 6 && currentCol < 2) {
                    currentCol++
                }
                break
        }

        if (currentRow === 6 && currentCol > 2) {
            currentCol = 2
        }
    }

    function selectCurrentKey() {
        if (currentRow < 6) {
            var index = currentRow * 6 + currentCol
            if (index < allKeys.length) {
                onKeySelected(allKeys[index])
            }
        } else {
            if (currentCol === 0) {
                onKeySelected(" ")
            } else if (currentCol === 1) {
                onKeySelected("")
            } else if (currentCol === 2) {
                if (typeof searchBar !== 'undefined' && searchBar.text.length > 0) {
                    searchBar.text = searchBar.text.substring(0, searchBar.text.length - 1)
                }
            }
        }
    }

    Keys.onPressed: {
        if (!event.isAutoRepeat) {
            if (api.keys.isAccept(event)) {
                selectCurrentKey()
                if (typeof soundEffects !== 'undefined') soundEffects.play("go")
                    event.accepted = true
            }
            else if (api.keys.isCancel(event)) {
                closeRequested()
                event.accepted = true
            }
            else if (event.key === Qt.Key_Up) {
                navigate("up")
                if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                    event.accepted = true
            }
            else if (event.key === Qt.Key_Down) {
                navigate("down")
                if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                    event.accepted = true
            }
            else if (event.key === Qt.Key_Left) {
                navigate("left")
                if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                    event.accepted = true
            }
            else if (event.key === Qt.Key_Right) {
                navigate("right")
                if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                    event.accepted = true
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: keyboard.width * 0.02

        Column {
            anchors.fill: parent
            spacing: 10

            Item {
                width: parent.width
                height: parent.height * 0.78
                Grid {
                    id: keyGrid
                    anchors.centerIn: parent
                    width: parent.width * keyboardWidthScale
                    height: parent.height * 0.9
                    columns: 6
                    spacing: Math.max(4, width * 0.01)
                    property real keyWidth: (width - (columns - 1) * spacing) / columns
                    property real keyHeight: (height - 5 * spacing) / 6

                    Repeater {
                        model: keyboard.allKeys
                        delegate: Rectangle {
                            width: keyGrid.keyWidth
                            height: keyGrid.keyHeight
                            color: "transparent"
                            Rectangle {
                                anchors.fill: parent
                                radius: Math.max(4, width * 0.08)
                                color: {
                                    var row = Math.floor(index / 6)
                                    var col = index % 6
                                    var isSelected = (keyboard.currentRow === row && keyboard.currentCol === col && keyboard.currentRow < 6)
                                    return (isSelected && keyboard.activeFocus) ? "#4d99e6" : Qt.rgba(0, 0, 0, 0.2)
                                }
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                Text {
                                    text: modelData
                                    anchors.centerIn: parent
                                    font.pixelSize: Math.max(20, Math.min(parent.width, parent.height) * 0.35)
                                    font.bold: {
                                        var row = Math.floor(index / 6)
                                        var col = index % 6
                                        return (keyboard.currentRow === row && keyboard.currentCol === col && keyboard.currentRow < 6 && keyboard.activeFocus)
                                    }
                                    color: {
                                        var row = Math.floor(index / 6)
                                        var col = index % 6
                                        var isSelected = (keyboard.currentRow === row && keyboard.currentCol === col && keyboard.currentRow < 6 && keyboard.activeFocus)
                                        return isSelected ? "black" : "white"
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (mouseNavigationEnabled) {
                                        keyboard.currentRow = Math.floor(index / 6)
                                        keyboard.currentCol = index % 6
                                        keyboard.forceActiveFocus()
                                        keyboard.onKeySelected(modelData)
                                        if (typeof soundEffects !== 'undefined') soundEffects.play("go")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: parent.height * 0.2

                Row {
                    id: specialButtonsRow
                    anchors.centerIn: parent
                    spacing: 10
                    property real buttonWidth: keyGrid.keyWidth
                    property real buttonHeight: keyGrid.keyHeight

                    Rectangle {
                        width: specialButtonsRow.buttonWidth
                        height: specialButtonsRow.buttonHeight
                        radius: Math.max(4, width * 0.08)
                        color: (keyboard.currentRow === 6 && keyboard.currentCol === 0 && keyboard.activeFocus) ? "#4d99e6" : Qt.rgba(0, 0, 0, 0.2)

                        Text {
                            text: "SPACE"
                            anchors.centerIn: parent
                            font.pixelSize: Math.max(15, Math.min(parent.width, parent.height) * 0.32)
                            font.bold: (keyboard.currentRow === 6 && keyboard.currentCol === 0 && keyboard.activeFocus)
                            color: (keyboard.currentRow === 6 && keyboard.currentCol === 0 && keyboard.activeFocus) ? "black" : "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                keyboard.currentRow = 6
                                keyboard.currentCol = 0
                                keyboard.forceActiveFocus()
                                keyboard.onKeySelected(" ")
                                if (typeof soundEffects !== 'undefined') soundEffects.play("go")
                            }
                        }
                    }

                    Rectangle {
                        width: specialButtonsRow.buttonWidth
                        height: specialButtonsRow.buttonHeight
                        radius: Math.max(4, width * 0.08)
                        color: (keyboard.currentRow === 6 && keyboard.currentCol === 1 && keyboard.activeFocus) ? "#4d99e6" : Qt.rgba(0, 0, 0, 0.2)

                        Text {
                            text: "CLEAR"
                            anchors.centerIn: parent
                            font.pixelSize: Math.max(15, Math.min(parent.width, parent.height) * 0.32)
                            font.bold: (keyboard.currentRow === 6 && keyboard.currentCol === 1 && keyboard.activeFocus)
                            color: (keyboard.currentRow === 6 && keyboard.currentCol === 1 && keyboard.activeFocus) ? "black" : "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                keyboard.currentRow = 6
                                keyboard.currentCol = 1
                                keyboard.forceActiveFocus()
                                keyboard.onKeySelected("")
                                if (typeof soundEffects !== 'undefined') soundEffects.play("go")
                            }
                        }
                    }

                    Rectangle {
                        width: specialButtonsRow.buttonWidth
                        height: specialButtonsRow.buttonHeight
                        radius: Math.max(4, width * 0.08)
                        color: (keyboard.currentRow === 6 && keyboard.currentCol === 2 && keyboard.activeFocus) ? "#4d99e6" : Qt.rgba(0, 0, 0, 0.2)

                        Text {
                            text: "DEL"
                            anchors.centerIn: parent
                            font.pixelSize: Math.max(15, Math.min(parent.width, parent.height) * 0.32)
                            font.bold: (keyboard.currentRow === 6 && keyboard.currentCol === 2 && keyboard.activeFocus)
                            color: (keyboard.currentRow === 6 && keyboard.currentCol === 2 && keyboard.activeFocus) ? "black" : "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                keyboard.currentRow = 6
                                keyboard.currentCol = 2
                                keyboard.forceActiveFocus()
                                if (typeof searchBar !== 'undefined' && searchBar.text.length > 0) {
                                    searchBar.text = searchBar.text.substring(0, searchBar.text.length - 1)
                                }
                                if (typeof soundEffects !== 'undefined') soundEffects.play("go")
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        focus = true
        forceActiveFocus()
    }
}
