import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import "qrc:/qmlutils" as PegasusUtils
import "utils.js" as Utils

Item {
    id: gameDetails
    width: parent.width * 0.35
    height: parent.height
    anchors.right: parent.right
    visible: false
    focus: visible
    property bool isClosing: false
    property var currentTheme: root.currentTheme
    property string currentThemeName: root.currentThemeName

    function applyTheme(themeName) {
        if (themeName === "DARK THEME") {
            currentTheme = root.themes.dark;
        } else {
            currentTheme = root.themes.light;
        }
    }

    Connections {
        target: root
        function onCurrentThemeChanged() {
            gameDetails.currentTheme = root.currentTheme;
            gameDetails.currentThemeName = root.currentThemeName;
        }
    }

    Component.onCompleted: {
        applyTheme(root.currentThemeName);
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    Keys.onPressed: function(event) {
        if (!event.isAutoRepeat) {
            if (api.keys.isCancel(event)) {
                event.accepted = true;
                isClosing = true;
                visible = false;
                soundEffects.play("back");
            }
        }
    }

    property var currentGame: root.game

    Rectangle {
        anchors.fill: parent
        color: currentTheme.primary

        Flickable {
            anchors {
                fill: parent
                topMargin: 10
            }
            contentHeight: detailsColumn.height + 40
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: detailsColumn
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                anchors.topMargin: 10

                Text {
                    id: gameTitle
                    text: game && game.title ? game.title : ""
                    color: currentTheme.buttomText
                    font.pixelSize: Math.min(root.height * 0.025, root.width * 0.03)
                    font.bold: true
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Rectangle {
                        Layout.fillWidth: true
                        height: gameDetails.height * 0.07
                        color: currentTheme.background
                        opacity: 1.0
                        border.color: currentTheme.bordercolor
                        border.width: 1
                        radius: 5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: "GENRE"
                                color: currentTheme.buttomText
                                font.pixelSize: Math.min(root.height * 0.015, root.width * 0.02)
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                text: {
                                    let genreText = game && game.genre ? game.genre : "Unknown";
                                    let separators = [",", "/", "-"];
                                    let allParts = [genreText];
                                    for (let separator of separators) {
                                        let newParts = [];
                                        for (let part of allParts) {
                                            newParts.push(...part.split(separator));
                                        }
                                        allParts = newParts;
                                    }

                                    allParts = allParts.map(part => part.trim()).filter(part => part.length > 0);

                                    if (allParts.length > 0) {
                                        return allParts[0];
                                    }

                                    return "Unknown";
                                }
                                color: currentTheme.text
                                font.pixelSize: Math.min(root.height * 0.018, root.width * 0.025)
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: gameDetails.height * 0.07
                        color: currentTheme.background
                        opacity: 1.0
                        border.color: currentTheme.bordercolor
                        border.width: 1
                        radius: 5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: "RELEASE DATE"
                                color: currentTheme.buttomText
                                font.pixelSize: Math.min(root.height * 0.015, root.width * 0.02)
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                text: game && game.releaseYear > 0 ? game.releaseYear.toString() : "Unknown"
                                color: currentTheme.text
                                font.pixelSize: Math.min(root.height * 0.018, root.width * 0.025)
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: gameDetails.height * 0.07
                        color: currentTheme.background
                        opacity: 1.0
                        border.color: currentTheme.bordercolor
                        border.width: 1
                        radius: 5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: "RATING"
                                color: currentTheme.buttomText
                                font.pixelSize: Math.min(root.height * 0.015, root.width * 0.02)
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                text: game && game.rating ? (game.rating * 100).toFixed(0) + "%" : "N/A"
                                color: currentTheme.text
                                font.pixelSize: Math.min(root.height * 0.018, root.width * 0.025)
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Rectangle {
                    id: descriptionContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: gameDetails.height * 0.5
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 5
                    border.color: currentTheme.textSelected
                    border.width: 1

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Item {
                            width: descriptionContainer.width
                            height: descriptionContainer.height
                            Rectangle {
                                anchors.top: parent.top
                                width: parent.width
                                height: parent.height * 0.15
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#00FFFFFF" }
                                    GradientStop { position: 1.0; color: "#FFFFFFFF" }
                                }
                            }
                            Rectangle {
                                y: parent.height * 0.15
                                width: parent.width
                                height: parent.height * 0.7
                                color: "#FFFFFFFF"
                            }
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: parent.height * 0.15
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#FFFFFFFF" }
                                    GradientStop { position: 1.0; color: "#00FFFFFF" }
                                }
                            }
                        }
                    }

                    PegasusUtils.AutoScroll {
                        id: autoscroll
                        anchors.fill: parent
                        pixelsPerSecond: 15
                        scrollWaitDuration: 3000

                        Item {
                            width: autoscroll.width
                            height: childrenRect.height + topPadding + bottomPadding

                            property real topPadding: autoscroll.height * 0.03
                            property real bottomPadding: autoscroll.height * 0.03
                            property real sidePadding: autoscroll.width * 0.05

                            Item {
                                id: topSpacer
                                width: parent.width
                                height: parent.topPadding
                            }

                            Text {
                                id: descripText
                                anchors {
                                    top: topSpacer.bottom
                                    left: parent.left
                                    leftMargin: parent.width * 0.01
                                }
                                text: game && game.description ? game.description : "No description available..."
                                width: parent.width - (parent.sidePadding * 2)
                                wrapMode: Text.Wrap
                                font.pixelSize: Math.min(root.height * 0.022, root.width * 0.026)
                                color: currentTheme.text
                                layer.enabled: true
                                layer.effect: DropShadow {
                                    color: currentTheme.background
                                    radius: 2
                                    samples: 5
                                    spread: 0.5
                                }
                            }

                            Item {
                                id: bottomSpacer
                                anchors.top: descripText.bottom
                                width: parent.width
                                height: parent.bottomPadding - 10
                            }
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 15
                    rowSpacing: 15

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: gameDetails.height * 0.09
                        color: currentTheme.background
                        opacity: 1.0
                        border.color: currentTheme.bordercolor
                        border.width: 1
                        radius: 5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: "DEVELOPER"
                                color: currentTheme.buttomText
                                font.pixelSize: Math.min(root.height * 0.015, root.width * 0.02)
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                text: game && game.developer ? game.developer : "Unknown"
                                color: currentTheme.text
                                font.pixelSize: Math.min(root.height * 0.018, root.width * 0.025)
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: gameDetails.height * 0.09
                        color: currentTheme.background
                        opacity: 1.0
                        border.color: currentTheme.bordercolor
                        border.width: 1
                        radius: 5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: "PUBLISHER"
                                color: currentTheme.buttomText
                                font.pixelSize: Math.min(root.height * 0.015, root.width * 0.02)
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                text: game && game.publisher ? game.publisher : "Unknown"
                                color: currentTheme.text
                                font.pixelSize: Math.min(root.height * 0.018, root.width * 0.025)
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: gameDetails.height * 0.08
                        color: currentTheme.background
                        opacity: 1.0
                        border.color: currentTheme.bordercolor
                        border.width: 1
                        radius: 5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: "LAST PLAYED"
                                color: currentTheme.buttomText
                                font.pixelSize: Math.min(root.height * 0.015, root.width * 0.02)
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                text: Utils.calculateLastPlayedText(game && game.lastPlayed)
                                color: currentTheme.text
                                font.pixelSize: Math.min(root.height * 0.018, root.width * 0.025)
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: gameDetails.height * 0.08
                        color: currentTheme.background
                        opacity: 1.0
                        border.color: currentTheme.bordercolor
                        border.width: 1
                        radius: 5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: "PLAY TIME"
                                color: currentTheme.buttomText
                                font.pixelSize: Math.min(root.height * 0.015, root.width * 0.02)
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                text: Utils.calculatePlayTimeText(game && game.playTime, false)
                                color: currentTheme.text
                                font.pixelSize: Math.min(root.height * 0.018, root.width * 0.025)
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: gameDetails.height * 0.08
                    color: currentTheme.background
                    opacity: 1.0
                    border.color: currentTheme.bordercolor
                    border.width: 1
                    radius: 5

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        Text {
                            text: "COLLECTION"
                            color: currentTheme.buttomText
                            font.pixelSize: Math.min(root.height * 0.015, root.width * 0.02)
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }

                        Text {
                            text: Utils.getNameCollecForGame(game, api)
                            color: currentTheme.text
                            font.pixelSize: Math.min(root.height * 0.018, root.width * 0.025)
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                        }
                    }
                }
            }
        }
    }
}
