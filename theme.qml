// Pegasus Frontend - PlayHub
// Copyright (C) 2024  Gonzalo Abbate
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.8
import QtQuick.Window 2.15
import QtQuick.Particles 2.15

FocusScope {
    id: root
    focus: true
    property bool settingsIconSelected: false
    property bool settingsIconFocused: false
    property string currentTime: Qt.formatDateTime(new Date(), "dd-MM HH:mm")
    property var currentTheme: themes.blackAndWhite

    readonly property var themes: {
        "blackAndWhite": {
            background: "white",
            primary: "black",
            secondary: "white",
            text: "black",
            textSelected: "white",
            border: "black",
            gridviewborder: "#e0e0e0",
            settingsText: "black",
            iconColor: "black"
        },
        "darkBreeze": {
            background: "#1a1d1f",
            primary: "#214f66",
            secondary: "#1a1d1f",
            text: "#214f66",
            textSelected: "white",
            border: "#214f66",
            gridviewborder: "#214f66",
            settingsText: "#214f66",
            iconColor: "#214f66"

        },
        "breeze": {
            background: "#eff0f1",
            primary: "#3baae4",
            secondary: "#eff0f1",
            text: "#3baae4",
            textSelected: "white",
            border: "#3baae4",
            gridviewborder: "white",
            settingsText: "#3baae4",
            iconColor: "#3baae4"
        }
    }

    function applyTheme(themeName) {
        switch(themeName) {
            case "BLACK AND WHITE":
                currentTheme = themes.blackAndWhite;
                break;
            case "DARK BREZEE":
                currentTheme = themes.darkBreeze;
                break;
            case "BREZEE":
                currentTheme = themes.breeze;
                break;
        }
    }

    Component.onCompleted: {
        const savedTheme = api.memory.get('selectedTheme');
        if (savedTheme) {
            applyTheme(savedTheme);
        }
    }

    SoundEffect {
        id: naviSound
        source: "assets/audio/Collec.wav"
        volume: 0.2
    }

    SoundEffect {
        id: gameSound
        source: "assets/audio/Games.wav"
        volume: 0.2
    }

    Item {
        id: collectionsItem
        property alias favoritesModel: favoritesProxyModel
        property alias historyModel: continuePlayingProxyModel

        ListModel {
            id: collectionsModel
            property int favoritesIndex: -1
            property int historyIndex : - 1
            Component.onCompleted: {
                var favoritecollection = { name: "Favorite", shortName: "favorite", games: favoritesProxyModel };
                collectionsModel.append(favoritecollection);
                collectionsModel.favoritesIndex = collectionsModel.count - 1;
                var historycollection = { name: "History", shortName: "history", games: continuePlayingProxyModel };
                collectionsModel.append(historycollection);
                collectionsModel.historyIndex = collectionsModel.count - 1;
                for (var i = 0; i < api.collections.count; ++i) {
                    var collection = api.collections.get(i);
                    collectionsModel.append(collection);
                }
            }
        }

        SortFilterProxyModel {
            id: favoritesProxyModel
            sourceModel: api.allGames
            filters: ValueFilter { roleName: "favorite"; value: true }
        }

        SortFilterProxyModel {
            id: historyProxyModel
            sourceModel: api.allGames
            sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
        }

        ListModel {
            id: continuePlayingProxyModel
            Component.onCompleted: {
                var currentDate = new Date()
                var sevenDaysAgo = new Date(currentDate.getTime() - 7 * 24 * 60 * 60 * 1000)
                for (var i = 0; i < historyProxyModel.count; ++i) {
                    var game = historyProxyModel.get(i)
                    var lastPlayedDate = new Date(game.lastPlayed)
                    var playTimeInMinutes = game.playTime / 60
                    if (lastPlayedDate >= sevenDaysAgo && playTimeInMinutes > 1) {
                        continuePlayingProxyModel.append(game)
                    }
                }
            }
        }
    }

    Rectangle {
        id: conteiner
        width: parent.width
        height: parent.height * 0.92
        color: currentTheme.background

        Item {
            id: settingsImage
            width: parent.width * 0.05
            height: collectionListView.height
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: root.width * 0.005

            Rectangle {
                id: iconWrapper
                anchors.centerIn: parent
                width: parent.width * 0.5
                height: parent.height * 0.5
                color: "transparent"
                scale: settingsIconFocused ? 1.3 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                    }
                }

                Image {
                    id: settingsIcon
                    anchors.fill: parent
                    source: "assets/setting/setting.svg"
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }

                ColorOverlay {
                    id: iconOverlay
                    anchors.fill: settingsIcon
                    source: settingsIcon
                    color: currentTheme.iconColor
                    visible: true
                    cached: true

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }
        }

        ListView {
            id: collectionListView
            width: parent.width * 0.95
            height: 60
            model: collectionsModel
            orientation: Qt.Horizontal
            spacing: 5
            clip: true
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 10
            property string currentShortName: ""
            property int indexToPosition: -1

            Item {
                id: gradientOverlay
                anchors.top: collectionListView.top
                anchors.bottom: collectionListView.bottom
                anchors.left: settingsImage.right
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

            delegate: Rectangle {
                id: collectionlistview
                width: 120
                height: 40
                color: index === collectionListView.currentIndex && collectionListView.focus ?
                currentTheme.primary : currentTheme.secondary
                border.color: currentTheme.border
                border.width: 4
                radius: 10
                Text {
                    id: collectionname
                    anchors.centerIn: parent
                    text: model.shortName.toUpperCase()
                    color: index === collectionListView.currentIndex && collectionListView.focus ?
                    currentTheme.textSelected : currentTheme.text

                    font.bold: true
                    font.pixelSize: index === collectionListView.currentIndex && collectionListView.focus ? 17 : 14
                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            onIndexToPositionChanged: {
                if (indexToPosition >= 0) {
                    positionViewAtIndex(indexToPosition, ListView.Center)
                }
            }

            onCurrentIndexChanged: {
                const selectedCollection = collectionsModel.get(currentIndex)
                gameGridView.model = collectionsModel.get(currentIndex).games;
                currentShortName = selectedCollection.shortName
                indexToPosition = currentIndex
            }

            focus: true

            Keys.onLeftPressed: {
                if (collectionListView.currentIndex === 0) {
                    event.accepted = true;
                    collectionListView.focus = false;
                    settingsIconFocused = true;
                    settingsIconSelected = true;
                    colorListView.focus = true;
                    colorListView.currentIndex = 0;
                    naviSound.play();
                } else if (collectionListView.currentIndex > 0) {
                    collectionListView.currentIndex -= 1;
                    naviSound.play();
                }
            }

            Keys.onRightPressed: {
                if (collectionListView.currentIndex < collectionListView.count - 1) {
                    collectionListView.currentIndex += 1;
                    naviSound.play();
                }
            }

            Keys.onPressed: {
                if (api.keys.isNextPage(event)) {
                    event.accepted = true;
                    collectionListView.incrementCurrentIndex();
                    naviSound.play();
                }
                if (api.keys.isPrevPage(event)) {
                    event.accepted = true;
                    collectionListView.decrementCurrentIndex();
                    naviSound.play();
                }
            }

            Keys.onDownPressed: {
                collectionListView.focus = false;
                gameGridView.focus = true;
                var currentIndex = gameGridView.currentIndex;
                gameGridView.currentIndex = -1;
                gameGridView.currentIndex = currentIndex;
                gameSound.play();
            }
        }

        Item {
            id: settingsItem
            width: parent.width
            height: parent.height
            visible: settingsIconSelected

            Image {
                id: settingbackground
                source: "assets/setting/settingbackground.png"
                width: parent.width * 0.5
                height: parent.height * 0.8
                anchors.centerIn: parent
                opacity: 0.3
            }

            Column {
                id: settingsColumn
                anchors.centerIn: parent
                spacing: 20

                Text {
                    id: textColorChoose
                    text: "CHOOSE A COLOR"
                    font.pixelSize: root.width * 0.03
                    font.bold: true
                    color: currentTheme.settingsText
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: 0.8
                }

                ListView {
                    id: colorListView
                    width: parent.width
                    height: parent.height * 0.8
                    clip: true
                    anchors.horizontalCenter: parent.horizontalCenter

                    model: ListModel {
                        ListElement { colorOption: "BLACK AND WHITE" }
                        ListElement { colorOption: "DARK BREZEE" }
                        ListElement { colorOption: "BREZEE" }
                    }

                    delegate: Rectangle {
                        id: listviewColors
                        width: colorListView.width
                        height: 50
                        radius: 30
                        color: index === colorListView.currentIndex ? currentTheme.primary : currentTheme.secondary
                        opacity: 0.8

                        Text {
                            id: colornames
                            anchors.centerIn: parent
                            text: model.colorOption
                            font.pixelSize: 16
                            color: index === colorListView.currentIndex ? currentTheme.textSelected : currentTheme.text

                        }
                    }

                    Keys.onUpPressed: {
                        if (currentIndex > 0) {
                            currentIndex -= 1;
                            naviSound.play();
                        }
                    }

                    Keys.onDownPressed: {
                        if (currentIndex < count - 1) {
                            currentIndex += 1;
                            naviSound.play();
                        }
                    }

                    Keys.onPressed: {
                        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                            event.accepted = true;
                            const selectedTheme = model.get(currentIndex).colorOption;
                            api.memory.set('selectedTheme', selectedTheme);
                            applyTheme(selectedTheme);
                            naviSound.play();
                        } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                            event.accepted = true;
                            settingsIconSelected = false;
                            settingsIconFocused = false;
                            collectionListView.focus = true;
                            naviSound.play();
                        }
                    }
                }
            }
        }

        GridView {
            id: gameGridView
            model: api.collections.get(0).games
            property int indexToPosition: -1
            anchors {
                top: collectionListView.bottom
                topMargin: 10
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            width: parent.width * 0.8
            cellWidth: conteiner.parent.width / 5
            cellHeight: (height) / 2
            keyNavigationEnabled: true
            keyNavigationWraps: true
            clip: true
            visible: !settingsIconSelected

            delegate: Rectangle {
                id: rectanglegridview
                property bool isSelected: GridView.isCurrentItem

                width: gameGridView.cellWidth
                height: gameGridView.cellHeight
                radius: 20
                border.width: 2
                color: isSelected && gameGridView.focus ? currentTheme.primary : currentTheme.secondary
                border.color: currentTheme.gridviewborder
                Item {
                    width: parent.width
                    height: parent.height

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            id: columnrectangle
                            width: parent.width
                            height: parent.height - 40
                            color: "transparent"
                            clip: true

                            Item{
                                anchors.fill: parent

                                Image {
                                    id: boxfront
                                    visible: status === Image.Ready
                                    source: model.assets.boxFront
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    width: parent.width
                                    height: parent.height
                                    anchors.centerIn: parent
                                    scale: isSelected && gameGridView.focus ? 1.05 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 150} }
                                    mipmap: true
                                }

                                Image {
                                    id: favoriteIcon
                                    visible: model.favorite && boxfront.status === Image.Ready
                                    source: "assets/favorite/favorite.png"
                                    width: 55
                                    height: 72
                                    anchors {
                                        top: boxfront.top
                                        right: boxfront.right
                                        topMargin: (parent.height - boxfront.paintedHeight) / 2
                                        rightMargin: (parent.width - boxfront.paintedWidth) / 2
                                    }
                                    scale: isSelected && gameGridView.focus ? 1.15 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 150 } }
                                    mipmap: true
                                }
                            }

                            Image {
                                id: noImage
                                visible: boxfront.status !== Image.Ready
                                source: isSelected && gameGridView.focus ? "assets/no-image/no-image-white.png" : "assets/no-image/no-image-black.png"
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                width: parent.width * 0.60
                                height: parent.height * 0.60
                                mipmap: true
                            }
                        }

                        Text {
                            id: gametitle
                            width: parent.width
                            height: 40
                            text: model.title
                            color: isSelected && gameGridView.focus ? currentTheme.textSelected : currentTheme.text
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Text {
                id: noGamesText
                anchors.centerIn: parent
                visible: gameGridView.count === 0
                text: "No " + collectionListView.currentShortName + " Available"
                font.pixelSize: 20
                color: "black"
                anchors.verticalCenter: parent.verticalCenter
            }

            focus: true
            SoundEffect {
                id: favSound
                source: "assets/audio/Fav.wav"
                volume: 0.5
            }

            Keys.onPressed: {
                if (!event.isAutoRepeat && (event.key === Qt.Key_Left || event.key === Qt.Key_Right || event.key === Qt.Key_Up || event.key === Qt.Key_Down)) {
                    gameSound.play();
                }

                if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                    event.accepted = true;
                    var selectedGame = gameGridView.model.get(gameGridView.currentIndex);
                    var collectionName = getNameCollecForGame(selectedGame);
                    for (var i = 0; i < api.collections.count; ++i) {
                        var collection = api.collections.get(i);
                        if (collection.name === collectionName) {
                            for (var j = 0; j < collection.games.count; ++j) {
                                var game = collection.games.get(j);
                                if (game.title === selectedGame.title) {
                                    game.launch();
                                    break;
                                }
                            }
                            break;
                        }
                    }
                } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                    event.accepted = true;
                    naviSound.play();
                    collectionListView.focus = true;
                }

                if (api.keys.isNextPage(event)) {
                    naviSound.play();
                    collectionListView.incrementCurrentIndex();
                    collectionListView.focus = true;
                } else if (api.keys.isPrevPage(event)) {
                    naviSound.play();
                    collectionListView.decrementCurrentIndex();
                    collectionListView.focus = true;
                }

                else if (!event.isAutoRepeat && api.keys.isDetails(event)) {
                    event.accepted = true;
                    favSound.play();
                    var selectedGame = gameGridView.model.get(gameGridView.currentIndex);
                    var collectionName = getNameCollecForGame(selectedGame);
                    for (var i = 0; i < api.collections.count; ++i) {
                        var collection = api.collections.get(i);
                        if (collection.name === collectionName) {
                            for (var j = 0; j < collection.games.count; ++j) {
                                var game = collection.games.get(j);
                                if (game.title === selectedGame.title) {
                                    game.favorite = !game.favorite;
                                    updateContinuePlayingModel();
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
            }

            onCurrentItemChanged: {
                if (gameGridView.count > 0 && gameGridView.focus) {
                    bottomBar.selectedGame = gameGridView.model.get(gameGridView.currentIndex);
                    indexToPosition = currentIndex;
                    updateGameInfo();
                } else {
                    bottomBar.selectedGame = null;
                }
            }
        }
    }

    Rectangle{
        id: bottomBar
        color: currentTheme.background
        anchors.top: conteiner.bottom
        height: parent.height * 0.08
        width: parent.width

        property var selectedGame: null
        property real iconSize: Math.min(height * 0.50, width * 0.02)

        Row {
            id: allrowicons
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: backRow.left
            anchors.rightMargin: 20
            spacing: 20
            visible: !settingsIconSelected

            Row {
                spacing: 5
                visible: !collectionListView.activeFocus
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
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                visible: !collectionListView.activeFocus
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
                    }

                    ColorOverlay {
                        anchors.fill: okicon
                        source: okicon
                        color: currentTheme.iconColor
                        cached: true
                    }
                }

                Text {
                    text: " LAUNCH"
                    color: currentTheme.text
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 100
                }
            }

            Row {
                spacing: 5
                visible: collectionListView.activeFocus
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
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                visible: collectionListView.activeFocus
                Rectangle {
                    width: bottomBar.iconSize
                    height: bottomBar.iconSize
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: previcon
                        anchors.fill: parent
                        source: "assets/control/prev.svg"
                        visible: false
                        mipmap: true
                    }

                    ColorOverlay {
                        anchors.fill: previcon
                        source: previcon
                        color: currentTheme.iconColor
                        cached: true
                    }
                }

                Text {
                    text: "PREV COLLECTION"
                    color: currentTheme.text
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                visible: collectionListView.activeFocus
                Rectangle {
                    width: bottomBar.iconSize
                    height: bottomBar.iconSize
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: nexticon
                        anchors.fill: parent
                        source: "assets/control/next.svg"
                        visible: false
                        mipmap: true
                    }

                    ColorOverlay {
                        anchors.fill: nexticon
                        source: nexticon
                        color: currentTheme.iconColor
                        cached: true
                    }
                }

                Text {
                    text: "NEXT COLLECTION"
                    color: currentTheme.text
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Row {
            id: backRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
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
                }
            }

            Text {
                text: " BACK"
                color: currentTheme.text
                font.bold: true
                font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 5
                height: 1
                color: "transparent"
            }
        }

        Row{
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: 2
            visible: !settingsIconSelected

            Rectangle {
                width: 5
                height: 1
                color: "transparent"
            }

            Row {
                spacing: 5
                Timer {
                    id: clockTimer
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        currentTime = Qt.formatDateTime(new Date(), "dd-MM HH:mm")
                    }
                }

                Text {
                    text: currentTime
                    color: currentTheme.text
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                Text {
                    text: "| Games: " + (gameGridView.count > 0 ? (gameGridView.currentIndex + 1) + "/" + gameGridView.count : "0/0 ")
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    color: currentTheme.text
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                Text {
                    id: playTimeText
                    text:"| Play Time: 00:00:00 "
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    color: currentTheme.text
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5

                Text {
                    id: lastPlayedText
                    text: "| Last Played: N/A"
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    color: currentTheme.text
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    function updateGameInfo() {
        var game = gameGridView.model.get(gameGridView.currentIndex);

        if (game) {
            var totalSeconds = game.playTime || 0;
            var hours = Math.floor(totalSeconds / 3600);
            var minutes = Math.floor((totalSeconds % 3600) / 60);
            var seconds = totalSeconds % 60;
            var playTimeFormatted =
            (hours < 10 ? "0" : "") + hours + ":" +
            (minutes < 10 ? "0" : "") + minutes + ":" +
            (seconds < 10 ? "0" : "") + seconds;
            playTimeText.text = "| Play Time: " + playTimeFormatted;

            if (game.lastPlayed.getTime()) {
                var lastPlayedDate = new Date(game.lastPlayed);
                var formattedDate = Qt.formatDateTime(lastPlayedDate, "yyyy-MM-dd HH:mm");
                lastPlayedText.text = "| Last Played: " + formattedDate;
            } else {
                lastPlayedText.text = "| Last Played: N/A";
            }
        } else {
            playTimeText.text = "| Play Time: 00:00:00";
            lastPlayedText.text = "| Last Played: N/A";
        }
    }

    function getNameCollecForGame(game) {
        if (game && game.collections && game.collections.count > 0) {
            var firstCollection = game.collections.get(0);
            for (var i = 0; i < api.collections.count; ++i) {
                var collection = api.collections.get(i);
                if (collection.name === firstCollection.name) {
                    return collection.name;
                }
            }
        }
        return "default";
    }

    function updateContinuePlayingModel() {
        continuePlayingProxyModel.clear();

        var currentDate = new Date();
        var sevenDaysAgo = new Date(currentDate.getTime() - 7 * 24 * 60 * 60 * 1000);

        for (var i = 0; i < historyProxyModel.count; ++i) {
            var game = historyProxyModel.get(i);
            var lastPlayedDate = new Date(game.lastPlayed);
            var playTimeInMinutes = game.playTime / 60;

            if (lastPlayedDate >= sevenDaysAgo && playTimeInMinutes > 1) {
                continuePlayingProxyModel.append(game);
            }
        }
    }
}
