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

    function transferFocusToLastPlayed() {
        if (typeof lastPlayedList !== 'undefined' && lastPlayedList.count > 0) {
            if (lastPlayedList.currentIndex < 0) {
                lastPlayedList.currentIndex = 0
            }
            lastPlayedList.forceActiveFocus()
            if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
        }
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


    Rectangle {
        anchors.fill: parent
        radius: 10
        border.color: currentTheme.border
        color: currentTheme.primary
        border.width: 2

        Column {
            anchors.fill: parent
            anchors.margins: keyboard.width * 0.02

            Item {
                width: parent.width
                height: parent.height * 0.78
                Grid {
                    id: keyGrid
                    anchors.centerIn: parent
                    width: parent.width * 0.95
                    height: parent.height * 0.9
                    columns: 6
                    spacing: Math.max(4, parent.width * 0.008)

                    Repeater {
                        model: keyboard.allKeys

                        delegate: Rectangle {
                            width: (keyGrid.width - (keyGrid.columns - 1) * keyGrid.spacing) / keyGrid.columns
                            height: (keyGrid.height - 5 * keyGrid.spacing) / 6

                            color: {
                                var row = Math.floor(index / 6)
                                var col = index % 6
                                var isSelected = (keyboard.currentRow === row && keyboard.currentCol === col && keyboard.currentRow < 6)
                                return (isSelected && keyboard.activeFocus) ? "#4d99e6" : currentTheme.secondary
                            }
                            radius: Math.max(4, width * 0.08)
                            border.color: currentTheme.border
                            border.width: 1

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.color: {
                                    var row = Math.floor(index / 6)
                                    var col = index % 6
                                    var isSelected = (keyboard.currentRow === row && keyboard.currentCol === col && keyboard.currentRow < 6)
                                    return (isSelected && keyboard.focus) ? "#55aaff" : "transparent"
                                }
                                border.width: 2
                            }

                            Text {
                                text: modelData
                                anchors.centerIn: parent
                                font.pixelSize: Math.max(12, parent.height * 0.25)
                                font.bold: {
                                    var row = Math.floor(index / 6)
                                    var col = index % 6
                                    return (keyboard.currentRow === row && keyboard.currentCol === col && keyboard.currentRow < 6 && keyboard.focus)
                                }

                                color: {
                                    var row = Math.floor(index / 6)
                                    var col = index % 6
                                    var isSelected = (keyboard.currentRow === row && keyboard.currentCol === col && keyboard.currentRow < 6)
                                    return (isSelected && keyboard.focus) ? "white" : currentTheme.text
                                }
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
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
                height: parent.height * 0.02
            }

            Item {
                width: parent.width
                height: parent.height * 0.2

                Row {
                    id: specialButtonsRow
                    anchors.centerIn: parent
                    spacing: Math.max(8, parent.width * 0.02)

                    property real buttonWidth: (parent.width * 0.8 - spacing * 2) / 3
                    property real buttonHeight: parent.height * 0.7

                    Rectangle {
                        width: specialButtonsRow.buttonWidth
                        height: specialButtonsRow.buttonHeight
                        color: (keyboard.currentRow === 6 && keyboard.currentCol === 0 && keyboard.activeFocus) ? "#4d99e6" : currentTheme.secondary
                        radius: Math.max(4, width * 0.05)
                        border.color: "#666666"
                        border.width: 1

                        Text {
                            text: "SPACE"
                            anchors.centerIn: parent
                            font.pixelSize: Math.max(10, parent.height * 0.25)
                            font.bold: (keyboard.currentRow === 6 && keyboard.currentCol === 0 && keyboard.focus)
                            color: (keyboard.currentRow === 6 && keyboard.currentCol === 0 && keyboard.focus) ? "white" : currentTheme.text
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                keyboard.currentRow = 6
                                keyboard.currentCol = 0
                                keyboard.forceActiveFocus()
                                keyboard.onKeySelected(" ")
                                if (typeof soundEffects !== 'undefined') soundEffects.play("go")
                            }
                            onEntered: {
                                if (keyboard.mouseNavigationEnabled) {
                                    keyboard.currentRow = 6
                                    keyboard.currentCol = 0
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: specialButtonsRow.buttonWidth
                        height: specialButtonsRow.buttonHeight
                        color: (keyboard.currentRow === 6 && keyboard.currentCol === 1 && keyboard.activeFocus) ? "#4d99e6" : currentTheme.secondary
                        radius: Math.max(4, width * 0.05)
                        border.color: "#666666"
                        border.width: 1

                        Text {
                            text: "CLEAR"
                            anchors.centerIn: parent
                            font.pixelSize: Math.max(10, parent.height * 0.25)
                            font.bold: (keyboard.currentRow === 6 && keyboard.currentCol === 1 && keyboard.focus)
                            color: (keyboard.currentRow === 6 && keyboard.currentCol === 1 && keyboard.focus) ? "white" : currentTheme.text
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                keyboard.currentRow = 6
                                keyboard.currentCol = 1
                                keyboard.forceActiveFocus()
                                keyboard.onKeySelected("")
                                if (typeof soundEffects !== 'undefined') soundEffects.play("go")
                            }
                            onEntered: {
                                if (keyboard.mouseNavigationEnabled) {
                                    keyboard.currentRow = 6
                                    keyboard.currentCol = 1
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: specialButtonsRow.buttonWidth
                        height: specialButtonsRow.buttonHeight
                        color: (keyboard.currentRow === 6 && keyboard.currentCol === 2 && keyboard.activeFocus) ? "#4d99e6" : currentTheme.secondary
                        radius: Math.max(4, width * 0.05)
                        border.color: "#666666"
                        border.width: 1

                        Text {
                            text: "DEL"
                            anchors.centerIn: parent
                            font.pixelSize: Math.max(10, parent.height * 0.25)
                            font.bold: (keyboard.currentRow === 6 && keyboard.currentCol === 2 && keyboard.focus)
                            color: (keyboard.currentRow === 6 && keyboard.currentCol === 2 && keyboard.focus) ? "white" : currentTheme.text
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                keyboard.currentRow = 6
                                keyboard.currentCol = 2
                                keyboard.forceActiveFocus()
                                if (typeof searchBar !== 'undefined' && searchBar.text.length > 0) {
                                    searchBar.text = searchBar.text.substring(0, searchBar.text.length - 1)
                                }
                                if (typeof soundEffects !== 'undefined') soundEffects.play("go")
                            }
                            onEntered: {
                                if (keyboard.mouseNavigationEnabled) {
                                    keyboard.currentRow = 6
                                    keyboard.currentCol = 2
                                }
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
