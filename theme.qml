import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.15

FocusScope {
    id: root
    focus: true

    property string currentTime: Qt.formatDateTime(new Date(), "dd-MM HH:mm")

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
        color: "#f5f5f5"

        ListView {
            id: collectionListView
            width: parent.width * 0.98
            height: 60
            model: collectionsModel
            orientation: Qt.Horizontal
            spacing: 5
            clip: true
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            property string currentShortName: ""
            property int indexToPosition: -1

            delegate: Rectangle {
                width: 120
                height: 40
                color: index === collectionListView.currentIndex && collectionListView.focus ? "black" : "white"
                border.color: "black"
                border.width: 4
                radius: 10
                Text {
                    anchors.centerIn: parent
                    text: model.shortName.toUpperCase()
                    color: index === collectionListView.currentIndex && collectionListView.focus ? "white" : "black"
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

            Keys.onRightPressed: {             
                if (collectionListView.currentIndex < collectionListView.count - 1) {
                    collectionListView.currentIndex += 1;
                    naviSound.play();
                }
            }

            Keys.onLeftPressed: {
                if (collectionListView.currentIndex > 0) {                    
                    collectionListView.currentIndex -= 1;
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

        GridView {
            id: gameGridView
            model: api.collections.get(0).games
            property int indexToPosition: -1
            anchors {
                top: collectionListView.bottom
                topMargin: 20
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            width: parent.width * 0.8
            cellWidth: conteiner.parent.width / 5
            cellHeight: conteiner.parent.height / 2.5
            keyNavigationEnabled: true
            keyNavigationWraps: true
            clip: true

            delegate: Rectangle {
                property bool isSelected: GridView.isCurrentItem

                width: gameGridView.cellWidth
                height: gameGridView.cellHeight
                radius: 20
                border.color: "#e0e0e0"
                border.width: 2
                color: isSelected && gameGridView.focus ? "black" : "white"
                Item {
                    width: parent.width
                    height: parent.height


                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
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
                            width: parent.width
                            height: 40
                            text: model.title
                            color: isSelected && gameGridView.focus ? "white" : "black"
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
        color: "white"
        anchors.top: conteiner.bottom
        height: parent.height * 0.08
        width: parent.width
        property var selectedGame: null
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            spacing: 20

            Row {
                spacing: 5
                visible: !collectionListView.activeFocus
                Image {
                    source: "assets/control/favorite.png"
                    width: 36
                    height:36 
                    anchors.verticalCenter: parent.verticalCenter
                    mipmap: true
                }

                Text {
                    text: " FAVORITE"
                    color: "black"
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                visible: !collectionListView.activeFocus
                Image {
                    source: "assets/control/ok.png"
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter
                    mipmap: true
                }

                Text {
                    text: " LAUNCH"
                    color: "black"
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 100
                }
                Rectangle {
                    width: 5 
                    height: 1
                    color: "transparent"
                }
            }

            Row {
                spacing: 5
                visible: collectionListView.activeFocus
                Image {
                    source: "assets/control/down.png"
                    width: 36
                    height:36 
                    anchors.verticalCenter: parent.verticalCenter
                    mipmap: true
                }

                Text {
                    text: " GAMES"
                    color: "black"
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                visible: collectionListView.activeFocus
                Image {
                    source: "assets/control/prev.png"
                    width: 36
                    height:36 
                    anchors.verticalCenter: parent.verticalCenter
                    mipmap: true
                }

                Text {
                    text: "PREV COLLECTION"
                    color: "black"
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5
                visible: collectionListView.activeFocus
                Image {
                    source: "assets/control/next.png"
                    width: 36
                    height:36 
                    anchors.verticalCenter: parent.verticalCenter
                    mipmap: true
                }

                Text {
                    text: "NEXT COLLECTION"
                    color: "black"
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 5 
                Image {
                    source: "assets/control/back.png"
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter
                    mipmap: true
                }

                Text {
                    text: " BACK"
                    color: "black"
                    font.bold: true
                    font.pixelSize: Math.min(bottomBar.height / 4, bottomBar.width / 40)
                    anchors.verticalCenter: parent.verticalCenter
                }
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
                    color: "black"
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
                    color: "black"
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
                    color: "black"
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
                    color: "black"
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
