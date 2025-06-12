import QtQuick 2.15
import QtMultimedia 5.15
import QtGraphicalEffects 1.15

FocusScope {
    id: mediaPlayerComponent
    property bool isPlaying: false
    property real playerWidth: parent ? parent.width * 0.6 : 800
    property real playerHeight: parent ? parent.height * 0.6 : 600
    property color dominantColor: "#003366"
    property var returnFocusTo: null
    property var gameInfoContainer: null
    property bool enableShaderEffect: true
    property real scanOpacity: 0.3
    property real dotSpacing: 2.0

    focus: true
    activeFocusOnTab: true

    onActiveFocusChanged: {
        if (activeFocus) {
            playerContainer.forceActiveFocus();
        }
    }

    onParentChanged: {
        if (parent) {
            playerWidth = Qt.binding(function() { return parent.width * 0.6 });
            playerHeight = Qt.binding(function() { return parent.height * 0.6 });
        }
    }
    anchors.centerIn: parent
    visible: false
    z: 2001

    property string videoSource: ""
    property string gameLogo: ""
    property bool isMuted: false
    property bool showControls: false
    property bool isInitializing: false

    function playVideo(source, focusItem, gameInfoRef, logoSource) {
        videoSource = source;
        returnFocusTo = focusItem;
        gameInfoContainer = gameInfoRef;
        gameLogo = logoSource || "";

        isInitializing = true;
        showControls = false;

        mediaPlayer.source = videoSource;
        mediaPlayer.play();
        visible = true;

        logoAnimationTimer.start();

        Qt.callLater(function() {
            forceActiveFocus();
            playerContainer.forceActiveFocus();
            root.focusManager.setFocus("mediaplayer", "gameinfo");
        });
    }

    Timer {
        id: logoAnimationTimer
        interval: 200
        onTriggered: {
            showControls = true;
            hideControlsTimer.restart();
            isInitializing = false;
        }
    }

    function stopVideo() {
        mediaPlayer.stop();
        visible = false;
        showControls = false;
        isInitializing = false;

        if (returnFocusTo) {
            returnFocusTo.isSelected = true;
        }

        Qt.callLater(function() {
            root.focusManager.setFocus("gameinfo", "mediaplayer");
        });
    }

    function showControlsTemporarily() {
        showControls = true;
        hideControlsTimer.restart();
    }

    function formatTime(ms) {
        var hours = Math.floor(ms / 3600000)
        var minutes = Math.floor((ms % 3600000) / 60000)
        var seconds = Math.floor((ms % 60000) / 1000)
        return hours > 0
        ? `${hours}:${pad(minutes)}:${pad(seconds)}`
        : `${minutes}:${pad(seconds)}`
    }

    function pad(num) {
        return num < 10 ? "0" + num : num
    }

    Rectangle {
        id: playerContainer
        width: playerWidth
        height: playerHeight
        anchors.centerIn: parent
        color: "transparent"
        focus: true
        activeFocusOnTab: true

        onActiveFocusChanged: {
            if (activeFocus && !isInitializing) {
                showControls = true;
                hideControlsTimer.restart();
            }
        }

        Timer {
            id: hideControlsTimer
            interval: 5000
            onTriggered: showControls = false
        }

        MediaPlayer {
            id: mediaPlayer
            autoPlay: true
            volume: isMuted ? 0.0 : volumeSlider.value

            onStopped: {
                if (status === MediaPlayer.EndOfMedia) {
                    mediaPlayerComponent.stopVideo();
                }
            }

            onError: {
                console.log("MediaPlayer error:", errorString);
                mediaPlayerComponent.stopVideo();
            }

            onStatusChanged: {
                if (status === MediaPlayer.NoMedia || status === MediaPlayer.InvalidMedia) {
                    mediaPlayerComponent.stopVideo();
                }
            }
        }

        Item {
            id: videoContainer
            anchors.fill: parent
            clip: true

            Item {
                id: scaledVideoContainer
                anchors.fill: parent

                VideoOutput {
                    id: videoOutput
                    anchors.fill: parent
                    source: mediaPlayer
                    visible: !enableShaderEffect
                    fillMode: VideoOutput.PreserveAspectCrop
                }

                ShaderEffect {
                    id: scanDotEffect
                    anchors.fill: parent
                    visible: enableShaderEffect
                    property variant source: ShaderEffectSource {
                        sourceItem: videoOutput
                        live: true
                    }
                    property real scanOpacity: mediaPlayerComponent.scanOpacity
                    property real dotSpacing: mediaPlayerComponent.dotSpacing

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
            }

            Item {
                id: logoContainer
                width: playerWidth * 0.25
                height: playerWidth * 0.1
                anchors {
                    top: parent.top
                    topMargin: 30
                    left: parent.left
                }
                visible: gameLogo !== ""
                clip: true

                Rectangle {
                    id: logoCard
                    width: parent.width
                    height: parent.height
                    color: Qt.rgba(0, 0, 0, 0.8)
                    radius: 8
                    border.color: "#909090"
                    border.width: 2
                    x: -width

                    states: [
                        State {
                            name: "visible"
                            when: showControls
                            PropertyChanges {
                                target: logoCard
                                x: 0
                            }
                        },
                        State {
                            name: "hidden"
                            when: !showControls
                            PropertyChanges {
                                target: logoCard
                                x: -logoCard.width
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            from: "*"; to: "*"
                            NumberAnimation {
                                property: "x"
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }
                    ]

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 5
                        verticalOffset: 5
                        radius: 20
                        samples: 20
                        color: "#80000000"
                    }

                    Image {
                        id: gameLogoImage
                        source: gameLogo
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        mipmap: true
                        smooth: true
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: Qt.rgba(1, 1, 1, 0.2)
                        border.width: 1
                        radius: parent.radius
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPositionChanged: {
                if (mouseY > parent.height - 100) {
                    showControls = true
                    hideControlsTimer.restart()
                }
            }
            onClicked: {
                showControls = true
                hideControlsTimer.restart()
            }
        }

        Rectangle {
            id: controlsContainer
            height: playerHeight * 0.15
            color: Qt.rgba(0, 0, 0, 0.7)
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            opacity: showControls ? 1 : 0
            visible: opacity > 0
            radius: 40

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            Rectangle {
                id: progressBar
                height: playerHeight * 0.015
                color: "#444444"
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: playerWidth * 0.2
                    rightMargin: playerWidth * 0.2
                    bottom: controlsRow.top
                    margins: playerHeight * 0.03
                }

                radius: height / 2

                Rectangle {
                    id: progressIndicator
                    width: mediaPlayer.duration > 0 ? (mediaPlayer.position / mediaPlayer.duration) * parent.width : 0
                    height: parent.height
                    color: "#909090"
                    radius: height / 2

                    Behavior on width {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                Rectangle {
                    id: progressHandle
                    width: playerHeight * 0.030
                    height: width
                    radius: width / 2
                    color: "#909090"
                    anchors.verticalCenter: parent.verticalCenter
                    x: mediaPlayer.duration > 0 ? (mediaPlayer.position / mediaPlayer.duration) * (parent.width - width) : 0
                    visible: true

                    Behavior on x {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                MouseArea {
                    id: progressBarArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (mediaPlayer.duration > 0) {
                            var newPosition = (mouse.x / width) * mediaPlayer.duration
                            mediaPlayer.seek(newPosition)
                        }
                    }
                }
            }

            Row {
                id: controlsRow
                spacing: playerWidth * 0.02
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    margins: playerHeight * 0.02
                }

                Image {
                    source: "assets/icons/replay.svg"
                    width: playerHeight * 0.052
                    height: width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mediaPlayer.seek(mediaPlayer.position - 10000)
                    }
                    mipmap: true
                }

                Image {
                    source: mediaPlayer.playbackState === MediaPlayer.PlayingState
                    ? "assets/icons/pause.svg"
                    : "assets/icons/play.svg"
                    width: playerHeight * 0.052
                    height: width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                                mediaPlayer.pause()
                            } else {
                                mediaPlayer.play()
                            }
                        }
                    }
                    mipmap: true
                }

                Image {
                    source: enableShaderEffect ? "assets/icons/fx_on.svg" : "assets/icons/fx_off.svg"
                    width: playerHeight * 0.052
                    height: width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: enableShaderEffect = !enableShaderEffect
                    }
                    mipmap: true

                    Rectangle {
                        anchors.fill: parent
                        color: enableShaderEffect ? "#909090" : "#666666"
                        radius: 4
                        visible: parent.source === ""

                        Text {
                            anchors.centerIn: parent
                            text: "FX"
                            color: "white"
                            font.pixelSize: parent.height * 0.4
                        }
                    }
                }

                Image {
                    source: "assets/icons/close.svg"
                    width: playerHeight * 0.052
                    height: width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mediaPlayerComponent.stopVideo()
                    }
                    mipmap: true
                }

                Image {
                    source: "assets/icons/forward.svg"
                    width: playerHeight * 0.052
                    height: width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mediaPlayer.seek(mediaPlayer.position + 10000)
                    }
                    mipmap: true
                }
            }

            Item {
                id: volumeControl
                width: playerWidth * 0.12
                height: playerHeight * 0.024
                anchors {
                    right: timeText.left
                    bottom: parent.bottom
                    margins: playerHeight * 0.05
                }

                Image {
                    id: volumeIcon
                    source: isMuted ? "assets/icons/mute.svg" : "assets/icons/volume.svg"
                    width: playerHeight * 0.054
                    height: width
                    mipmap: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: isMuted = !isMuted
                    }
                }

                Rectangle {
                    id: volumeSlider
                    property real value: 1.0
                    height: playerHeight * 0.015
                    width: playerWidth * 0.12
                    color: "#444444"
                    radius: height / 2
                    anchors {
                        left: volumeIcon.right
                        leftMargin: playerWidth * 0.01
                        verticalCenter: volumeIcon.verticalCenter
                    }

                    Rectangle {
                        width: parent.width * parent.value
                        height: parent.height
                        color: "#909090"
                        radius: height / 2
                    }

                    Rectangle {
                        id: volumeHandle
                        width: playerHeight * 0.030
                        height: width
                        radius: width / 2
                        color: "#909090"
                        x: (parent.width - width) * parent.value
                        anchors.verticalCenter: parent.verticalCenter
                        visible: true
                    }

                    MouseArea {
                        id: volumeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onMouseXChanged: {
                            if (pressed) {
                                var newValue = Math.max(0, Math.min(1, mouseX / width))
                                parent.value = newValue
                            }
                        }
                        onClicked: {
                            var newValue = Math.max(0, Math.min(1, mouseX / width))
                            parent.value = newValue
                        }
                    }
                }
            }

            Text {
                id: timeText
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: playerHeight * 0.092
                }
                color: "white"
                text: formatTime(mediaPlayer.position) + " / " + formatTime(mediaPlayer.duration)
                font.pixelSize: playerHeight * 0.024
            }
        }

        Rectangle {
            id: videoBorder
            anchors.fill: parent
            color: "transparent"
            border.color: "#909090"
            border.width: 8
            radius: 0
        }

        onVisibleChanged: {
            if (!visible) {
                mediaPlayer.stop();
            }
        }

        Keys.onPressed: function(event) {
            if (!event.isAutoRepeat) {
                if (api.keys.isCancel(event)) {
                    event.accepted = true;
                    soundEffects.play("back");
                    stopVideo();
                    return;
                }

                if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                    event.accepted = true;
                    soundEffects.play("navi");
                    showControlsTemporarily();
                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                        mediaPlayer.pause();
                    } else {
                        mediaPlayer.play();
                    }
                    return;
                }

                if (api.keys.isDetails(event)) {
                    event.accepted = true;
                    soundEffects.play("navi");
                    showControlsTemporarily();
                    enableShaderEffect = !enableShaderEffect;
                    return;
                }

                switch (event.key) {
                    case Qt.Key_Space:
                        event.accepted = true;
                        soundEffects.play("navi");
                        showControlsTemporarily();
                        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                            mediaPlayer.pause();
                        } else {
                            mediaPlayer.play();
                        }
                        break;
                    case Qt.Key_Left:
                        event.accepted = true;
                        soundEffects.play("navi");
                        showControlsTemporarily();
                        mediaPlayer.seek(mediaPlayer.position - 10000);
                        break;
                    case Qt.Key_Right:
                        event.accepted = true;
                        soundEffects.play("navi");
                        showControlsTemporarily();
                        mediaPlayer.seek(mediaPlayer.position + 10000);
                        break;
                    case Qt.Key_Up:
                        event.accepted = true;
                        soundEffects.play("navi");
                        showControlsTemporarily();
                        volumeSlider.value = Math.min(1.0, volumeSlider.value + 0.1);
                        break;
                    case Qt.Key_Down:
                        event.accepted = true;
                        soundEffects.play("navi");
                        showControlsTemporarily();
                        volumeSlider.value = Math.max(0.0, volumeSlider.value - 0.1);
                        break;
                    default:
                        event.accepted = false;
                }
            }
        }
    }
}
