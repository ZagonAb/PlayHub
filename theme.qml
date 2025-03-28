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
    property bool initialZoomComplete: false
    property bool gameInfoFocused: false
    property bool gameInfoVisible: false
    property bool isMinimizing: false
    property bool isVisible: false
    property var game: null
    property real iconSize: Math.min(height * 0.50, width * 0.02)
    property string currentTime: Qt.formatDateTime(new Date(), "dd-MM HH:mm")
    property var currentTheme: themes.blackAndWhite
    property string currentThemeName: api.memory.get('selectedTheme') || "BLACK AND WHITE"
    property string maskImageSource: "assets/overlay/overlay.png"

    property bool isGameInfoOpen: false

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
                    styleColor: "black"
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 3
                        verticalOffset: 3
                        radius: 20
                        samples: 20
                        color: "black"
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
                    radius: 20
                    samples: 20
                    color: "black"
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

        SoundEffect {
            id: soundEffect
            source: "assets/audio/sound.wav"
            loops: 1
            volume: 0.2
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
            focusTimer.start()
        }
    }

    Timer {
        id: focusTimer
        interval: 3100
        repeat: false
        onTriggered: {
            collectionListView.focus = true
        }
    }

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
            primary: "#2c5164",
            secondary: "#292d32",
            text: "#a8a8a6",
            textSelected: "white",
            border: "#3999cb",
            gridviewborder: "#3999cb",
            settingsText: "#3999cb",
            iconColor: "#a8a8a6",
            favoriteiconColor: "#d00003"
        },
        "breeze": {
            background: "#eff0f1",
            primary: "#bbdef1",
            secondary: "#eff0f1",
            text: "#5a5b5b",
            textgridview: "#3999cb",
            textSelected: "#151515",
            border: "#3999cb",
            gridviewborder: "#3999cb",
            settingsText: "#3999cb",
            iconColor: "#5a5b5b",
            favoriteiconColor: "#d00003"
        },
        "nordicdarker": {
            background: "#3B4252",
            primary: "#707d97",
            secondary: "#3B4252",
            text: "#b2b6c0",
            textSelected: "white",
            border: "#707d97",
            gridviewborder: "#707d97",
            settingsText: "#707d97",
            iconColor: "#b2b6c0",
            favoriteiconColor: "#d00003"
        },
        "grayandgray": {
            background: "#202020",
            primary: "#303030",
            secondary: "#202020",
            text: "#8b8b8b",
            textSelected: "#b5b5b5",
            border: "#303030",
            gridviewborder: "#303030",
            settingsText: "#b5b5b5",
            iconColor: "#b5b5b5",
            favoriteiconColor: "#d00003"
        },
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
            case "NORDIC DARKER":
                currentTheme = themes.nordicdarker;
                maskImageSource = "assets/overlay/overlay2.png";
                break;
            case "GRAY AND GRAY":
                currentTheme = themes.grayandgray;
                maskImageSource = "assets/overlay/overlay3.png";
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
            root.currentThemeName = savedTheme;
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
                border.width: 2
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
                if (gameGridView.model && gameGridView.model.count > 0) {
                    collectionListView.focus = false;
                    gameGridView.focus = true;
                    var currentIndex = gameGridView.currentIndex;
                    gameGridView.currentIndex = -1;
                    gameGridView.currentIndex = currentIndex;
                    goSound.play();
                } else {
                    backSound.play()
                }
            }
        }

        Item {
            id: settingsItem
            width: parent.width
            height: parent.height
            visible: settingsIconSelected

            Image {
                id: settingbackground
                source: "assets/setting/settingbackground.svg"
                width: parent.width * 0.5
                height: parent.height * 0.8
                anchors.centerIn: parent

                mipmap: true
                visible: false
            }

            ColorOverlay {
                id: iconOverlayicon
                anchors.fill: settingbackground
                source: settingbackground
                color: currentTheme.iconColor
                opacity: 0.2
                visible: true
                cached: true

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
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
                        ListElement { colorOption: "NORDIC DARKER" }
                        ListElement { colorOption: "GRAY AND GRAY"}
                    }

                    delegate: Rectangle {
                        id: listviewColors
                        width: colorListView.width
                        height: 50
                        radius: 30

                        color: {
                            if (index === colorListView.currentIndex) {
                                return currentTheme.primary
                            } else if (model.colorOption === root.currentThemeName) {
                                return Qt.darker(currentTheme.primary, 1.2)
                            } else {
                                return currentTheme.secondary
                            }
                        }

                        opacity: 0.8

                        Rectangle {
                            width: 8
                            height: parent.height * 0.5
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 4
                            visible: model.colorOption === root.currentThemeName
                            color: currentTheme.border
                        }

                        Text {
                            id: colornames
                            anchors.centerIn: parent
                            text: model.colorOption
                            font.pixelSize: 16
                            color: {
                                if (index === colorListView.currentIndex) {
                                    return currentTheme.textSelected
                                } else if (model.colorOption === root.currentThemeName) {
                                    return currentTheme.textSelected
                                } else {
                                    return currentTheme.text
                                }
                            }
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
                            root.currentThemeName = selectedTheme;
                            applyTheme(selectedTheme);
                            naviSound.play();
                        }else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
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
            keyNavigationEnabled: true
            keyNavigationWraps: true
            width: parent.width
            cellHeight: collectionListView.currentShortName === "history" ? height / 2 : height / 2
            cellWidth: collectionListView.currentShortName === "history" ? parent.width / 3 - 5 : parent.width / 5 - 5
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
                    if (isSelected && gameImage.status === Image.Ready) {
                        var boxfrontItem = gameImage;
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
                                    id: gameImage
                                    visible: status === Image.Ready
                                    source: collectionListView.currentShortName === "history"
                                    ? (model.assets.screenshot || model.assets.boxFront)
                                    : model.assets.boxFront
                                    fillMode: collectionListView.currentShortName === "history"
                                    ? Image.Stretch
                                    : Image.PreserveAspectFit
                                    asynchronous: true
                                    width: parent.width * 0.93
                                    height: parent.height * 0.93
                                    anchors.centerIn: parent
                                    scale: isSelected && gameGridView.focus ? 1.04 : 1.0

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
                                        color: currentTheme.textSelected
                                        spread: 0.5
                                        radius: 15
                                    }
                                }

                                Item {
                                    id: favoriteIconContainer
                                    width: collectionListView.currentShortName === "history" ?
                                    parent.width * 0.10 : parent.width * 0.17
                                    height: parent.height * 0.17
                                    anchors {
                                        top: gameImage.top
                                        right: gameImage.right
                                        topMargin: (parent.height - gameImage.paintedHeight) / 2.5
                                        rightMargin: (parent.width - gameImage.paintedWidth) / 2.3
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
                                    visible: model.favorite && gameImage.status === Image.Ready
                                    scale: isSelected && gameGridView.focus ? 1.15 : 0.8
                                    Behavior on scale { NumberAnimation { duration: 150 } }
                                }

                                Image {
                                    id: noImage
                                    visible: gameImage.status !== Image.Ready
                                    source: isSelected && gameGridView.focus ? "assets/no-image/no-image-white.png" : "assets/no-image/no-image-black.png"
                                    anchors.centerIn: parent
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    width: parent.width * 0.60
                                    height: parent.height * 0.60
                                    mipmap: true
                                }

                                Column {
                                    visible: collectionListView.currentShortName === "history"
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        bottom: gameImage.bottom
                                    }
                                    spacing: 2

                                    Rectangle {
                                        width: gameImage.width
                                        height: gameImage.height * 0.080
                                        radius: 5
                                        color: "#80000000"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        scale: isSelected && gameGridView.focus ? 1.04 : 1.0

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: 150
                                            }
                                        }

                                        Text {
                                            anchors.fill: parent
                                            text: "Last played: " + Qt.formatDateTime(model.lastPlayed, "dd/MM/yyyy")
                                            color: "white"
                                            font.pixelSize: Math.min(root.height * 0.02, root.width * 0.05)
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
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
                        text: "The " + collectionListView.currentShortName + " collection is empty"
                        font.pixelSize: Math.min(root.height * 0.04, root.width * 0.07)
                        color: currentTheme.text
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Item {
                        width: parent.width * 0.70
                        height: parent.height * 0.70
                        anchors.horizontalCenter: parent.horizontalCenter

                        Image {
                            id: collectionsIcons
                            source: collectionListView.currentShortName === "favorite"
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
                            color: currentTheme.text
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

            SoundEffect {
                id: favSound
                source: "assets/audio/Fav.wav"
                volume: 0.5
            }

            Keys.onPressed: {
                if (!event.isAutoRepeat && api.keys.isFilters(event)) {
                    event.accepted = true;
                    gameGridView.focus = false;
                    gameInfoFocused = true;
                    root.isGameInfoOpen = true;
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
                            asynchronous: true
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
                            asynchronous: true
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
                            asynchronous: true
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
                id: okRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: backRow.left
                spacing: 10
                visible: colorListView.focus

                Rectangle {
                    width: bottomBar.iconSize
                    height: bottomBar.iconSize
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: okicon2
                        anchors.fill: parent
                        source: "assets/control/ok.svg"
                        visible: false
                        mipmap: true
                    }

                    ColorOverlay {
                        anchors.fill: okicon2
                        source: okicon2
                        color: currentTheme.iconColor
                        cached: true
                        visible: true
                    }
                }

                Text {
                    text: "CHOOSE"
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
                        visible: true
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

    Item {
        id: gameInfo
        width: parent.width
        height: parent.height
        visible: x < parent.width
        opacity: root.isGameInfoOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        x: root.isGameInfoOpen ? 0 : parent.width
        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        Item {
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
                    source: game && game.assets && game.assets.screenshot ? game.assets.screenshot : "assets/no-image/defaultimage.png"
                    fillMode: Image.PreserveAspectCrop
                    mipmap: true
                    visible: true
                    asynchronous: true
                }
            }

            Image {
                id: defaultImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: "assets/no-image/defaultimage.png"
                mipmap: true
                visible: backgroundImage.status === Image.Error
                asynchronous: true
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

                Item {
                    Layout.preferredWidth: root.width * 0.35
                    Layout.fillHeight: true

                    Image {
                        id: boxArt
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.5
                        source: game && game.assets && game.assets.boxFront ? game.assets.boxFront : "assets/no-image/defaultimage.png"
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        layer.enabled: true
                        layer.effect: Glow {
                            samples: 100
                            color: currentTheme.textSelected
                            spread: 0.5
                            radius: 15
                        }
                    }

                    Image {
                        id: boxArtdefault
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.5
                        source: "assets/no-image/defaultimage.png"
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        visible: boxArt.status === Image.Error
                        layer.enabled: true
                        layer.effect: Glow {
                            samples: 100
                            color: currentTheme.textSelected
                            spread: 0.5
                            radius: 15
                        }
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
                            color: currentTheme.text
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
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
                            color: currentTheme.text
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
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

                        Connections {
                            target: root
                            function onIsGameInfoOpenChanged() {
                                if (root.isGameInfoOpen) {
                                    buttonsGames.currentIndex = 0;
                                }
                            }
                        }

                        Rectangle {
                            id: playButton
                            color: currentTheme.primary
                            width: gameInfo.width * 0.1
                            height: parent.currentIndex === 0 ? gameInfo.height * 0.06 : gameInfo.height * 0.05

                            border.color: currentTheme.textSelected
                            radius: gameInfo.width * 0.005

                            Behavior on height {
                                NumberAnimation { duration: 50 }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "Launch"
                                color: currentTheme.textSelected
                                font.pixelSize: Math.min(gameInfo.height * 0.02, gameInfo.width * 0.06)
                            }
                        }

                        Rectangle {
                            id: favoriteButton
                            color: currentTheme.primary
                            width: gameInfo.width * 0.1
                            height: parent.currentIndex === 1 ? gameInfo.height * 0.06 : gameInfo.height * 0.05
                            border.color: currentTheme.textSelected
                            radius: gameInfo.width * 0.005

                            Behavior on height {
                                NumberAnimation { duration: 50 }
                            }

                            property bool isFavorite: false

                            Connections {
                                target: root
                                function onGameChanged() {
                                    favoriteButton.updateFavoriteState();
                                }
                            }

                            Connections {
                                target: gameInfo
                                function onVisibleChanged() {
                                    if (gameInfo.visible) {
                                        favoriteButton.updateFavoriteState();
                                    }
                                }
                            }

                            function updateFavoriteState() {
                                if (!game) {
                                    isFavorite = false;
                                    return;
                                }

                                var collectionName = getNameCollecForGame(game);
                                for (var i = 0; i < api.collections.count; ++i) {
                                    var collection = api.collections.get(i);
                                    if (collection.name === collectionName) {
                                        for (var j = 0; j < collection.games.count; ++j) {
                                            var currentGame = collection.games.get(j);
                                            if (currentGame.title === game.title) {
                                                isFavorite = currentGame.favorite;
                                                return;
                                            }
                                        }
                                        break;
                                    }
                                }
                                isFavorite = false;
                            }

                            Text {
                                anchors.centerIn: parent
                                text: favoriteButton.isFavorite ? "Favorite -" : "Favorite +"
                                color: currentTheme.textSelected
                                font.pixelSize: Math.min(gameInfo.height * 0.02, gameInfo.width * 0.06)
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
                                    event.accepted = true;
                                    gameInfoFocused = false;
                                    root.isGameInfoOpen = false;
                                    gameGridView.forceActiveFocus();
                                    naviSound.play();

                                    if (gameGridView.currentIndex >= 0 &&
                                        gameGridView.currentIndex < gameGridView.count) {
                                        game = gameGridView.model.get(gameGridView.currentIndex);
                                        } else {
                                            game = null;
                                        }

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
                            color: currentTheme.text
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: game && game.developer ? game.developer : "Unknown"
                            color: currentTheme.textSelected
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }

                        Text {
                            text: "Publisher:"
                            color: currentTheme.text
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: game && game.publisher ? game.publisher : "Unknown"
                            color: currentTheme.textSelected
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }

                        Text {
                            text: "Genre:"
                            color: currentTheme.text
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
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
                            color: currentTheme.textSelected
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }

                        Text {
                            text: "Release Date:"
                            color: currentTheme.text
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: game && game.releaseYear > 0 ? game.releaseYear.toString() : "Unknown"
                            color: currentTheme.textSelected
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }

                        Text {
                            id: gamecollection
                            text: "Collection:"
                            color: currentTheme.text
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: getNameCollecForGame(game)
                            color: currentTheme.textSelected
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
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
                            color: currentTheme.text
                            visible: game && game.playTime > 0
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
                                radius: 3
                                samples: 5
                                spread: 0.3
                                horizontalOffset: 0
                                verticalOffset: 0
                            }
                        }
                        Text {
                            text: calculatePlayTimeText(false)
                            color: currentTheme.textSelected
                            font.pixelSize: Math.min(root.height * 0.03, root.width * 0.06)
                            visible: game && game.playTime > 0
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: currentTheme.background
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

            Item {
                id: descriptionContainer
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: parent.height * 0.1

                Item {
                    id: clipContainer
                    anchors {
                        leftMargin: 10
                        fill: parent
                    }
                    clip: true

                    Text {
                        id: scrollingText
                        text: {
                            if (game && game.description) {
                                var firstDotIndex = game.description.indexOf(".");
                                var secondDotIndex = game.description.indexOf(".", firstDotIndex + 1);
                                if (secondDotIndex !== -1) {
                                    return game.description.substring(0, secondDotIndex + 1);
                                } else {
                                    return game.description;
                                }
                            } else {
                                return "No description available, use game scraper to get proper information...";
                            }
                        }

                        color: currentTheme.text
                        font.pixelSize: Math.min(parent.height * 0.3, parent.width * 0.03)
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height

                        property bool shouldScroll: width > clipContainer.width

                        x: shouldScroll ? clipContainer.width : 10

                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: currentTheme.background
                            radius: 3
                            samples: 5
                            spread: 0.5
                        }

                        NumberAnimation on x {
                            id: scrollAnim
                            from: scrollingText.shouldScroll ? clipContainer.width : 10
                            to: scrollingText.shouldScroll ? -scrollingText.width : 10
                            duration: Math.max(4000, scrollingText.width * 10)
                            loops: Animation.Infinite
                            running: root.isGameInfoOpen && scrollingText.shouldScroll
                        }

                        onTextChanged: {
                            if (scrollAnim.running) {
                                scrollAnim.restart()
                            }

                            if (!shouldScroll) {
                                x = 10
                            }
                        }
                    }
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: root.width * 0.050
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                        GradientStop { position: 1.0; color: currentTheme.primary }
                    }

                    visible: scrollingText.shouldScroll
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: root.width * 0.050
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: currentTheme.primary }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.0) }
                    }
                    visible: scrollingText.shouldScroll
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
