import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

GridView {
    id: gameGridView
    property int indexToPosition: -1
    property real selectedItemX: 0
    property real selectedItemY: 0
    property real viewportX: contentX + width / 2
    property real viewportY: contentY + height / 2
    property string currentShortName: ""
    property var rootItem: null
    property var safeModel: model || null

    width: parent.width * 0.95
    height: parent.height
    cellWidth: width / 4
    cellHeight: height / 3

    onModelChanged: {
        if (model && model.count > 0) {
            currentIndex = 0;
            if (rootItem) {
                rootItem.game = model.get(currentIndex);
                if (rootItem.bottomBar) {
                    rootItem.bottomBar.selectedGame = model.get(currentIndex);
                }
            }
        } else {
            currentIndex = -1;
            if (rootItem) {
                rootItem.game = null;
                if (rootItem.bottomBar) {
                    rootItem.bottomBar.selectedGame = null;
                }
            }
        }
    }

    clip: true
    keyNavigationEnabled: true
    keyNavigationWraps: true
    cacheBuffer: cellHeight * 4
    displayMarginBeginning: cellHeight
    displayMarginEnd: cellHeight
    reuseItems: true

    opacity: 1
    Behavior on opacity {
        NumberAnimation {
            duration: launchTimer.interval
            easing.type: Easing.InQuad
        }
    }

    delegate: Rectangle {
        id: rectanglegridview
        property bool isSelected: GridView.isCurrentItem && gameGridView.activeFocus
        property bool hasScreenshot: model.assets.screenshot && model.assets.screenshot.toString() !== ""
        property bool hasLogo: model.assets.logo && model.assets.logo.toString() !== ""

        width: gameGridView.cellWidth
        height: gameGridView.cellHeight
        color: "transparent"

        function updateOriginPoint() {
            if (isSelected && gameImage.status === Image.Ready) {
                var boxfrontItem = gameImage
                var boxfrontCenter = boxfrontItem.mapToItem(null,
                                                            boxfrontItem.width * boxfrontItem.scale / 2,
                                                            boxfrontItem.height * boxfrontItem.scale / 2)
            }
        }

        Item {
            width: parent.width
            height: parent.height
            anchors.margins: 2
            anchors.fill: parent

            Item {
                id: columnrectangle
                width: parent.width
                height: parent.height

                Item {
                    anchors.fill: parent

                    Image {
                        id: gameImage
                        visible: false
                        source: hasScreenshot ? model.assets.screenshot : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        width: parent.width * 0.93
                        height: parent.height * 0.93
                        anchors.centerIn: parent
                        mipmap: true
                        cache: true
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: false
                    }

                    Rectangle {
                        id: roundedMask
                        width: gameImage.width
                        height: gameImage.height
                        anchors.centerIn: parent
                        radius: 15
                        visible: false
                    }

                    OpacityMask {
                        id: maskedImage
                        width: gameImage.width
                        height: gameImage.height
                        anchors.centerIn: parent
                        source: gameImage
                        maskSource: roundedMask
                        visible: hasScreenshot && gameImage.status === Image.Ready
                        scale: isSelected && gameGridView.focus ? 1.04 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                onRunningChanged: {
                                    if (!running && isSelected) {
                                        rectanglegridview.updateOriginPoint()
                                    }
                                }
                            }
                        }

                        layer.enabled: isSelected && hasScreenshot
                        layer.effect: Glow {
                            samples: 100
                            color: root.currentTheme.gridviewborder
                            spread: 0.5
                            radius: 22
                        }
                    }

                    Connections {
                        target: gameImage
                        function onStatusChanged() {
                            if (gameImage.status === Image.Ready && isSelected) {
                                rectanglegridview.updateOriginPoint()
                            }
                        }
                    }

                    Image {
                        id: gameLogo
                        source: hasLogo ? model.assets.logo : ""
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        width: parent.width * 0.8
                        height: parent.height * 0.3
                        anchors.centerIn: parent
                        opacity: (hasScreenshot ? (gameImage.status === Image.Ready ? (isSelected ? 1.0 : 0.7) : 0) : 
                                (hasLogo ? (isSelected ? 1.0 : 0.7) : 0))
                        visible: opacity > 0 && hasLogo
                        mipmap: true
                        cache: true
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: false
                        anchors.verticalCenterOffset: isSelected && gameGridView.focus ? -3 : 0
                        scale: isSelected && gameGridView.focus ? 1.05 : 1.0
                        layer.enabled: true
                        layer.effect: isSelected ? glowEffect : dropShadowEffect

                        Component {
                            id: glowEffect
                            Glow {
                                samples: 30
                                color: "white"
                                spread: 0.2
                                radius: 8
                            }
                        }

                        Component {
                            id: dropShadowEffect
                            DropShadow {
                                transparentBorder: true
                                horizontalOffset: 2
                                verticalOffset: 2
                                radius: 8
                                samples: 16
                                color: "#80000000"
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutQuad
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutQuad
                            }
                        }

                        Behavior on anchors.verticalCenterOffset {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutBack
                            }
                        }
                    }

                    Rectangle {
                        id: titleContainer
                        width: maskedImage.width
                        height: maskedImage.height * 0.15
                        radius: 15
                        color: "#AA000000"
                        anchors {
                            bottom: maskedImage.bottom
                            horizontalCenter: maskedImage.horizontalCenter
                        }
                        opacity: isSelected ? 1 : 0
                        visible: opacity > 0

                        states: [
                            State {
                                name: "selected"
                                when: isSelected
                                PropertyChanges {
                                    target: titleContainer
                                    anchors.bottomMargin: 5
                                }
                            },
                            State {
                                name: "unselected"
                                when: !isSelected
                                PropertyChanges {
                                    target: titleContainer
                                    anchors.bottomMargin: -height
                                }
                            }
                        ]

                        transitions: Transition {
                            NumberAnimation { properties: "anchors.bottomMargin,opacity"; duration: 150 }
                        }

                        Text {
                            anchors.fill: parent
                            anchors.margins: 3
                            text: model.title
                            color: "white"
                            font.pixelSize: Math.min(root.height * 0.016, root.width * 0.035)
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        id: topElementsContainer
                        width: maskedImage.width
                        height: maskedImage.height * 0.15
                        anchors {
                            top: maskedImage.top
                            horizontalCenter: maskedImage.horizontalCenter
                        }

                        Rectangle {
                            id: lastPlayedContainer
                            width: parent.width * 0.7
                            height: parent.height
                            radius: 15
                            color: "#AA000000"
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                top: parent.top
                            }
                            opacity: isSelected ? 1 : 0
                            visible: opacity > 0 && gameGridView.currentShortName === "history"
                            scale: isSelected && gameGridView.focus ? 1.04 : 1.0

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 150
                                }
                            }

                            Text {
                                anchors.fill: parent
                                anchors.margins: 3
                                text: "Last played: " + Qt.formatDateTime(model.lastPlayed, "dd/MM/yyyy")
                                color: "white"
                                font.pixelSize: Math.min(root.height * 0.016, root.width * 0.035)
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            states: [
                                State {
                                    name: "selected"
                                    when: isSelected
                                    PropertyChanges {
                                        target: lastPlayedContainer
                                        anchors.topMargin: 0
                                    }
                                },
                                State {
                                    name: "unselected"
                                    when: !isSelected
                                    PropertyChanges {
                                        target: lastPlayedContainer
                                        anchors.topMargin: -height
                                    }
                                }
                            ]

                            transitions: Transition {
                                NumberAnimation { properties: "anchors.topMargin,opacity"; duration: 150 }
                            }
                        }

                        Item {
                            id: favoriteIconContainer
                            width: parent.height * 0.8
                            height: parent.height * 0.8
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                rightMargin: parent.width * 0.03
                            }
                            visible: model.favorite && gameImage.status === Image.Ready

                            Rectangle {
                                id: favoriteIconBackground
                                anchors.fill: parent
                                color: Qt.rgba(0, 0, 0, 0.6)
                                radius: width / 2
                                visible: true
                            }

                            Image {
                                id: favoriteIcon
                                anchors.centerIn: parent
                                width: parent.width * 0.7
                                height: parent.height * 0.7
                                source: "assets/favorite/favorite.svg"
                                mipmap: true
                                fillMode: Image.PreserveAspectFit
                            }

                            scale: isSelected && gameGridView.focus ? 1.2 : 1.0
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        states: [
                            State {
                                name: "selected"
                                when: isSelected
                                PropertyChanges {
                                    target: topElementsContainer
                                    anchors.topMargin: parent.height * 0.02
                                }
                            },
                            State {
                                name: "unselected"
                                when: !isSelected
                                PropertyChanges {
                                    target: topElementsContainer
                                    anchors.topMargin: parent.height * 0.02
                                }
                            }
                        ]
                    }

                    Image {
                        id: noImage
                        visible: !hasScreenshot && !hasLogo
                        source: isSelected ? "assets/.no-image/no-image-white.png" : "assets/.no-image/no-image-black.png"
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        width: parent.width * 0.60
                        height: parent.height * 0.60
                        mipmap: true
                        opacity: 0.7
                    }
                }
            }
        }

        Component.onCompleted: {
            if (isSelected) {
                updateSelectedItemPosition()
            }
        }

        function updateSelectedItemPosition() {
            if (isSelected) {
                var itemRect = rectanglegridview.mapToItem(gameGridView, 0, 0, width, height)
                gameGridView.selectedItemX = itemRect.x + (itemRect.width / 2)
                gameGridView.selectedItemY = itemRect.y + (itemRect.height / 2)
            }
        }
    }

    Item {
        id: emptyCollection
        anchors.centerIn: parent
        width: parent.width * 0.5
        height: parent.height * 0.5
        visible: gameGridView.count === 0
        opacity: 0
        property bool initialAnimationComplete: false

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 10
            Text {
                text: "The " + gameGridView.currentShortName + " collection is empty"
                font.pixelSize: Math.min(root.height * 0.04, root.width * 0.07)
                color: root.currentTheme.text
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                width: parent.width * 0.70
                height: parent.height * 0.70
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: collectionsIcons
                    source: gameGridView.currentShortName === "favorite"
                    ? "assets/icons/addfavorite.svg"
                    : "assets/icons/history.svg"
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    width: parent.width
                    height: parent.height
                    mipmap: true
                    visible: true
                    anchors.centerIn: parent
                }

                ColorOverlay {
                    anchors.fill: collectionsIcons
                    source: collectionsIcons
                    color: root.currentTheme.text
                    antialiasing: true
                }
            }
        }

        Timer {
            id: initialAnimationTimer
            interval: 5500
            running: true
            repeat: false
            onTriggered: {
                emptyCollection.initialAnimationComplete = true
                if (gameGridView.count === 0) {
                    emptyCollection.opacity = 1
                }
            }
        }
    }

    states: [
        State {
            name: "empty"
            when: gameGridView.count === 0 && emptyCollection.initialAnimationComplete
            PropertyChanges {
                target: emptyCollection
                opacity: 1
            }
        },
        State {
            name: "notEmpty"
            when: gameGridView.count > 0
            PropertyChanges {
                target: emptyCollection
                opacity: 0
            }
        }
    ]

    Keys.onPressed: {
        if (!event.isAutoRepeat) {
            if (api.keys.isAccept(event)) {
                event.accepted = true;
                gameGridView.focus = false;
                root.showGameInfo();
                soundEffects.play("go");
            }
            else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right ||
                event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
                soundEffects.play("navi");
            if (currentItem) {
                currentItem.updateSelectedItemPosition()
            }
                }
                else if (api.keys.isCancel(event)) {
                    event.accepted = true;
                    soundEffects.play("back");
                    root.focusManager.setFocus("collections", "games");
                }
                else if (api.keys.isDetails(event)) {
                    event.accepted = true;
                    soundEffects.play("fav");
                    if (model && currentIndex >= 0 && currentIndex < count) {
                        var game = safeModel.get(currentIndex);
                        if (game && rootItem) {
                            rootItem.toggleFavorite(game);
                            rootItem.game = game;
                            model = model;
                        }
                    }
                }
                else if (api.keys.isFilters(event)) {
                    event.accepted = true;
                    root.searchVisible = true;
                    soundEffects.play("go");
                }
        }

        if (api.keys.isNextPage(event)) {
            soundEffects.play("navi");
            collectionListView.incrementCurrentIndex()
            collectionListView.focus = true
        } else if (api.keys.isPrevPage(event)) {
            soundEffects.play("navi");
            collectionListView.decrementCurrentIndex()
            collectionListView.focus = true
        }
    }

    onCurrentItemChanged: {
        if (gameGridView.count > 0 && gameGridView.focus && currentIndex >= 0) {
            if (rootItem) {
                rootItem.game = safeModel.get(currentIndex);
                if (rootItem.bottomBar) {
                    rootItem.bottomBar.selectedGame = safeModel.get(currentIndex);
                }
            }
            indexToPosition = currentIndex;
            if (currentItem) {
                currentItem.updateSelectedItemPosition();
            }
        } else if (rootItem && rootItem.bottomBar) {
            rootItem.bottomBar.selectedGame = null;
        }
    }

    function toggleFavorite(game) {
        if (rootItem) {
            rootItem.toggleFavorite(game);
        }
    }
}
