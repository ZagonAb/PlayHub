import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

ListView {
    id: collectionListView
    width: parent.width * 0.90
    height: 60
    model: collectionsModel.getModel()
    orientation: Qt.Horizontal
    spacing: 5
    clip: true
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    property string currentShortName: ""
    property int indexToPosition: -1

    Item {
        id: gradientOverlay
        anchors.top: collectionListView.top
        anchors.bottom: collectionListView.bottom
        anchors.left: collectionListView.left
        width: root.width * 0.015
        z: 2

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Qt.Horizontal
                GradientStop { position: 0.0; color: currentTheme.background }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.0) }
            }
        }
    }

    delegate: Item {
        id: collectionlistview

        width: {
            if (!root || !collectionListView) return 100;

            if (index === collectionListView.currentIndex && collectionListView.focus) {
                return root.width * 0.100;
            } else if (Math.abs(index - collectionListView.currentIndex) === 1) {
                return root.width * 0.075;
            } else {
                return root.width * 0.070;
            }
        }
        height: root.height * 0.04
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
        }

        Rectangle {
            id: bg
            anchors.fill: parent
            color: index === collectionListView.currentIndex && collectionListView.focus ?
            currentTheme.secondary : currentTheme.background
            border.color: currentTheme.secondary
            border.width: 2
            radius: 10

            gradient: Gradient {
                GradientStop {
                    position: 0.0;
                    color: Qt.lighter(index === collectionListView.currentIndex && collectionListView.focus ?
                    currentTheme.secondary : currentTheme.background, 1.1)
                }
                GradientStop {
                    position: 1.0;
                    color: index === collectionListView.currentIndex && collectionListView.focus ?
                    currentTheme.secondary : currentTheme.background
                }
            }

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }

        Text {
            id: collectionname
            anchors.centerIn: parent
            text: model.shortName.toUpperCase()
            color: index === collectionListView.currentIndex && collectionListView.focus ?
            currentTheme.textSelected : currentTheme.text
            font.bold: true
            font.pixelSize: parent ? parent.width * 0.14 : 12

            SequentialAnimation on opacity {
                running: index === collectionListView.currentIndex && collectionListView.focus
                loops: Animation.Infinite
                NumberAnimation { from: 0.9; to: 1; duration: 1200; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1; to: 0.9; duration: 1200; easing.type: Easing.InOutSine }
            }

            layer.enabled: true
            layer.effect: Glow {
                samples: 16
                color: Qt.rgba(currentTheme.primary.r, currentTheme.primary.g, currentTheme.primary.b,
                               index === collectionListView.currentIndex && collectionListView.focus ? 0.3 : 0)
                radius: index === collectionListView.currentIndex && collectionListView.focus ? 10 : 0
                spread: 0.2

                Behavior on radius {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }
            }
        }

        Rectangle {
            width: parent.width * 0.6
            height: 3
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: -1
            }
            color: currentTheme.text
            radius: 2
            visible: index === collectionListView.currentIndex && collectionListView.focus

            property real animProgress: 0
            SequentialAnimation on animProgress {
                running: visible
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: 1; duration: 1000; easing.type: Easing.InOutSine }
            }
        }
    }

    Item {
        id: endGradientOverlay
        anchors.top: collectionListView.top
        anchors.bottom: collectionListView.bottom
        anchors.right: parent.right
        width: root.width * 0.015
        z: 2
        visible: collectionListView.contentWidth > collectionListView.width

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Qt.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                GradientStop { position: 1.0; color: currentTheme.background }
            }
        }
    }

    onIndexToPositionChanged: {
        if (indexToPosition >= 0) {
            positionViewAtIndex(indexToPosition, ListView.Center)
        }
    }

    onCurrentIndexChanged: {
        const selectedCollection = model.get(currentIndex)
        gameGridView.model = model.get(currentIndex).games;
        currentShortName = selectedCollection.shortName
        indexToPosition = currentIndex
    }

    Keys.onLeftPressed: {
        if (currentIndex === 0) {
            event.accepted = true;
            root.focusManager.setFocus("settings", "collections");
            soundEffects.play("go");
        } else {
            decrementCurrentIndex();
            soundEffects.play("navi");
        }
    }

    Keys.onRightPressed: {
        if (root.settingsIconFocused) {
            event.accepted = true;
            root.focusManager.setFocus("collections", "settings");
            soundEffects.play("go");
        } else {
            incrementCurrentIndex();
            soundEffects.play("navi");
        }
    }

    Keys.onDownPressed: {
        if (gameGridView.model && gameGridView.model.count > 0) {
            root.focusManager.setFocus("games", "collections");
            soundEffects.play("go");
        } else {
            soundEffects.play("back");
        }
    }

    /*Keys.onPressed: {
        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            collectionListView.incrementCurrentIndex();
            soundEffects.play("navi");
        }
        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            collectionListView.decrementCurrentIndex();
            soundEffects.play("navi");
        }
    }*/

    Keys.onPressed: {
        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            collectionListView.incrementCurrentIndex();
            soundEffects.play("navi");
        }
        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            collectionListView.decrementCurrentIndex();
            soundEffects.play("navi");
        }
        if (api.keys.isFilters(event)) {
            event.accepted = true;
            root.searchVisible = true;
            soundEffects.play("go");
        }
    }
}
