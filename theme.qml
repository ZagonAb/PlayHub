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
    property bool gameInfoFocused: false
    property bool gameInfoVisible: false
    property bool isMinimizing: false
    property var game: null
    property real iconSize: Math.min(height * 0.50, width * 0.02)
    property string currentTime: Qt.formatDateTime(new Date(), "dd-MM HH:mm")
    property var currentTheme: themes.blackAndWhite
    property string maskImageSource: "assets/overlay/overlay.png"

    readonly property var themes: {
        "blackAndWhite": {
            background: "white",
            primary: "black",
            secondary: "white",
            text: "black",
            textSelected: "white",
            border: "black",
            gridviewborder: "black",
            settingsText: "black",
            iconColor: "black",
            favoriteiconColor: "#d00003"
        },
        "darkBreeze": {
            background: "#292d32",
            primary: "#3aa7e0",
            secondary: "#292d32",
            text: "#3aa7e0",
            textSelected: "white",
            border: "#3aa7e0",
            gridviewborder: "#3aa7e0",
            settingsText: "#3aa7e0",
            iconColor: "#3aa7e0",
            favoriteiconColor: "#3aa7e0"
        },
        "breeze": {
            background: "#eff0f1",
            primary: "#3aa7e0",
            secondary: "#eff0f1",
            text: "#3aa7e0",
            textgridview: "#3aa7e0",
            textSelected: "white",
            border: "#3aa7e0",
            gridviewborder: "#3aa7e0",
            settingsText: "#3aa7e0",
            iconColor: "#3aa7e0",
            favoriteiconColor: "#3aa7e0"
        }
    }

    function applyTheme(themeName) {
        switch(themeName) {
            case "BLACK AND WHITE":
                currentTheme = themes.blackAndWhite;
                maskImageSource = "assets/overlay/overlay.png";
                break;
            case "DARK BREZEE":
                currentTheme = themes.darkBreeze;
                maskImageSource = "assets/overlay/overlay0.png";
                break;
            case "BREZEE":
                currentTheme = themes.breeze;
                maskImageSource = "assets/overlay/overlay1.png";
                break;
        }
    }

    Timer {
        id: launchTimer
        interval: 700
        repeat: false
        onTriggered: {
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
            root.isMinimizing = false;
        }
    }

    SoundEffect {
        id: naviSound
        source: "assets/audio/choose.wav"
        volume: 0.8
    }

    SoundEffect {
        id: backSound
        source: "assets/audio/back.wav"
        volume: 0.5
    }

    SoundEffect {
        id: goSound
        source: "assets/audio/go.wav"
        volume: 0.5
    }

    SoundEffect {
        id: launchSound
        source: "assets/audio/launch.wav"
        volume: 1.0
    }

    Component.onCompleted: {
        const savedTheme = api.memory.get('selectedTheme');
        if (savedTheme) {
            applyTheme(savedTheme);
        }

        naviSound.play();
    }

    Item {
        id: collectionsItem
        property alias favoritesModel: favoritesProxyModel

        ListModel {
            id: collectionsModel
            property int favoritesIndex: -1
            property int historyIndex : - 1
            Component.onCompleted: {
                var favoritecollection = { name: "Favorite", shortName: "favorite", games: favoritesProxyModel };
                collectionsModel.append(favoritecollection);
                collectionsModel.favoritesIndex = collectionsModel.count - 1;
                var historycollection = { name: "History", shortName: "history", games: history };
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
            id: historyPlaying
            sourceModel: api.allGames
            filters: ExpressionFilter {
                expression: lastPlayed != null && lastPlayed.toString() !== "Invalid Date"
            }
            sorters: RoleSorter {
                roleName: "lastPlayed"
                sortOrder: Qt.DescendingOrder
            }
        }

        SortFilterProxyModel {
            id: history
            sourceModel: historyPlaying
            filters: IndexFilter {
                minimumIndex: 0
                maximumIndex: 50
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
            width: parent.width * 0.90
            height: 60
            model: collectionsModel
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

            delegate: Rectangle {
                id: collectionlistview
                width: root.width * 0.080
                height: root.height * 0.04
                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
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
                    font.pixelSize: index === collectionListView.currentIndex && collectionListView.focus ? parent.width * 0.14 : parent.width * 0.12
                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.InOutQuad
                        }
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
                    goSound.play();
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
                goSound.play();
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
                            backSound.play();
                        }
                    }
                }
            }
        }

        GridView {
            id: gameGridView
            model: api.collections.get(0).games
            property int indexToPosition: -1
            property real selectedItemX: 0
            property real selectedItemY: 0
            property real viewportX: contentX + width / 2
            property real viewportY: contentY + height / 2
            cellHeight: (height) / 2
            keyNavigationEnabled: true
            keyNavigationWraps: true
            width: parent.width
            cellWidth: parent.width / 5 -5
            anchors.horizontalCenterOffset: (parent.width - (Math.floor(parent.width / cellWidth) * cellWidth)) / 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors {
                top: collectionListView.bottom
                topMargin: 10
                bottom: parent.bottom
            }
            clip: true
            visible: !settingsIconSelected

            transform: [
                Scale {
                    id: viewScale
                    origin.x: gameGridView.selectedItemX
                    origin.y: gameGridView.selectedItemY
                    xScale: root.isMinimizing ? 8.0 : 1.0
                    yScale: root.isMinimizing ? 8.0 : 1.0

                    Behavior on xScale {
                        NumberAnimation {
                            duration: launchTimer.interval
                            easing.type: Easing.InQuad
                        }
                    }
                    Behavior on yScale {
                        NumberAnimation {
                            duration: launchTimer.interval
                            easing.type: Easing.InQuad
                        }
                    }
                }
            ]

            opacity: root.isMinimizing ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: launchTimer.interval
                    easing.type: Easing.InQuad
                }
            }

            delegate: Rectangle {
                id: rectanglegridview

                property bool isSelected: GridView.isCurrentItem

                width: gameGridView.cellWidth
                height: gameGridView.cellHeight
                radius: 20
                border.width: 2
                color: isSelected && gameGridView.focus ? currentTheme.primary : currentTheme.secondary
                border.color: currentTheme.gridviewborder

                function updateOriginPoint() {
                    if (isSelected && boxfront.status === Image.Ready) {
                        var boxfrontItem = boxfront;
                        var boxfrontCenter = boxfrontItem.mapToItem(null,
                                                                    boxfrontItem.width * boxfrontItem.scale / 2,
                                                                    boxfrontItem.height * boxfrontItem.scale / 2);
                    }
                }

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

                            Item {
                                anchors.fill: parent

                                Image {
                                    id: boxfront
                                    visible: status === Image.Ready
                                    source: model.assets.boxFront
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    width: parent.width * 0.93
                                    height: parent.height * 0.93
                                    anchors.centerIn: parent
                                    scale: isSelected && gameGridView.focus ? 1.05 : 1.0

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 150
                                            onRunningChanged: {
                                                if (!running && isSelected) {
                                                    rectanglegridview.updateOriginPoint();
                                                }
                                            }
                                        }
                                    }

                                    onStatusChanged: {
                                        if (status === Image.Ready && isSelected) {
                                            rectanglegridview.updateOriginPoint();
                                        }
                                    }
                                    mipmap: true
                                    layer.enabled: isSelected
                                    layer.effect: Glow {
                                        samples: 100
                                        color: currentTheme.background
                                        spread: 0.5
                                        radius: 15
                                    }
                                }

                                Item {
                                    id: favoriteIconContainer
                                    width: parent.width * 0.17
                                    height: parent.height * 0.17
                                    anchors {
                                        top: boxfront.top
                                        right: boxfront.right
                                        topMargin: (parent.height - boxfront.paintedHeight) / 2.5
                                        rightMargin: (parent.width - boxfront.paintedWidth) / 2.3
                                    }
                                    Rectangle {
                                        id: favoriteIconBackground
                                        anchors.fill: parent
                                        color: "transparent"
                                        DropShadow {
                                            anchors.fill: favoriteIcon
                                            source: favoriteIcon
                                            horizontalOffset: 0
                                            verticalOffset: 0
                                            radius: 10
                                            color: "black"
                                            visible: isSelected && gameGridView.focus
                                        }
                                        Image {
                                            id: favoriteIcon
                                            anchors.fill: parent
                                            source: "assets/favorite/favorite.svg"
                                            mipmap: true
                                        }
                                        ColorOverlay {
                                            anchors.fill: favoriteIcon
                                            source: favoriteIcon
                                            color: currentTheme.favoriteiconColor
                                            cached: true
                                        }
                                    }
                                    visible: model.favorite && boxfront.status === Image.Ready
                                    scale: isSelected && gameGridView.focus ? 1.15 : 0.8
                                    Behavior on scale { NumberAnimation { duration: 150 } }
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
                        }

                        Text {
                            id: gametitle
                            width: parent.width
                            height: 40
                            text: model.title
                            color: isSelected && gameGridView.focus ? currentTheme.textSelected : currentTheme.text
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.05)
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }

                Component.onCompleted: {
                    if (isSelected) {
                        updateSelectedItemPosition();
                    }
                }

                function updateSelectedItemPosition() {
                    if (isSelected) {
                        var itemRect = rectanglegridview.mapToItem(gameGridView, 0, 0, width, height);
                        gameGridView.selectedItemX = itemRect.x + (itemRect.width / 2);
                        gameGridView.selectedItemY = itemRect.y + (itemRect.height / 2);
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
                if (!event.isAutoRepeat && api.keys.isFilters(event)) {
                    event.accepted = true;
                    gameGridView.focus = false;
                    gameInfoLoader.active = true;
                    gameInfoFocused = true;

                    if (gameInfoLoader.status === Loader.Ready) {
                        gameInfoLoader.item.buttonsGames.forceActiveFocus();
                    }
                    naviSound.play();
                }

                if (!event.isAutoRepeat && (event.key === Qt.Key_Left || event.key === Qt.Key_Right || event.key === Qt.Key_Up || event.key === Qt.Key_Down)) {
                    naviSound.play();
                    if (currentItem) {
                        currentItem.updateSelectedItemPosition();
                    }
                }

                if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                    event.accepted = true;
                    if (currentItem) {
                        currentItem.updateSelectedItemPosition();
                    }
                    root.isMinimizing = true;
                    launchTimer.start();
                    launchSound.play();
                } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                    event.accepted = true;
                    backSound.play();
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
                } else if (!event.isAutoRepeat && api.keys.isDetails(event)) {
                    favSound.play();
                    event.accepted = true;
                    var selectedGame = gameGridView.model.get(gameGridView.currentIndex);
                    var collectionName = getNameCollecForGame(selectedGame);
                    for (var i = 0; i < api.collections.count; ++i) {
                        var collection = api.collections.get(i);
                        if (collection.name === collectionName) {
                            for (var j = 0; j < collection.games.count; ++j) {
                                var game = collection.games.get(j);
                                if (game.title === selectedGame.title) {
                                    game.favorite = !game.favorite;
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
                    game = gameGridView.model.get(gameGridView.currentIndex);
                    indexToPosition = currentIndex;
                    if (currentItem) {
                        currentItem.updateSelectedItemPosition();
                    }
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

        Item {
            height: parent.height
            width: parent.width * 0.95
            anchors.horizontalCenter: parent.horizontalCenter

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
                            id: detailsicon
                            anchors.fill: parent
                            source: "assets/control/details.svg"
                            visible: false
                            mipmap: true
                        }

                        ColorOverlay {
                            anchors.fill: detailsicon
                            source: detailsicon
                            color: currentTheme.iconColor
                            cached: true
                        }
                    }

                    Text {
                        text: " DETAILS"
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
            }
        }
    }

    Loader {
        id: gameInfoLoader
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        y: active ? 0 : parent.height
        active: false
        asynchronous: true
        focus: gameInfoFocused

        Behavior on y {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        sourceComponent: Item {
            id: gameInfo
            anchors.fill: parent

            Item {
                id: imageContainer
                anchors.right: parent.right
                width: parent.width * 0.65
                height: parent.height * 0.75
                anchors.top: parent.top

                Image {
                    id: backgroundImage
                    width: imageContainer.width
                    height: imageContainer.height
                    source: game && game.assets && game.assets.screenshot ? game.assets.screenshot : "assets/no-image/defaultimage.jpg"
                    fillMode: Image.Stretch
                    mipmap: true
                    visible: true
                }
            }

            Image {
                id: defaultImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: "assets/no-image/defaultimage.jpg"
                mipmap: true
                visible: backgroundImage.status === Image.Error
            }

            Image {
                id: maskImage
                source: root.maskImageSource
                anchors.fill: parent
                fillMode: Image.Stretch
                smooth: true
                visible: true
            }

            RowLayout {
                anchors {
                    fill: parent
                    margins: 40
                }
                spacing: 40

                Image {
                    id: boxArt
                    source:  game && game.assets && game.assets.boxFront ? game.assets.boxFront : "assets/no-image/defaultimage.jpg"
                    Layout.preferredWidth: root.width * 0.3
                    Layout.preferredHeight: root.height * 0.4
                    fillMode: Image.PreserveAspectFit

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 8.0
                        samples: 16
                        color: currentTheme.background
                    }
                }

                Image {
                    id: boxArtdefault
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 400
                    source: "assets/no-image/defaultimage.jpg"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    visible: boxArt.status === Image.Error
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 8.0
                        samples: 16
                        color: currentTheme.background
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: game && game.title ? game.title : ""
                        font.pixelSize: root.width * 0.03
                        font.bold: true
                        color: "white"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        spacing: 2

                        Text {
                            id: ratingText
                            text: game && game.rating ? "Rating: " + (game.rating * 100).toFixed(0) + "%" : "Rating: N/A"
                            color: "#cccccc"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.05)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }

                        Text {
                            id: lastPlayed2
                            text: calculateLastPlayedText()
                            color: "#cccccc"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.05)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                    }

                    RowLayout {
                        id: buttonsGames
                        spacing: 10

                        property int currentIndex: 0

                        Rectangle {
                            id: playButton
                            color: currentTheme.iconColor
                            width: gameInfoLoader.width * 0.1 //120
                            //height: parent.currentIndex === 0 ? 45 : 40
                            height: parent.currentIndex === 0 ? gameInfoLoader.height * 0.06 : gameInfoLoader.height * 0.05

                            border.color: currentTheme.background
                            radius: gameInfoLoader.width * 0.005 //10

                            Behavior on height {
                                NumberAnimation { duration: 50 }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "Launch"
                                color: "white"
                                font.pixelSize: Math.min(gameInfoLoader.height * 0.02, gameInfoLoader.width * 0.06)
                            }
                        }

                        Rectangle {
                            id: favoriteButton
                            color: currentTheme.iconColor
                            width: gameInfoLoader.width * 0.1
                            height: parent.currentIndex === 1 ? gameInfoLoader.height * 0.06 : gameInfoLoader.height * 0.05
                            border.color: currentTheme.background
                            radius: gameInfoLoader.width * 0.005

                            Behavior on height {
                                NumberAnimation { duration: 50 }
                            }

                            property bool isFavorite: false

                            Component.onCompleted: {
                                updateFavoriteState();
                            }

                            function updateFavoriteState() {
                                if (!game) return;
                                var collectionName = getNameCollecForGame(game);
                                for (var i = 0; i < api.collections.count; ++i) {
                                    var collection = api.collections.get(i);
                                    if (collection.name === collectionName) {
                                        for (var j = 0; j < collection.games.count; ++j) {
                                            var currentGame = collection.games.get(j);
                                            if (currentGame.title === game.title) {
                                                isFavorite = currentGame.favorite;
                                                break;
                                            }
                                        }
                                        break;
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: favoriteButton.isFavorite ? "Favorite -" : "Favorite +"
                                color: "white"
                                font.pixelSize: Math.min(gameInfoLoader.height * 0.02, gameInfoLoader.width * 0.06)
                            }
                        }

                        focus: gameInfoFocused

                        Keys.onLeftPressed: {
                            if (currentIndex > 0) {
                                currentIndex--;
                                naviSound.play();
                            }
                        }

                        Keys.onRightPressed: {
                            if (currentIndex < 1) {
                                currentIndex++;
                                naviSound.play();
                            }
                        }

                        Keys.onPressed: function(event) {
                            if (!event.isAutoRepeat) {
                                if (api.keys.isCancel(event)) {
                                    gameInfoFocused = false;
                                    gameGridView.focus = true;
                                    naviSound.play();
                                    event.accepted = true;

                                    if (gameGridView.currentIndex >= 0 && gameGridView.currentIndex < gameGridView.count) {
                                        game = gameGridView.model.get(gameGridView.currentIndex);
                                    } else {
                                        game = null;
                                    }

                                    gameInfoLoader.active = false;

                                    if (favoriteButton) {
                                        favoriteButton.updateFavoriteState();
                                    }
                                }

                                if (api.keys.isAccept(event)) {
                                    event.accepted = true;
                                    if (currentIndex === 0) {
                                        root.isMinimizing = true;
                                        launchTimer.start();
                                        launchSound.play();
                                    }else {
                                        favSound.play();
                                        var selectedGame = game;
                                        var collectionName = getNameCollecForGame(selectedGame);
                                        for (var i = 0; i < api.collections.count; ++i) {
                                            var collection = api.collections.get(i);
                                            if (collection.name === collectionName) {
                                                for (var j = 0; j < collection.games.count; ++j) {
                                                    var currentGame = collection.games.get(j);
                                                    if (currentGame.title === selectedGame.title) {
                                                        currentGame.favorite = !currentGame.favorite;
                                                        favoriteButton.isFavorite = currentGame.favorite;
                                                        break;
                                                    }
                                                }
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    GridLayout {
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 24
                        Layout.topMargin: 32

                        Text {
                            text: "Developer:"
                            color: "#cccccc"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: game && game.developer ? game.developer : "Unknown"
                            color: "white"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }

                        Text {
                            text: "Publisher:"
                            color: "#cccccc"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: game && game.publisher ? game.publisher : "Unknown"
                            color: "white"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }

                        Text {
                            text: "Genre:"
                            color: "#cccccc"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: {
                                let genreText = game && game.genre ? game.genre : "Unknown";
                                let separators = [",", "/", "-"];
                                for (let separator of separators) {
                                    if (genreText.includes(separator)) {
                                        return genreText.split(separator)[0];
                                    }
                                }
                                return genreText;
                            }
                            color: "white"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }

                        Text {
                            text: "Release Date:"
                            color: "#cccccc"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: game && game.releaseYear > 0 ? game.releaseYear.toString() : "Unknown"
                            color: "white"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }

                        Text {
                            id: playTimeText2
                            text: "Play Time:"
                            color: "#cccccc"
                            visible: game && game.playTime > 0
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: calculatePlayTimeText(false)
                            color: "white"
                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.06)
                            visible: game && game.playTime > 0
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "black"
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                    }
                }
            }
        }
    }

    function calculateLastPlayedText() {
        if (!game || !game.lastPlayed) {
            return "| Last Played: Never"
        }
        let date = new Date(game.lastPlayed)
        if (isNaN(date.getTime())) {
            return "| Last Played: Never"
        }
        let now = new Date()
        let today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        let yesterday = new Date(today.getTime() - (1000 * 60 * 60 * 24))
        if (date >= today) {
            return "| Last Played: Today"
        } else if (date >= yesterday) {
            return "| Last Played: Yesterday"
        } else {
            return "| Last Played: " + date.toLocaleDateString("en-GB")
        }
    }

    function calculatePlayTimeText(includePrefix) {
        let seconds = game && game.playTime || 0;
        let hours = Math.floor(seconds / 3600);
        let minutes = Math.floor((seconds % 3600) / 60);
        let remainingSeconds = seconds % 60;

        let hoursStr = hours.toString().padStart(2, '0');
        let minutesStr = minutes.toString().padStart(2, '0');
        let secondsStr = remainingSeconds.toString().padStart(2, '0');

        let playTime = hoursStr + ":" + minutesStr + ":" + secondsStr;
        return includePrefix ? "| Play Time: " + playTime : playTime;
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
}
