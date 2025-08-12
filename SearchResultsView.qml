import QtQuick 2.15
import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.12

ListView {
    id: searchResultsView
    width: parent.width
    height: parent.height
    clip: true
    focus: true
    orientation: ListView.Horizontal
    spacing: 15

    property string filter: ""
    property int visibleItemCount: 3
    property var root: parent
    property bool showRandomGames: filter === ""
    property var randomGameIndices: []
    property bool useRandomModel: filter === ""
    property bool mouseNavigationEnabled: true
    property var currentTheme: parent.currentTheme || root.currentTheme

    snapMode: ListView.NoSnap
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 80
    keyNavigationWraps: false

    SortFilterProxyModel {
        id: randomModel
        sourceModel: api.allGames
        filters: [
            ExpressionFilter {
                expression: searchResultsView.randomGameIndices.includes(index)
            }
        ]
    }

    SortFilterProxyModel {
        id: searchModel
        sourceModel: api.allGames
        filters: ExpressionFilter {
            property string searchText: ""
            expression: {
                if (searchText === "") return false;
                var regex = new RegExp("^" + searchText, "i");
                return regex.test(String(model.title));
            }
        }
        sorters: RoleSorter {
            roleName: "title"
            sortOrder: Qt.AscendingOrder
        }
    }

    model: useRandomModel ? randomModel : searchModel

    onFilterChanged: {
        var wasEmpty = useRandomModel;
        var isEmpty = (filter === "");

        if (wasEmpty !== isEmpty) {
            useRandomModel = isEmpty;
            currentIndex = -1;

            if (isEmpty) {
                selectRandomIndices();
            }
        }

        searchModel.filters[0].searchText = filter.toLowerCase();
    }

    function selectRandomIndices() {
        var indices = [];
        var count = Math.min(10, api.allGames.count);

        if (api.allGames.count <= 10) {
            for (var i = 0; i < api.allGames.count; i++) {
                indices.push(i);
            }
            randomGameIndices = indices;
            return;
        }

        while (indices.length < count) {
            var randomIndex = Math.floor(Math.random() * api.allGames.count);
            if (!indices.includes(randomIndex)) {
                indices.push(randomIndex);
            }
        }
        randomGameIndices = indices;
    }

    function resetRandomGames() {
        selectRandomIndices();
        useRandomModel = true;
        currentIndex = -1;
    }

    Component.onCompleted: {
        selectRandomIndices();
    }

    delegate: Item {
        width: searchResultsView.width / visibleItemCount - spacing
        height: searchResultsView.height
        property bool isCurrentItem: ListView.isCurrentItem && searchResultsView.activeFocus
        scale: isCurrentItem ? 1.05 : 1.0
        opacity: isCurrentItem ? 1.0 : 0.9
        z: isCurrentItem ? 1 : 0

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 5
            color: "transparent"
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                Rectangle {
                    width: parent.width
                    height: parent.height - 60
                    color: "transparent"
                    border.color: isCurrentItem ? "#4d99e6" : (currentTheme ? currentTheme.bordercolor : "#c0c0c0")
                    border.width: isCurrentItem ? 2 : 0
                    radius: 15

                    Item {
                        width: parent.width
                        height: parent.height

                        Image {
                            id: screenImage
                            anchors.fill: parent
                            anchors.margins: 5
                            source: model.assets.screenshot || "assets/.no-image/no_screenshot.png"
                            fillMode: Image.Stretch
                            mipmap: true
                            asynchronous: true
                            cache: true
                            visible: false
                        }

                        Image {
                            id: noScreenshotImage
                            anchors.fill: parent
                            anchors.margins: 5
                            source: "assets/.no-image/no_screenshot.png"
                            fillMode: Image.Stretch
                            mipmap: true
                            asynchronous: true
                            cache: true
                            visible: false
                        }

                        Rectangle {
                            id: roundedMask
                            width: screenImage.width
                            height: screenImage.height
                            anchors.centerIn: parent
                            radius: 15
                            visible: false
                        }

                        OpacityMask {
                            id: maskedScreenshot
                            width: screenImage.width
                            height: screenImage.height
                            anchors.centerIn: parent
                            source: screenImage
                            maskSource: roundedMask
                            visible: screenImage.status === Image.Ready && screenImage.source.toString() !== ""
                        }

                        OpacityMask {
                            id: maskedNoScreenshot
                            width: noScreenshotImage.width
                            height: noScreenshotImage.height
                            anchors.centerIn: parent
                            source: noScreenshotImage
                            maskSource: roundedMask
                            visible: (screenImage.status === Image.Ready && screenImage.source.toString() === "") ||
                            (screenImage.status === Image.Error)
                        }

                        Item {
                            id: logoContainer
                            anchors {
                                bottom: parent.bottom
                                bottomMargin: 15
                                horizontalCenter: parent.horizontalCenter
                            }
                            width: parent.width * 0.7
                            height: width * 0.25

                            property real targetScale: isCurrentItem ? 1.1 : 1.0
                            property real targetOpacity: isCurrentItem ? 1.0 : 0.8
                            property real glowRadius: isCurrentItem ? 8 : 0

                            transform: Scale {
                                origin.x: logoContainer.width / 2
                                origin.y: logoContainer.height / 2
                                xScale: logoContainer.targetScale
                                yScale: logoContainer.targetScale
                            }

                            Image {
                                id: logoImage
                                anchors.centerIn: parent
                                width: parent.width
                                height: parent.height
                                source: model.assets.logo || ""
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                                asynchronous: true
                                cache: true
                                visible: status === Image.Ready && source.toString() !== ""
                                opacity: logoContainer.targetOpacity

                                layer.enabled: true
                                layer.effect: Glow {
                                    id: logoGlow
                                    radius: logoContainer.glowRadius * 0.5
                                    samples: 16
                                    color: Qt.rgba(1, 1, 1, 0.7)
                                    spread: 0.3
                                    transparentBorder: true
                                }
                            }

                            Behavior on targetScale {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }

                            Behavior on targetOpacity {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }

                            Behavior on glowRadius {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    padding: 5

                    Text {
                        text: model.title
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        color: isCurrentItem ? "#ffffff" : "#cccccc"
                        maximumLineCount: 1
                        Behavior on color {
                            ColorAnimation {
                                duration: 60
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    Text {
                        text: {
                            if (model.collections && model.collections.count > 0) {
                                return model.collections.get(0).name
                            }
                            return "Unknown Collection"
                        }
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        color: isCurrentItem ? "#dddddd" : "#aaaaaa"
                        maximumLineCount: 1
                        Behavior on color {
                            ColorAnimation {
                                duration: 60
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (mouseNavigationEnabled) {
                    searchResultsView.currentIndex = index;
                    searchResultsView.forceActiveFocus();
                    if (typeof keyboard !== 'undefined') {
                        keyboard.resetKeyboard();
                    }
                    if (typeof soundEffects !== 'undefined') soundEffects.play("navi");
                }
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: 100
        color: "transparent"
        visible: model.count === 0 && filter !== ""

        Text {
            anchors.centerIn: parent
            text: "No results were found for: " + filter
            font.pixelSize: 18
            color: "#aaaaaa"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Keys.onPressed: {
        if (!event.isAutoRepeat) {
            if (api.keys.isAccept(event)) {
                event.accepted = true;
                soundEffects.play("launch");
                if (model && currentIndex >= 0) {
                    var game = model.get(currentIndex);
                    searchOverlayLoader.parent.game = game;
                    searchOverlayLoader.parent.launchTimer.start();
                }
            }
            else if (api.keys.isCancel(event)) {
                event.accepted = true
                if (model.count > 0 && currentIndex >= 0) {
                    var game = model.get(currentIndex)
                }

                if (typeof keyboard !== 'undefined') {
                    keyboard.forceActiveFocus()
                    if (typeof soundEffects !== 'undefined') soundEffects.play("go")
                }
            }
            else if (event.key === Qt.Key_Left) {
                if (currentIndex > 0) {
                    decrementCurrentIndex()
                    if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                }
                event.accepted = true
            }
            else if (event.key === Qt.Key_Right) {
                if (currentIndex < count - 1) {
                    incrementCurrentIndex()
                    if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                }
                event.accepted = true
            }
            else if (event.key === Qt.Key_Up) {
                if (typeof keyboard !== 'undefined') {
                    keyboard.forceActiveFocus()
                    if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                }
                event.accepted = true
            }
            else if (event.key === Qt.Key_Down) {
                if (currentIndex < count - 1) {
                    incrementCurrentIndex()
                    if (typeof soundEffects !== 'undefined') soundEffects.play("navi")
                }
                event.accepted = true
            }
        }
    }
}
