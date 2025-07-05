import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: buttonRoot
    property real contentWidth: contentRow.width
    width: contentRow.width + leftPadding + rightPadding
    height: Math.max(contentRow.height + topPadding + bottomPadding, 50)

    property alias text: buttonText.text
    property alias textColor: buttonText.color
    property alias font: buttonText.font
    property color backgroundColor: "transparent"
    property color hoverColor: Qt.darker(backgroundColor, 1.2)
    property color pressedColor: Qt.darker(backgroundColor, 1.4)
    property color borderColor: "transparent"
    property int borderWidth: 2
    property int radius: 8
    property bool isSelected: false
    property bool showFocusRing: true
    property string iconSource: ""
    property real iconSize: buttonText.implicitHeight * 0.8
    property real leftPadding: 20
    property real rightPadding: 20
    property real topPadding: 10
    property real bottomPadding: 10
    property real scaleFactor: 1.0
    property real hoverScale: 1.05
    property real clickScale: 0.95
    property int animationDuration: 150

    signal clicked()
    signal pressed()
    signal released()
    signal entered()
    signal exited()

    property string dynamicText: text
    property bool enableTextTransition: false
    property int textTransitionDuration: 200
    property var currentTheme: root.currentTheme

    onDynamicTextChanged: {
        if (enableTextTransition && buttonText.text !== "" && dynamicText !== buttonText.text) {
            textChangeAnimation.start();
        } else {
            buttonText.text = dynamicText;
            Qt.callLater(updateWidth);
        }
    }

    onWidthChanged: {
        var calculatedWidth = contentRow.width + leftPadding + rightPadding;
        if (Math.abs(width - calculatedWidth) > 1) {
            Qt.callLater(updateWidth);
        }
    }

    function updateWidth() {
        var newWidth = contentRow.width + leftPadding + rightPadding;
        if (newWidth > 0 && newWidth !== buttonRoot.width) {
            buttonRoot.width = newWidth;
        }
    }

    Timer {
        id: widthUpdateTimer
        interval: 10
        repeat: false
        onTriggered: updateWidth()
    }

    SequentialAnimation {
        id: textChangeAnimation

        ParallelAnimation {
            NumberAnimation {
                target: buttonText
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: buttonRoot.textTransitionDuration / 2
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: buttonIcon
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: buttonRoot.textTransitionDuration / 2
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: buttonRoot
                property: "scaleFactor"
                to: 0.95
                duration: buttonRoot.textTransitionDuration / 2
                easing.type: Easing.InQuad
            }
        }

        ScriptAction {
            script: {
                buttonText.text = buttonRoot.dynamicText;
                widthUpdateTimer.start();
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: buttonText
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: buttonRoot.textTransitionDuration / 2
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: buttonIcon
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: buttonRoot.textTransitionDuration / 2
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: buttonRoot
                property: "scaleFactor"
                to: isSelected || buttonMouseArea.containsMouse ? hoverScale : 1.0
                duration: buttonRoot.textTransitionDuration / 2
                easing.type: Easing.OutElastic
            }
        }
    }

    SequentialAnimation {
        id: focusAnimation
        loops: 1

        ParallelAnimation {
            NumberAnimation {
                target: focusRing
                property: "opacity"
                from: 0
                to: 1
                duration: buttonRoot.animationDuration
            }
            NumberAnimation {
                target: focusRing
                property: "scale"
                from: 0.8
                to: 1
                duration: buttonRoot.animationDuration
            }
        }
    }

    ParallelAnimation {
        id: hoverAnimation
        NumberAnimation {
            target: buttonRoot
            property: "scaleFactor"
            to: hoverScale
            duration: buttonRoot.animationDuration
            easing.type: Easing.OutQuad
        }
        ColorAnimation {
            target: buttonBackground
            property: "color"
            to: hoverColor
            duration: buttonRoot.animationDuration
        }
    }

    ParallelAnimation {
        id: pressAnimation
        NumberAnimation {
            target: buttonRoot
            property: "scaleFactor"
            to: clickScale
            duration: buttonRoot.animationDuration / 2
        }
        ColorAnimation {
            target: buttonBackground
            property: "color"
            to: pressedColor
            duration: buttonRoot.animationDuration / 2
        }
    }

    ParallelAnimation {
        id: releaseAnimation
        NumberAnimation {
            target: buttonRoot
            property: "scaleFactor"
            to: isSelected || buttonMouseArea.containsMouse ? hoverScale : 1.0
            duration: buttonRoot.animationDuration
            easing.type: Easing.OutElastic
        }
        ColorAnimation {
            target: buttonBackground
            property: "color"
            to: isSelected || buttonMouseArea.containsMouse ? hoverColor : backgroundColor
            duration: buttonRoot.animationDuration
        }
    }

    transform: Scale {
        origin.x: buttonRoot.width / 2
        origin.y: buttonRoot.height / 2
        xScale: buttonRoot.scaleFactor
        yScale: buttonRoot.scaleFactor
    }

    Rectangle {
        id: buttonBackground
        anchors.fill: parent
        color: backgroundColor
        border.color: borderColor
        border.width: borderWidth
        radius: buttonRoot.radius
        antialiasing: true

        Behavior on color {
            ColorAnimation { duration: buttonRoot.animationDuration }
        }
    }

    Rectangle {
        id: focusRing
        anchors.fill: parent
        anchors.margins: -5
        radius: buttonRoot.radius + 3
        color: "transparent"
        border.color: borderColor
        border.width: 2
        opacity: 0
        scale: 0.8
        visible: showFocusRing && (buttonRoot.activeFocus || isSelected)
        antialiasing: true
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 10

        onWidthChanged: {
            buttonRoot.contentWidth = contentRow.width;
            buttonRoot.width = contentRow.width + leftPadding + rightPadding;
        }

        Item {
            id: iconContainer
            width: iconSource !== "" ? iconSize : 0
            height: iconSize
            visible: iconSource !== ""

            Image {
                id: buttonIcon
                anchors.centerIn: parent
                source: iconSource
                width: parent.width
                height: parent.height
                visible: iconSource !== ""
                fillMode: Image.PreserveAspectFit
                mipmap: true
                onStatusChanged: {
                    if (status == Image.Ready) {
                        widthUpdateTimer.start();
                    }
                }

                onSourceChanged: widthUpdateTimer.start()
            }

            ColorOverlay {
                anchors.fill: buttonIcon
                source: buttonIcon
                color: currentTheme ? currentTheme.iconColor : "white"
                visible: buttonIcon.visible
            }
        }

        Text {
            id: buttonText
            text: dynamicText
            font.pixelSize: Math.min(buttonRoot.height * 0.4, 20)
            font.bold: true
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            maximumLineCount: 1

            onContentWidthChanged: widthUpdateTimer.start()
            onContentHeightChanged: widthUpdateTimer.start()
            onTextChanged: widthUpdateTimer.start()

            layer.enabled: true
            layer.effect: DropShadow {
                color: Qt.rgba(0, 0, 0, 0.5)
                radius: 1
                samples: 2
                spread: 0.2
            }
        }
    }

    MouseArea {
        id: buttonMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            buttonRoot.entered();
            hoverAnimation.start();
        }

        onExited: {
            buttonRoot.exited();
            if (!isSelected) {
                buttonRoot.scaleFactor = 1.0;
                buttonBackground.color = backgroundColor;
            }
        }

        onPressed: {
            buttonRoot.pressed();
            pressAnimation.start();
        }

        onReleased: {
            buttonRoot.released();
            releaseAnimation.start();
        }

        onClicked: {
            buttonRoot.clicked();
        }

        onCanceled: {
            releaseAnimation.start();
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true;
            pressAnimation.start();
        }
    }

    Keys.onReleased: {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true;
            releaseAnimation.start();
            buttonRoot.clicked();
        }
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            focusAnimation.start();
            hoverAnimation.start();
            if (root.focusManager) {
                root.focusManager.logFocus("Button '" + text + "' gained focus");
            }
        } else {
            if (!buttonMouseArea.containsMouse) {
                scaleFactor = 1.0;
                buttonBackground.color = backgroundColor;
            }
        }
    }

    onIsSelectedChanged: {
        if (isSelected) {
            focusAnimation.start();
            hoverAnimation.start();
        } else if (!buttonMouseArea.containsMouse) {
            buttonRoot.scaleFactor = 1.0;
            buttonBackground.color = backgroundColor;
        }
    }

    Component.onCompleted: {
        widthUpdateTimer.start();
    }
}
