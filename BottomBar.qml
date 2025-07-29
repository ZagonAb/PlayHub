import QtQuick 2.15
import QtGraphicalEffects 1.12

Rectangle {
    id: bottomBar
    color: "transparent"
    height: parent.height * 0.1
    width: parent.width

    property var selectedGame: null
    property real iconSize: Math.min(height * 0.7, width * 0.04)
    property var currentTheme
    property string currentTime
    property string currentCollectionName
    property int gameCount
    property int currentGameIndex
    property bool collectionListViewActiveFocus
    property bool settingsIconSelected

    Item {
        height: parent.height
        width: parent.width * 0.95
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Row {
            id: allrowicons
            anchors.right: backRow.left
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20
            visible: !settingsIconSelected

            Row {
                spacing: 5
                visible: true
                Rectangle {
                    width: bottomBar.iconSize
                    height: bottomBar.iconSize
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: searchicon
                        anchors.fill: parent
                        source: "assets/control/search.svg"
                        visible: false
                        mipmap: true
                        asynchronous: true
                    }

                    ColorOverlay {
                        anchors.fill: searchicon
                        source: searchicon
                        color: currentTheme.iconColor
                        cached: true
                    }
                }

                Text {
                    text: " SEARCH"
                    color: currentTheme.text
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 30)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                visible: !collectionListViewActiveFocus
                Rectangle {
                    width: bottomBar.iconSize
                    height: bottomBar.iconSize
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: favoriteicon
                        anchors.fill: parent
                        source: "assets/control/favorite.svg"
                        visible: false
                        mipmap: true
                        asynchronous: true
                    }

                    ColorOverlay {
                        anchors.fill: favoriteicon
                        source: favoriteicon
                        color: currentTheme.iconColor
                        cached: true
                    }
                }

                Text {
                    text: " FAVORITE"
                    color: currentTheme.text
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 30)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                visible: !collectionListViewActiveFocus
                Rectangle {
                    width: bottomBar.iconSize
                    height: bottomBar.iconSize
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: okicon
                        anchors.fill: parent
                        source: "assets/control/ok.svg"
                        visible: false
                        mipmap: true
                        asynchronous: true
                    }

                    ColorOverlay {
                        anchors.fill: okicon
                        source: okicon
                        color: currentTheme.iconColor
                        cached: true
                    }
                }

                Text {
                    text: " OK"
                    color: currentTheme.text
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 30)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 100
                }
            }

            Row {
                spacing: 5
                visible: collectionListViewActiveFocus
                Rectangle {
                    width: bottomBar.iconSize
                    height: bottomBar.iconSize
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: downicon
                        anchors.fill: parent
                        source: "assets/control/down.svg"
                        visible: false
                        mipmap: true
                        asynchronous: true
                    }

                    ColorOverlay {
                        anchors.fill: downicon
                        source: downicon
                        color: currentTheme.iconColor
                        cached: true
                    }
                }

                Text {
                    text: " GAMES"
                    color: currentTheme.text
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 30)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Row {
            id: backRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Rectangle {
                width: bottomBar.iconSize
                height: bottomBar.iconSize
                color: "transparent"
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: backicon
                    anchors.fill: parent
                    source: "assets/control/back.svg"
                    visible: false
                    mipmap: true
                }

                ColorOverlay {
                    anchors.fill: backicon
                    source: backicon
                    color: currentTheme.iconColor
                    cached: true
                    visible: true
                }
            }

            Text {
                text: " BACK"
                color: currentTheme.text
                font.bold: true
                font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 30)
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 5
                height: 1
                color: "transparent"
            }
        }

        Item {
            id: infoSection
            width: parent.width * 0.45
            height: parent.height
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15

                Row {
                    spacing: 5
                    id: timeThemeRow

                    Rectangle {
                        width: timeText.width + themeText.width + 20
                        height: bottomBar.height * 0.7
                        radius: height/2
                        color: Qt.rgba(currentTheme.textSelected.r, currentTheme.textSelected.g, currentTheme.textSelected.b, 0.05)
                        border.color: Qt.rgba(currentTheme.textSelected.r, currentTheme.textSelected.g, currentTheme.textSelected.b, 0.2)
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                id: timeText
                                text: currentTime
                                color: currentTheme.text
                                font.bold: true
                                font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 30)
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 1
                                height: timeText.height * 0.6
                                color: currentTheme.text
                                opacity: 0.5
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                id: themeText
                                text: currentTheme === themes.light ? "LIGHT" : "DARK"
                                color: currentTheme.text
                                font.bold: true
                                font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 30)
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.8; to: 1; duration: 2000; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 1; to: 0.8; duration: 2000; easing.type: Easing.InOutSine }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: collectionText.width + 20
                    height: bottomBar.height * 0.7
                    radius: height/2
                    color: Qt.rgba(currentTheme.textSelected.r, currentTheme.textSelected.g, currentTheme.textSelected.b, 0.05)
                    border.color: Qt.rgba(currentTheme.textSelected.r, currentTheme.textSelected.g, currentTheme.textSelected.b, 0.2)
                    border.width: 1
                    visible: currentCollectionName !== ""

                    Text {
                        id: collectionText
                        text: currentCollectionName
                        anchors.centerIn: parent
                        font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 30)
                        color: currentTheme.text
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: Math.min(implicitWidth, infoSection.width * 0.3)
                    }

                    SequentialAnimation on scale {
                        running: collectionListViewActiveFocus
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 1.02; duration: 1000; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.02; to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
                    }
                }

                Rectangle {
                    width: gamesText.width + 20
                    height: bottomBar.height * 0.7
                    radius: height/2
                    color: Qt.rgba(currentTheme.textSelected.r, currentTheme.textSelected.g, currentTheme.textSelected.b, 0.05)
                    border.color: Qt.rgba(currentTheme.textSelected.r, currentTheme.textSelected.g, currentTheme.textSelected.b, 0.2)
                    border.width: 1
                    visible: gameCount > 0

                    Text {
                        id: gamesText
                        text: "Games: " + (gameCount > 0 ? (currentGameIndex + 1) + "/" + gameCount : "0/0")
                        anchors.centerIn: parent
                        font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 30)
                        color: currentTheme.text
                        font.bold: true
                    }

                    SequentialAnimation on scale {
                        running: !collectionListViewActiveFocus
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 1.02; duration: 1000; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.02; to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
                    }
                }
            }
        }
    }
}
