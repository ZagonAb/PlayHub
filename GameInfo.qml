import QtQuick 2.15
import QtMultimedia 5.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Item {
    id: gameInfo
    width: parent.width
    height: parent.height
    visible: x < parent.width
    opacity: root.isGameInfoOpen ? 1 : 0
    property bool gameInfoFocused: false
    property bool isGameInfoOpen: false
    property int lastFocusedIndex: 0
    property var currentTheme: root.currentTheme
    property string currentThemeName: root.currentThemeName
    property var currentGame: root.game ? root.game : null

    onVisibleChanged: {
        if (visible) {
            navigationContainer.currentIndex = 0;
            navigationContainer.forceActiveFocus();
        }
    }

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
            gameInfo.currentTheme = root.currentTheme;
            gameInfo.currentThemeName = root.currentThemeName;
        }
    }

    Component.onCompleted: {
        applyTheme(root.currentThemeName);
    }

    onCurrentGameChanged: {
        if (currentGame) {
            favoriteButton.updateFavoriteState();
        } else if (gameGridView.model && gameGridView.model.count > 0) {
            currentGame = gameGridView.model.get(gameGridView.currentIndex);
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    x: isGameInfoOpen ? 0 : parent.width
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
            width: parent.width
            height: parent.height * 0.90
            anchors.top: parent.top

            Image {
                id: backgroundBlurImage
                anchors.fill: parent
                source: game && game.assets && game.assets.screenshot ? game.assets.screenshot : "assets/.no-image/no_screenshot.png"
                fillMode: Image.PreserveAspectCrop
                mipmap: true
                visible: false
                asynchronous: true
            }

            FastBlur {
                id: backgroundBlur
                anchors.fill: parent
                source: backgroundBlurImage
                radius: 60
                opacity: 0.6

                transform: Scale {
                    origin.x: backgroundBlur.width / 2
                    origin.y: backgroundBlur.height / 2
                    xScale: -1
                }
            }

            LinearGradient {
                id: leftEdgeGradient
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * 0.15
                start: Qt.point(0, 0)
                end: Qt.point(width, 0)

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "black" }
                    GradientStop { position: 0.7; color: "#40000000" }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }

            LinearGradient {
                id: rightEdgeGradient
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * 0.15
                start: Qt.point(width, 0)
                end: Qt.point(0, 0)

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "black" }
                    GradientStop { position: 0.7; color: "#40000000" }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }

            Image {
                id: backgroundImage
                anchors.fill: parent
                source: game && game.assets && game.assets.screenshot ? game.assets.screenshot : "assets/.no-image/no_screenshot.png"
                fillMode: Image.PreserveAspectFit
                mipmap: true
                visible: false
                asynchronous: true
            }

            ShaderEffect {
                id: scanDotEffect
                anchors.centerIn: parent
                width: {
                    if (backgroundImage.status === Image.Ready) {
                        var imgRatio = backgroundImage.sourceSize.width / backgroundImage.sourceSize.height;
                        var containerRatio = parent.width / parent.height;
                        return imgRatio > containerRatio ? parent.width : parent.height * imgRatio;
                    }
                    return parent.width;
                }
                height: {
                    if (backgroundImage.status === Image.Ready) {
                        var imgRatio = backgroundImage.sourceSize.width / backgroundImage.sourceSize.height;
                        var containerRatio = parent.width / parent.height;
                        return imgRatio > containerRatio ? parent.width / imgRatio : parent.height;
                    }
                    return parent.height;
                }

                property variant source: backgroundImage
                property real scanOpacity: 0.3
                property real dotSpacing: 2.0
                visible: false
                fragmentShader: "
                uniform sampler2D source;
                uniform lowp float scanOpacity;
                uniform highp float dotSpacing;
                varying highp vec2 qt_TexCoord0;
                void main() {
                vec4 baseColor = texture2D(source, qt_TexCoord0);
                highp vec2 pix = gl_FragCoord.xy;
                highp float fx = floor(pix.x / dotSpacing);
                highp float fy = floor(pix.y / dotSpacing);
                highp float m = mod(fx + fy, 2.0);
                highp float maskDot = (m < 0.5) ? 1.0 : 0.0;
                baseColor.rgb = mix(baseColor.rgb, vec3(0.0), maskDot * scanOpacity);
                gl_FragColor = baseColor;
            }
            "
            }

            LinearGradient {
                id: fadeGradient
                anchors.fill: scanDotEffect
                visible: false
                start: Qt.point(0, 0)
                end: Qt.point(scanDotEffect.width, 0)

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00000000" }
                    GradientStop { position: 0.1; color: "#FF000000" }
                    GradientStop { position: 0.9; color: "#FF000000" }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }

            OpacityMask {
                anchors.fill: scanDotEffect
                source: scanDotEffect
                maskSource: fadeGradient
            }
        }

        Image {
            id: defaultImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: "assets/.no-image/no_screenshot.png"
            mipmap: true
            visible: backgroundImage.status === Image.Error
            asynchronous: true
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.4; color: Qt.rgba(0, 0, 0, 0.3) }
                GradientStop { position: 0.8; color: "black" }
            }
            opacity: 1
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 40
                rightMargin: 1
                topMargin: 30
                bottomMargin: 30
            }
            spacing:1

            Item {
                id: imageBoxArt
                Layout.preferredWidth: root.width * 0.35
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignHCenter

                Image {
                    id: boxArt
                    anchors.centerIn: parent
                    width: parent.width * 0.8
                    height: parent.height * 0.5
                    source: game && game.assets && game.assets.boxFront ? game.assets.boxFront : "assets/.no-image/defaultimage.png"
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
                    source: "assets/.no-image/defaultimage.png"
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
                Layout.fillHeight: true
                spacing: 20
                Layout.alignment: Qt.AlignLeft | Qt.AlignHCenter
                Layout.leftMargin: 0

                Text {
                    text: game && game.title ? game.title : ""
                    font.pixelSize: root.width * 0.03
                    font.bold: true
                    color: "white"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }

                Item {
                    id: navigationContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height
                    Layout.maximumHeight: childrenRect.height
                    property int currentIndex: 0
                    property alias navigationContainer: navigationContainer
                    focus: gameInfoFocused

                    Connections {
                        target: root
                        function onIsGameInfoOpenChanged() {
                            if (root.isGameInfoOpen) {
                                navigationContainer.currentIndex = 0;
                            }
                        }
                    }


                    function restoreFocus() {
                        gameInfoFocused = true;
                        forceActiveFocus();
                        currentIndex = 2;
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: 15

                        RowLayout {
                            id: buttonsGames
                            spacing: gameInfo.width * 0.02
                            Layout.fillWidth: true

                            CustomButton {
                                id: playButton
                                Layout.preferredWidth: contentWidth + 40
                                Layout.minimumWidth: 150
                                Layout.preferredHeight: 50
                                text: "Launch"
                                iconSource: "assets/icons/launch.svg"
                                backgroundColor: currentTheme.primary
                                textColor: currentTheme.textbutton
                                borderColor: currentTheme.bordercolor
                                radius: 10
                                isSelected: navigationContainer.currentIndex === 0
                                showFocusRing: true

                                onClicked: {
                                    if (game) {
                                        root.isMinimizing = true;
                                        launchTimer.start();
                                        soundEffects.play("launch");
                                    }
                                }
                            }

                            CustomButton {
                                id: favoriteButton
                                Layout.preferredWidth: contentWidth + 40
                                Layout.minimumWidth: 150
                                Layout.preferredHeight: 50
                                dynamicText: isFavorite ? "Favorite ON" : "Favorite OFF"
                                iconSource: isFavorite ? "assets/icons/heart-filled.svg" : "assets/icons/heart-outline.svg"
                                backgroundColor: currentTheme.primary
                                textColor: currentTheme.textbutton
                                borderColor: currentTheme.bordercolor
                                radius: 10
                                isSelected: navigationContainer.currentIndex === 1
                                showFocusRing: true
                                enableTextTransition: true
                                textTransitionDuration: 250

                                Connections {
                                    target: root
                                    function onGameChanged() {
                                        favoriteButton.updateFavoriteState();
                                    }
                                }

                                property bool isFavorite: game ? game.favorite : false

                                Binding {
                                    target: favoriteButton
                                    property: "isFavorite"
                                    value: game ? game.favorite : false
                                    when: game !== null
                                }

                                onIsFavoriteChanged: {
                                    Qt.callLater(updateWidth);
                                }

                                function updateFavoriteState() {
                                    if (!game) {
                                        isFavorite = false;
                                        return;
                                    }

                                    var collectionName = Utils.getNameCollecForGame(game, api);
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

                                onClicked: {
                                    soundEffects.play("fav");
                                    var selectedGame = game;
                                    var collectionName = Utils.getNameCollecForGame(selectedGame, api);
                                    for (var i = 0; i < api.collections.count; ++i) {
                                        var collection = api.collections.get(i);
                                        if (collection.name === collectionName) {
                                            for (var j = 0; j < collection.games.count; ++j) {
                                                var currentGame = collection.games.get(j);
                                                if (currentGame.title === selectedGame.title) {
                                                    currentGame.favorite = !currentGame.favorite;
                                                    isFavorite = currentGame.favorite;
                                                    break;
                                                }
                                            }
                                            break;
                                        }
                                    }
                                }

                                Component.onCompleted: {
                                    updateFavoriteState();
                                }
                            }

                            CustomButton {
                                id: previewButton
                                Layout.preferredWidth: contentWidth + 40
                                Layout.minimumWidth: 150
                                Layout.preferredHeight: 50
                                opacity: enabled ? 1.0 : 0.6
                                enabled: currentGame && currentGame.assets && currentGame.assets.video && currentGame.assets.video.toString() !== ""
                                text: enabled ?  "No Preview" : "Play Preview"
                                Behavior on opacity {
                                    NumberAnimation { duration: 200 }
                                }
                                iconSource: "assets/icons/play.svg"
                                backgroundColor: currentTheme.primary
                                textColor: currentTheme.textbutton
                                borderColor: currentTheme.bordercolor
                                radius: 10
                                isSelected: navigationContainer.currentIndex === 2
                                showFocusRing: true

                                onClicked: {
                                    if (currentGame && currentGame.assets && currentGame.assets.video) {
                                        soundEffects.play("navi");
                                        navigationContainer.focus = false;
                                        previewButton.isSelected = false;
                                        gameInfoFocused = false;
                                        videoPlayer.playVideo(currentGame.assets.video, previewButton, gameInfo, currentGame.assets.logo)
                                    } else {
                                        soundEffects.play("back");
                                    }
                                }
                            }
                        }

                        Item {
                            id: descriptionButton
                            Layout.preferredWidth: parent.width * 0.6
                            Layout.maximumWidth: parent.width * 0.7
                            Layout.preferredHeight: 80

                            property string fullDescription: game && game.description ? game.description : "No description available..."
                            property string shortDescription: ""
                            property string displayText: ""
                            property bool isExpanded: false
                            property bool isSelected: navigationContainer.currentIndex === 3

                            Component.onCompleted: {
                                updateDescription();
                            }

                            Connections {
                                target: root
                                function onGameChanged() {
                                    descriptionButton.updateDescription();
                                }
                            }

                            onIsSelectedChanged: {
                                if (!isSelected && isExpanded) {
                                    descriptionButton.displayText = descriptionButton.shortDescription;
                                    descriptionButton.isExpanded = false;
                                }
                            }

                            function updateDescription() {
                                shortDescription = getShortDescription();
                                displayText = shortDescription;
                                isExpanded = false;
                            }

                            function getShortDescription() {
                                if (!game || !game.description) return "No description available...";
                                let text = game.description;
                                let firstDot = text.indexOf(".");
                                let secondDot = firstDot > -1 ? text.indexOf(".", firstDot + 1) : -1;
                                if (secondDot > -1 && secondDot < 150) {
                                    return text.substring(0, secondDot + 1);
                                } else if (firstDot > -1 && firstDot < 150) {
                                    return text.substring(0, firstDot + 1);
                                }
                                return text.substring(0, 150) + (text.length > 150 ? "..." : "");
                            }

                            Rectangle {
                                id: bg
                                anchors.fill: parent
                                color: descriptionButton.isSelected ? "white" : "transparent"
                                radius: 10
                                border.color: descriptionButton.isSelected ? currentTheme.textSelected : "transparent"
                                border.width: descriptionButton.isSelected ? 2 : 0
                                opacity: descriptionButton.isSelected ? 1 : 0

                                Behavior on opacity {
                                    NumberAnimation { duration: 200 }
                                }
                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                            }

                            Item {
                                anchors {
                                    fill: parent
                                    margins: 10
                                }

                                Text {
                                    id: descText
                                    anchors {
                                        left: parent.left
                                        right: moreText.visible ? moreText.left : parent.right
                                        verticalCenter: parent.verticalCenter
                                        margins: 10
                                    }
                                    text: descriptionButton.displayText
                                    color: descriptionButton.isSelected ? "black" : "white"
                                    font.pixelSize: 16
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: descriptionButton.isExpanded ? -1 : 2
                                    elide: descriptionButton.isExpanded ? Text.ElideNone : Text.ElideRight
                                    visible: text !== ""

                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }

                                Text {
                                    id: moreText
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                        rightMargin: 10
                                    }
                                    text: descriptionButton.isExpanded ? "Less" : "More"
                                    color: descriptionButton.isSelected ? "black" : "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                    visible: descriptionButton.shortDescription !== descriptionButton.fullDescription && descriptionButton.shortDescription !== ""

                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    descriptionButton.expandDescription();
                                }
                            }

                            function expandDescription() {
                                if (gameDetailsPanel.isAnimatedVisible) {
                                    gameDetailsPanel.isAnimatedVisible = false;
                                    descriptionButton.isExpanded = false;
                                    descriptionButton.displayText = descriptionButton.shortDescription;
                                } else {
                                    gameDetailsPanel.isAnimatedVisible = true;
                                    descriptionButton.isExpanded = false;
                                    descriptionButton.displayText = descriptionButton.shortDescription;
                                }
                                soundEffects.play("navi");
                            }
                        }
                    }

                    Keys.onLeftPressed: {
                        if (currentIndex > 0 && currentIndex <= 3) {
                            currentIndex--;
                            soundEffects.play("navi");
                        }
                    }

                    Keys.onRightPressed: {
                        if (currentIndex >= 0 && currentIndex < 3) {
                            currentIndex++;
                            soundEffects.play("navi");
                        }
                    }

                    Keys.onUpPressed: {
                        if (currentIndex === 3) {
                            descriptionButton.isSelected = false;
                            currentIndex = 0;
                            soundEffects.play("navi");
                        }
                    }

                    Keys.onDownPressed: {
                        if (currentIndex <= 2) {
                            currentIndex = 3;
                            descriptionButton.isSelected = true;
                            soundEffects.play("navi");
                        }
                    }

                    onCurrentIndexChanged: {
                        playButton.isSelected = (currentIndex === 0);
                        favoriteButton.isSelected = (currentIndex === 1);
                        previewButton.isSelected = (currentIndex === 2);
                        descriptionButton.isSelected = (currentIndex === 3);
                    }

                    Keys.onPressed: function(event) {
                        if (!event.isAutoRepeat) {
                            if (api.keys.isCancel(event)) {
                                event.accepted = true;
                                if (videoPlayer.visible) {
                                    videoPlayer.stopVideo();
                                    soundEffects.play("back");
                                    focusManager.setFocus("gameinfo", "mediaplayer");
                                } else if (gameDetailsPanel.isAnimatedVisible) {
                                    gameDetailsPanel.isAnimatedVisible = false;
                                    soundEffects.play("back");
                                    focusManager.setFocus("gameinfo", "gamedetails");
                                } else {
                                    root.hideGameInfo();
                                }
                            }

                            if (api.keys.isAccept(event) && !videoPlayer.visible) {
                                event.accepted = true;
                                if (currentIndex === 0) {
                                    playButton.clicked();
                                } else if (currentIndex === 1) {
                                    favoriteButton.clicked();
                                } else if (currentIndex === 2) {
                                    if (previewButton.enabled) {
                                        previewButton.clicked();
                                    } else {
                                        soundEffects.play("back");
                                    }
                                } else if (currentIndex === 3) {
                                    gameDetailsPanel.isAnimatedVisible = !gameDetailsPanel.isAnimatedVisible;
                                    if (gameDetailsPanel.isAnimatedVisible) {
                                        descriptionButton.isSelected = false;
                                        descriptionButton.displayText = descriptionButton.shortDescription;
                                    } else {
                                        descriptionButton.isSelected = true;
                                    }
                                    soundEffects.play("navi");
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: darkenEffect
        anchors.fill: parent
        visible: gameDetailsPanel.isAnimatedVisible
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.9) }
            GradientStop {
                position: 1.0 - (gameDetailsPanel.width / parent.width);
                color: Qt.rgba(0, 0, 0, 0.5)
            }
            GradientStop { position: 1.0; color: "transparent" }
        }

        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        Connections {
            target: gameDetailsPanel
            function onWidthChanged() {
                darkenEffect.gradient.stops[1].position = 1.0 - (gameDetailsPanel.width / parent.width)
            }
        }
    }

    Timer {
        id: focusRestoreTimer
        interval: 150
        running: false
        repeat: false
        onTriggered: {
            descriptionButton.isSelected = true;
            navigationContainer.currentIndex = 3;
            navigationContainer.forceActiveFocus();
        }
    }

    GameDetails {
        id: gameDetailsPanel
        opacity: 1

        onIsAnimatedVisibleChanged: {
            darkenEffect.opacity = isAnimatedVisible ? 1 : 0
            if (!isAnimatedVisible) {
                focusRestoreTimer.start();
            }
        }
    }

    MediaPlayerComponent {
        id: videoPlayer
        anchors.fill: parent
        z: 1000
        visible: false

        onVisibleChanged: {
            if (!visible) {
                delayTimer.restart();
            }
        }

        Timer {
            id: delayTimer
            interval: 50
            onTriggered: {
                navigationContainer.focus = true;
                navigationContainer.currentIndex = 2;
                previewButton.isSelected = true;
                navigationContainer.forceActiveFocus();
            }
        }
    }

    Rectangle {
        id: videoDarkenEffect
        anchors.fill: parent
        color: "black"
        opacity: videoPlayer.visible ? 0.9 : 0
        z: 999
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
    }
}
