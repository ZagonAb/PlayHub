import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

ListView {
    id: collectionListView
    width: parent.width * 0.90
    model: collectionsModel.getModel()
    orientation: Qt.Horizontal
    spacing: 5
    clip: true
    anchors.top: parent.top
    anchors.topMargin: parent.height * 0.01
    anchors.horizontalCenter: parent.horizontalCenter
    property string currentShortName: ""
    property string currentCollectionName: ""
    property int indexToPosition: -1
    property bool modelInitialized: false
    property var currentCollection: model && currentIndex >= 0 ? model.get(currentIndex) : null

    ColorMapping {
        id: colorMapping
    }

    onModelChanged: {
        if (model && model.count > 0) {
            modelInitialized = true;
            if (collectionsModel.favoritesIndex >= 0) {
                collectionsModel.favoritesModel.invalidate();
            }
        }
    }

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

        property real imageScale: collectionListView.activeFocus && index === collectionListView.currentIndex ? 1.0 : 0.8

        Behavior on imageScale {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
        }

        width: {
            if (!root || !collectionListView) return 100;

            if (index === collectionListView.currentIndex) {
                return root.width * 0.150;
            } else if (Math.abs(index - collectionListView.currentIndex) === 1) {
                return root.width * 0.075;
            } else {
                return root.width * 0.070;
            }
        }
        height: collectionListView.height
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
        }

        Rectangle {
            id: bg
            anchors.fill: parent
            color: "transparent"
            border.color: currentTheme.secondary
            border.width: 2
            radius: 15

            gradient: Gradient {
                GradientStop {
                    position: 0.0;
                    color: {
                        var customColor = colorMapping.colorMap[model.shortName.toLowerCase()];
                        return customColor ? customColor : (index === collectionListView.currentIndex && collectionListView.focus ?
                        currentTheme.secondary : currentTheme.background);
                    }
                }
                GradientStop {
                    position: 1.0;
                    color: currentTheme.background
                }
            }

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }

        Item {
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: parent.height * 0.9

            Image {
                id: collectionLogo
                anchors.fill: parent
                source: model.shortName ? "assets/logos/" + model.shortName.toLowerCase() + ".png" : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: status === Image.Ready
                mipmap: true
                scale: collectionlistview.imageScale
                transformOrigin: Item.Center

                layer.enabled: true
                layer.effect: Glow {
                    samples: 16
                    color: Qt.rgba(currentTheme.background.r, currentTheme.background.g, currentTheme.background.b,
                                   index === collectionListView.currentIndex ? 0.3 : 0)
                    radius: index === collectionListView.currentIndex ? 10 : 0
                    spread: 0.4
                }
            }

            Text {
                id: collectionname
                anchors.centerIn: parent
                text: model.shortName.toUpperCase()
                color: index === collectionListView.currentIndex ? currentTheme.textSelected : currentTheme.text
                font.bold: true
                font.pixelSize: parent.height * 0.1
                visible: collectionLogo.status !== Image.Ready
                scale: collectionlistview.imageScale
                transformOrigin: Item.Center
            }
        }

        Rectangle {
            id: indicator
            width: parent.width * 0.8 * animScale
            height: 3
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: -1
            }
            color: currentTheme.text
            radius: 2
            visible: index === collectionListView.currentIndex && collectionListView.focus
            property real animScale: 0

            Behavior on animScale {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutQuad
                }
            }

            onVisibleChanged: {
                if (visible) {
                    animScale = 0
                    animScale = 1
                } else {
                    animScale = 0
                }
            }

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
        if (!model || currentIndex < 0) return;
        currentCollection = model.get(currentIndex);
        if (!currentCollection) return;
        currentShortName = currentCollection.shortName;
        currentCollectionName = currentCollection.name;

        if (currentCollection.shortName === "favorite") {
            if (!collectionsModel.favoritesLoaded) {
                gameGridView.model = null;
                Qt.callLater(function() {
                    collectionsModel.favoritesModel.invalidate();
                    gameGridView.model = currentCollection.games;
                    if (gameGridView.model && gameGridView.model.count > 0) {
                        gameGridView.currentIndex = 0;
                        root.game = gameGridView.model.get(0);
                    }
                });
            } else {
                gameGridView.model = currentCollection.games;
            }
        } else {
            gameGridView.model = currentCollection.games;
        }

        indexToPosition = currentIndex;
        if (gameGridView.model && gameGridView.model.count > 0) {
            gameGridView.currentIndex = 0;
            root.game = gameGridView.model.get(0);
        }
    }

    Keys.onLeftPressed: {
        if (currentIndex === 0) {
            event.accepted = true;
            root.focusManager.setFocus("settings", "collections");
            soundEffects.play("go");
        } else {
            decrementCurrentIndex();
            soundEffects.play("navi");
            if (model && currentIndex >= 0) {
                var collection = model.get(currentIndex);
                if (collection) {
                    currentShortName = collection.shortName;
                }
            }
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
            if (model && currentIndex >= 0) {
                var collection = model.get(currentIndex);
                if (collection) {
                    currentShortName = collection.shortName;
                }
            }
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
