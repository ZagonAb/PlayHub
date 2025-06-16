import QtQuick 2.15

Rectangle {
    id: searchBar
    width: parent.width * 0.6
    height: 60
    property var currentTheme
    property alias text: searchInput.text
    property alias clearText: searchInput.text
    color: currentTheme.primary
    border.color: focus ? "#4d99e6" : currentTheme.border
    radius: 15
    border.width: 3

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: focus ? currentTheme.text : "transparent"
        border.width: 1
        opacity: 0.7
    }

    TextInput {
        id: searchInput
        anchors.fill: parent
        anchors.margins: 15
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 20
        font.bold: true
        color: currentTheme.text
        clip: true
        selectByMouse: true

        onTextChanged: {
            if (typeof searchResultsView !== 'undefined' && searchResultsView) {
                searchResultsView.filter = text.toLowerCase()
            }
        }
    }

    Text {
        visible: searchInput.text.length === 0
        text: "Search games..."
        anchors.fill: searchInput
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 20
        color: currentTheme.text
        font.italic: true
    }

    Rectangle {
        visible: searchInput.text.length > 0
        width: 35
        height: 35
        radius: 17
        color: "#ff4444"
        anchors {
            right: parent.right
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }

        scale: clearMouseArea.pressed ? 0.9 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }

        Text {
            text: "×"
            font.pixelSize: 22
            font.bold: true
            anchors.centerIn: parent
            color: "white"
        }

        MouseArea {
            id: clearMouseArea
            anchors.fill: parent
            onClicked: {
                searchInput.text = ""
                searchInput.forceActiveFocus()
            }
        }
    }

    Rectangle {
        visible: searchInput.text.length > 0
        width: parent.width * 0.8
        height: 3
        color: "#4d99e6"
        radius: 1
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            horizontalCenter: parent.horizontalCenter
        }

        SequentialAnimation on opacity {
            running: searchInput.text.length > 0
            loops: Animation.Infinite
            NumberAnimation { to: 0.5; duration: 800 }
            NumberAnimation { to: 1.0; duration: 800 }
        }
    }
}
