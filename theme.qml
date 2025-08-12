import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.8
import QtQuick.Window 2.15
import QtQuick.Particles 2.15
import "utils.js" as Utils

FocusScope {
    id: root
    focus: true
    property bool settingsIconSelected: false
    property bool settingsIconFocused: false
    property bool initialZoomComplete: false
    property bool gameInfoFocused: false
    property bool gameInfoVisible: false
    property bool isMinimizing: false
    property bool isVisible: false
    property real iconSize: Math.min(height * 0.50, width * 0.02)
    property string currentTime: Qt.formatDateTime(new Date(), "dd-MM HH:mm")
    property var currentTheme: themes.light
    property string currentThemeName: api.memory.get('selectedTheme') || "LIGHT THEME"
    property bool isGameInfoOpen: false
    property alias launchTimer: launchTimer
    property bool focusEnabled: false
    property bool positionRestored: false
    property real systemColorOpacity: 0.3
    property real themeColorOpacity: 1
    property bool gradientSystemOnTop: x

    property color rawSystemColor: {
        if (collectionListView.currentShortName) {
            return colorMapping.colorMap[collectionListView.currentShortName.toLowerCase()] || currentTheme.background
        }
        return currentTheme.background
    }

    property color rawThemeColor: currentTheme.background

    function colorWithOpacity(baseColor, opacity) {
        var adjustedOpacity = Math.max(0.1, Math.min(1.0, opacity));
        return Qt.rgba(
            baseColor.r * adjustedOpacity + (1 - adjustedOpacity) * 0.1,
                       baseColor.g * adjustedOpacity + (1 - adjustedOpacity) * 0.1,
                       baseColor.b * adjustedOpacity + (1 - adjustedOpacity) * 0.1,
                       1.0
        );
    }

    Connections {
        target: collectionListView
        function onCurrentShortNameChanged() {
        }
    }

    property bool searchVisible: false

    onSearchVisibleChanged: {
        if (searchVisible) {
            searchOverlayLoader.active = true
        } else {
            if (searchOverlayLoader.item) {
                var lastFocused = searchOverlayLoader.item.lastFocusedItem
                focusManager.setFocus(lastFocused || "collections", "search")
            }
            searchOverlayLoader.active = false
        }
    }

    ColorMapping {
        id: colorMapping
    }

    Connections {
        target: gameInfo
        function onVisibleChanged() {
            if (!gameInfo.visible && gameGridView.currentIndex >= 0) {
                game = gameGridView.model.get(gameGridView.currentIndex);
            }
        }
    }

    property var game: {
        var selectedGame = null;
        if (gameGridView.model && gameGridView.currentIndex >= 0) {
            selectedGame = gameGridView.model.get(gameGridView.currentIndex);
        }
        return selectedGame;
    }

    property var focusManager: FocusManager {
        id: focusManager
        rootItem: root
        gameGridView: gameGridView
        collectionListView: collectionListView
        gameInfo: gameInfo
        mediaPlayer: gameInfo.videoPlayer
        gameDetails: gameInfo.gameDetailsPanel
        settingsImage: settingsImage
    }

    SoundEffects {
        id: soundEffects
    }

    SoundEffect {
        id: soundEffect
        source: "assets/audio/sound.wav"
        loops: 1
        volume: 0.2
    }

    FontLoader {
        id: fontLoader
        source: "assets/font/font.ttf"
    }

    Rectangle {
        id: mainContainer
        width: parent.width
        height: parent.height
        color: "transparent"
        z: 100

        property real contentOpacity: 1.

        Item {
            id: backgroundContainer
            anchors.fill: parent

            opacity: mainContainer.contentOpacity

            Image {
                id: backgroundImageGlass
                anchors.fill: parent
                source: "assets/overlay/glass.png"
                fillMode: Image.PreserveAspectCrop
                visible: true
                mipmap: true
                asynchronous: true
            }
        }

        Item {
            id: textContainer
            anchors.centerIn: parent
            width: root.width * 0.70
            height: parent.height
            opacity: mainContainer.contentOpacity
            property real baseX: width / 2 - 85
            property var letterSpacings: ({
                'P': - root.width * 0.23,
                'l': - root.width * 0.15,
                'a': - root.width * 0.10,
                'y': - root.width * 0.02,
                'H':  root.width * 0.06,
                'u':  root.width * 0.15,
                'b':  root.width * 0.24,
            })

            Repeater {
                model: ListModel {
                    ListElement { letter: "P"; index: 0 }
                    ListElement { letter: "l"; index: 1 }
                    ListElement { letter: "a"; index: 2 }
                    ListElement { letter: "y"; index: 3 }
                    ListElement { letter: "H"; index: 4 }
                    ListElement { letter: "u"; index: 5 }
                    ListElement { letter: "b"; index: 6 }
                }

                delegate: Text {
                    id: letter
                    text: model.letter
                    font.pixelSize: root.width * 0.15
                    color: "white"
                    font.family: fontLoader.name
                    font.bold: true
                    x: textContainer.width / 2 - width / 2
                    y: -100
                    opacity: 0
                    style: Text.Outline
                    styleColor: "#80000000"

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 4
                        verticalOffset: 4
                        radius: 30
                        samples: 50
                        color: "#A0000000"
                        spread: 0.5
                    }

                    property real finalX: textContainer.baseX + textContainer.letterSpacings[text]
                    property real finalY: textContainer.height / 2 - height / 2

                    SequentialAnimation {
                        running: true
                        loops: 1

                        PauseAnimation {
                            duration: index * 150
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                target: letter
                                property: "opacity"
                                from: 0.5
                                to: 1
                                duration: 800
                                easing.type: Easing.InOutQuad
                            }

                            NumberAnimation {
                                target: letter
                                property: "y"
                                to: finalY
                                duration: 800
                                easing.type: Easing.OutBounce
                            }
                        }

                        PauseAnimation {
                            duration: 300
                        }

                        NumberAnimation {
                            target: letter
                            property: "x"
                            to: finalX
                            duration: 300
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            property var subtitleTexts: [
                "Theme For Pegasus-Frontend.",
                "Happy Gaming!",
                "Enjoy your favorite games.",
                "Remember your last released game.",
                "Let the games begin!",
                "Your gaming journey starts here.",
                "Get ready to play.",
                "Gaming memories await.",
                "Welcome to gamer paradise.",
                "Your game collection, always at your fingertips.",
                "Browse, select, and play without limits.",
                "Where your games come to life.",
                "Relive your best gaming moments.",
                "It's always a good time to game.",
                "The adventure begins with a click.",
                "Your favorite classics await.",
                "The next level is just a button away.",
                "Let the fun never end.",
                "Your games, your rules.",
                "All set for a marathon of fun.",
                "Keep playing, keep dreaming.",
                "Your portal to extraordinary worlds.",
                "Nostalgia is just a step away.",
                "Turn every game into an epic adventure.",
                "Pick up where you left off with your last game.",
                "The magic of gaming starts here.",
                "Your gamer world, personalized for you."
            ]

            function getRandomText() {
                var index = Math.floor(Math.random() * subtitleTexts.length)
                return subtitleTexts[index]
            }

            Text {
                id: subtitleText
                text: textContainer.getRandomText()
                x: textContainer.width / 2 - width / 2
                y: parent.height * 0.65
                font.pixelSize: root.width * 0.02
                color: "white"
                opacity: 0
                style: Text.Outline
                styleColor: "black"

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 30
                    samples: 40
                    color: "black"
                    spread: 0.5
                }

                SequentialAnimation {
                    running: true
                    PauseAnimation {
                        duration: 2450
                    }

                    NumberAnimation {
                        target: subtitleText
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Timer {
            id: soundTimer
            interval: 1500
            running: true
            repeat: false
            onTriggered: soundEffect.play()
        }

        Timer {
            id: fadeOutTimer
            interval: 4000
            running: true
            repeat: false
            onTriggered: {
                fadeOutAnimation.start()
            }
        }

        NumberAnimation {
            id: fadeOutAnimation
            target: mainContainer
            property: "contentOpacity"
            from: 1.0
            to: 0.0
            duration: 2000
            easing.type: Easing.InOutQuad
            onStopped: {
                mainContainer.destroy()
                if (positionRestored) {
                    Qt.callLater(function() {
                        focusManager.setFocus("games", "restore");
                    });
                }
            }
        }
    }

    transform: Scale {
        id: initialZoom
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.initialZoomComplete ? 1.0 : 4.0
        yScale: root.initialZoomComplete ? 1.0 : 4.0

        Behavior on xScale {
            NumberAnimation {
                duration: 3000
                easing.type: Easing.OutCubic
            }
        }
        Behavior on yScale {
            NumberAnimation {
                duration: 3000
                easing.type: Easing.OutCubic
            }
        }
    }

    opacity: root.initialZoomComplete ? 1.0 : 0.05

    Behavior on opacity {
        NumberAnimation {
            duration: 3000
            easing.type: Easing.InOutQuad
        }
    }

    Timer {
        id: initialZoomTimer
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            root.initialZoomComplete = true
        }
    }

    Timer {
        id: focusTimer
        interval: 6100
        repeat: false
        running: true
        onTriggered: {
            if (!positionRestored) {
                focusEnabled = true;
                collectionListView.focus = true;
            }
        }
    }

    function clearMemoryIfNotRestoring() {
        if (!focusManager.restoringPosition) {
            api.memory.unset('lastCollectionIndex');
            api.memory.unset('lastGameTitle');
        }
    }

    readonly property var themes: {
        "light": {
            background: "#f5f5f5",
            primary: "#f0f0f0",
            secondary: "#c1c1c1",
            text: "#a8a8a6",
            textgamedetails: "#333333",
            textSelected: "#000000",
            buttomText: "#333333",
            textbutton: "#f9f9f9",
            bordercolor: "#c0c0c0",
            gridviewborder: "#424242",
            settingsText: "#333333",
            iconColor: "#f0f0f0",
            settingsiconcolor: "#a8a8a6",
            favoriteiconColor: "#d00003",
            gradientColor: "#e8e8e8"
        },
        "dark": {
            background: "#0e1011",
            primary: "#1d1d1d",
            secondary: "#363636",
            text: "#a8a8a6",
            textgamedetails: "#a8a8a6",
            textSelected: "white",
            buttomText: "white",
            textbutton: "#f9f9f9",
            bordercolor: "#a8a8a6",
            gridviewborder: "#b1b1b1",
            settingsText: "#a8a8a6",
            iconColor: "#f0f0f0",
            settingsiconcolor: "#a8a8a6",
            favoriteiconColor: "#d00003",
            gradientColor: "#141618"
        }
    }

    function applyTheme(themeName) {
        currentTheme = themes[themeName];
        currentThemeName = themeName === "dark" ? "DARK THEME" : "LIGHT THEME";
        api.memory.set('selectedTheme', currentThemeName);
        currentThemeChanged();

        if (gameInfo.visible) {
            var oldGame = gameInfo.currentGame;
            gameInfo.visible = false;
            Qt.callLater(function() {
                gameInfo.currentGame = oldGame;
                gameInfo.visible = true;
            });
        }
    }

    function toggleTheme() {
        if (currentTheme === themes.light) {
            applyTheme("dark");
        } else {
            applyTheme("light");
        }
        soundEffects.play("navi");
    }

    Timer {
        id: launchTimer
        interval: 700
        repeat: false
        onTriggered: {
            if (root.game) {
                api.memory.set('lastCollectionIndex', collectionListView.currentIndex);
                api.memory.set('lastGameTitle', root.game.title);
                var collectionName = Utils.getNameCollecForGame(root.game, api);
                for (var i = 0; i < api.collections.count; ++i) {
                    var collection = api.collections.get(i);
                    if (collection.name === collectionName) {
                        for (var j = 0; j < collection.games.count; ++j) {
                            var game = collection.games.get(j);
                            if (game.title === root.game.title) {
                                game.launch();
                                break;
                            }
                        }
                        break;
                    }
                }
            }
            root.isMinimizing = false;
        }
    }

    Component.onCompleted: {
        const savedTheme = api.memory.get('selectedTheme');
        if (savedTheme === "DARK THEME") {
            applyTheme("dark");
        } else {
            applyTheme("light");
        }

        focusEnabled = false;
        var lastCollectionIndex = api.memory.get('lastCollectionIndex');
        var lastGameTitle = api.memory.get('lastGameTitle');

        if (lastCollectionIndex !== undefined && lastGameTitle !== undefined) {
            positionRestored = true;
            restorePosition();
        } else {
            positionRestored = false;
            clearMemoryIfNotRestoring();

            var checkModel = function() {
                if (collectionListView.model && collectionListView.model.count > 0) {
                    collectionListView.currentIndex = 0;
                    focusManager.setFocus("collections", "restore");
                    Qt.callLater(function() {
                        if (collectionsModel.favoritesIndex >= 0) {
                            collectionsModel.favoritesModel.invalidate();
                        }
                        Qt.callLater(function() {
                            if (gameGridView.model && gameGridView.model.count > 0) {
                                gameGridView.currentIndex = 0;
                                root.game = gameGridView.model.get(0);
                            }
                        });
                    });
                } else {
                    Qt.callLater(checkModel);
                }
            };
            Qt.callLater(checkModel);
        }

        soundEffects.play("navi");
        settingsIconFocused = false;
    }

    Timer {
        id: clearMemoryTimer
        interval: 500
        repeat: false
        onTriggered: {
            clearMemoryIfNotRestoring();
        }
    }

    function restorePosition() {
        var lastCollectionIndex = api.memory.get('lastCollectionIndex');
        var lastGameTitle = api.memory.get('lastGameTitle');

        if (lastCollectionIndex !== undefined && lastGameTitle !== undefined) {
            if (collectionListView.model && collectionListView.model.count > 0) {
                setPositionByTitle(lastCollectionIndex, lastGameTitle);
            } else {
                var checkModel = function() {
                    if (collectionListView.model && collectionListView.model.count > 0) {
                        setPositionByTitle(lastCollectionIndex, lastGameTitle);
                    } else {
                        Qt.callLater(checkModel);
                    }
                };
                Qt.callLater(checkModel);
            }
        }
    }

    function setPositionByTitle(collectionIndex, gameTitle) {
        if (collectionIndex >= 0 && collectionIndex < collectionListView.model.count) {
            collectionListView.currentIndex = collectionIndex;
            collectionListView.positionViewAtIndex(collectionIndex, ListView.Center);

            var checkGamesModel = function() {
                if (gameGridView.model && gameGridView.model.count > 0) {
                    var foundIndex = -1;
                    for (var i = 0; i < gameGridView.model.count; i++) {
                        var game = gameGridView.model.get(i);
                        if (game.title === gameTitle) {
                            foundIndex = i;
                            break;
                        }
                    }

                    var targetIndex = foundIndex >= 0 ? foundIndex : 0;

                    gameGridView.currentIndex = targetIndex;
                    gameGridView.positionViewAtIndex(targetIndex, GridView.Center);

                    Qt.callLater(function() {
                        focusEnabled = true;
                        focusManager.setFocus("games", "restore");
                        clearMemoryTimer.start();
                    });
                } else {
                    Qt.callLater(checkGamesModel);
                }
            };
            Qt.callLater(checkGamesModel);
        }
    }

    CollectionsModel {
        id: collectionsModel
    }

    Rectangle {
        id: backgroundGradient
        anchors.fill: parent
        z: -1

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop {
                id: systemStop
                position: root.gradientSystemOnTop ? 0.0 : 1.0
                color: root.colorWithOpacity(root.rawSystemColor, root.systemColorOpacity)

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }

            GradientStop {
                position: root.gradientSystemOnTop ? 0.3 : 0.7
                color: Qt.rgba(
                    (root.rawSystemColor.r * root.systemColorOpacity + root.rawThemeColor.r * root.themeColorOpacity) / 2,
                               (root.rawSystemColor.g * root.systemColorOpacity + root.rawThemeColor.g * root.themeColorOpacity) / 2,
                               (root.rawSystemColor.b * root.systemColorOpacity + root.rawThemeColor.b * root.themeColorOpacity) / 2,
                               (root.systemColorOpacity + root.themeColorOpacity) / 2
                )

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }

            GradientStop {
                id: themeStop
                position: root.gradientSystemOnTop ? 1.0 : 0.3
                color: root.colorWithOpacity(root.rawThemeColor, root.themeColorOpacity)

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    Rectangle {
        id: conteiner
        property alias conteiner: conteiner
        width: parent.width
        height: parent.height * 0.92
        color: "transparent"
        visible: true
        x: root.isGameInfoOpen ? -parent.width : 0

        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        Item {
            id: settingsImage
            width: parent.width * 0.05
            height: collectionListView.height
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: root.width * 0.005
            Keys.enabled: root.focusEnabled
            focus: settingsIconFocused

            property bool animatingTheme: false

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: 100
                onClicked: {
                    if (!settingsImage.animatingTheme) {
                        settingsImage.animateThemeChange()
                    }
                }
            }

            Rectangle {
                id: iconWrapper
                anchors.centerIn: parent
                property real circleSize: Math.min(parent.width, parent.height) * 0.5
                width: circleSize
                height: circleSize

                color: settingsIconFocused ? Qt.rgba(0, 0, 0, 0.2) : "transparent"
                radius: width / 2
                scale: settingsIconFocused ? 1.3 : 1.0

                Behavior on scale {
                    NumberAnimation { duration: 150 }
                }
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Image {
                    id: settingsIcon
                    anchors.fill: parent
                    anchors.margins: parent.width * 0.01
                    source: root.currentTheme === themes.light ? "assets/setting/light.svg" : "assets/setting/dark.svg"
                    fillMode: Image.PreserveAspectFit
                    visible: false
                    mipmap: true
                    transform: Rotation {
                        id: iconRotation
                        origin.x: settingsIcon.width / 2
                        origin.y: settingsIcon.height / 2
                        angle: 0
                    }
                }

                ColorOverlay {
                    id: iconOverlay
                    anchors.fill: settingsIcon
                    anchors.margins: parent.width * 0.15
                    source: settingsIcon
                    color: currentTheme.settingsiconcolor
                    visible: true
                    cached: true
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            SequentialAnimation {
                id: themeChangeAnimation

                ParallelAnimation {
                    NumberAnimation {
                        target: iconRotation
                        property: "angle"
                        from: 0
                        to: 180
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: iconWrapper
                        property: "scale"
                        from: iconWrapper.scale
                        to: iconWrapper.scale * 0.8
                        duration: 150
                        easing.type: Easing.InQuad
                    }
                }

                ScriptAction {
                    script: {
                        root.toggleTheme()
                    }
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: iconRotation
                        property: "angle"
                        from: 180
                        to: 360
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: iconWrapper
                        property: "scale"
                        from: iconWrapper.scale * 0.8
                        to: settingsIconFocused ? 1.3 : 1.0
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }

                ScriptAction {
                    script: {
                        iconRotation.angle = 0
                        settingsImage.animatingTheme = false
                    }
                }
            }

            function animateThemeChange() {
                if (!animatingTheme) {
                    animatingTheme = true
                    themeChangeAnimation.start()
                } else {
                }
            }

            Keys.onPressed: {
                if (api.keys.isAccept(event)) {
                    event.accepted = true;
                    if (!animatingTheme) {
                        animateThemeChange();
                    }
                }
                if (api.keys.isCancel(event) || event.key === Qt.Key_Right) {
                    event.accepted = true;
                    settingsIconFocused = false;
                    collectionListView.focus = true;
                    soundEffects.play("back");
                }
            }
            onFocusChanged: {
                if (focus) {
                    settingsIconFocused = true;
                } else {
                    settingsIconFocused = false;
                }
            }
        }

        CollectionsView {
            id: collectionListView
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height * 0.15
            Keys.enabled: root.focusEnabled
        }

        GamesGridModel {
            id: gamesGridModel
            currentTheme: root.currentTheme
            rootItem: root
        }

        GamesGridView {
            id: gameGridView
            anchors {
                top: collectionListView.bottom
                topMargin: 10
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            currentShortName: collectionListView.currentShortName
            rootItem: root
            model: {
                if (!collectionListView.model ||
                    collectionListView.currentIndex < 0 ||
                    !collectionListView.model.get(collectionListView.currentIndex)) {
                    return null;
                    }
                    var collection = collectionListView.model.get(collectionListView.currentIndex);
                return collection && collection.games ? collection.games : null;
            }
            visible: !settingsIconSelected
            Keys.enabled: root.focusEnabled
        }
    }

    BottomBar {
        id: bottomBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: conteiner.bottom
        anchors.bottom: parent.bottom
        currentTheme: root.currentTheme
        currentTime: root.currentTime
        currentCollectionName: collectionListView.currentCollectionName
        gameCount: gameGridView.count
        currentGameIndex: gameGridView.currentIndex
        collectionListViewActiveFocus: collectionListView.activeFocus
        settingsIconSelected: root.settingsIconSelected
    }

    GameInfo {
        id: gameInfo
        currentGame: root.game
        gameInfoFocused: root.gameInfoFocused
        isGameInfoOpen: root.isGameInfoOpen
        property var root: root
        property var gameGridView: gameGridView
        property var soundEffects: soundEffects
    }

    Loader {
        id: searchOverlayLoader
        anchors.fill: parent
        active: false
        z: 1000

        sourceComponent: Component {
            Item {
                id: searchOverlayContainer
                property var lastFocusedItem: null

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.95)

                    Timer {
                        id: focusTimer2
                        interval: 100
                        running: true
                        onTriggered: keyboard.forceActiveFocus()
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {}
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        SearchBar {
                            id: searchBar
                            width: parent.width * 0.6
                            anchors.horizontalCenter: parent.horizontalCenter
                            currentTheme: root.currentTheme
                        }

                        Row {
                            width: parent.width * 0.95
                            height: parent.height * 0.4
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 20

                            LastPlayedList {
                                id: lastPlayedList
                                height: parent.height
                                width: parent.width * 0.35
                                currentTheme: root.currentTheme
                            }

                            Keyboard {
                                id: keyboard
                                height: parent.height
                                width: parent.width * 0.30
                                currentTheme: root.currentTheme
                                onKeySelected: function(key) {
                                    if (key === "") {
                                        searchBar.text = ""
                                    } else {
                                        searchBar.text += key
                                    }
                                }
                                onCloseRequested: searchVisible = false
                            }

                            FavoriteList {
                                id: favoriteList
                                height: parent.height
                                width: parent.width * 0.35
                                currentTheme: root.currentTheme
                            }
                        }

                        SearchResultsView {
                            id: searchResultsView
                            width: parent.width
                            height: parent.height * 0.45
                            property var currentTheme: root.currentTheme
                        }
                    }

                    Keys.onPressed: {
                        if (api.keys.isCancel(event)) {
                            event.accepted = true
                            searchVisible = false
                            if (typeof soundEffects !== 'undefined') soundEffects.play("back")
                        }
                    }
                }

                Component.onCompleted: {
                    searchResultsView.resetRandomGames()
                    lastFocusedItem = focusManager.currentFocus
                    focusManager.setFocus("search", "games")
                }

                function handleMouseFocusChange(newFocus) {
                    if (newFocus === "searchBar") {
                        searchBar.forceActiveFocus()
                        keyboard.forceActiveFocus()
                    } else if (newFocus === "lastPlayed") {
                        lastPlayedList.forceActiveFocus()
                        lastPlayedList.currentIndex = 0
                        keyboard.resetKeyboard()
                    } else if (newFocus === "searchResults") {
                        searchResultsView.forceActiveFocus()
                        searchResultsView.currentIndex = 0
                        keyboard.resetKeyboard()
                    }
                    else if (newFocus === "favorites") {
                        favoriteList.forceActiveFocus()
                        favoriteList.currentIndex = 0
                        keyboard.resetKeyboard()
                    }
                }
            }
        }
    }

    function resetSearch() {
        if (searchOverlayLoader.item) {
            searchOverlayLoader.item.searchBar.text = ""
            searchOverlayLoader.item.searchResultsView.filter = ""
            searchOverlayLoader.item.searchResultsView.currentIndex = -1
            if (searchOverlayLoader.item.lastPlayedList.count > 0) {
                searchOverlayLoader.item.lastPlayedList.currentIndex = 0
            }
            if (searchOverlayLoader.item.favoriteList.count > 0) {
                searchOverlayLoader.item.favoriteList.currentIndex = 0
            }
            if (typeof keyboard !== 'undefined') {
                keyboard.resetKeyboard()
            }
        }
    }

    function toggleFavorite(game) {
        if (!game) return;

        var collectionName = Utils.getNameCollecForGame(game, api);
        for (var i = 0; i < api.collections.count; ++i) {
            var collection = api.collections.get(i);
            if (collection.name === collectionName) {
                for (var j = 0; j < collection.games.count; ++j) {
                    var currentGame = collection.games.get(j);
                    if (currentGame.title === game.title) {
                        currentGame.favorite = !currentGame.favorite;
                        if (gameInfo.currentGame && gameInfo.currentGame.title === game.title) {
                            gameInfo.favoriteButton.isFavorite = currentGame.favorite;
                        }
                        break;
                    }
                }
                break;
            }
        }
    }

    function showGameInfo() {
        if (gameGridView.model && gameGridView.currentIndex >= 0) {
            root.game = gameGridView.model.get(gameGridView.currentIndex);
        }
        isGameInfoOpen = true;
        focusManager.setFocus("gameinfo", "games");
        soundEffects.play("go");
    }

    function hideGameInfo() {
        isGameInfoOpen = false;
        focusManager.setFocus("games", "gameinfo");
        soundEffects.play("back");
    }
}
