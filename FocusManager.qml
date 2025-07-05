import QtQuick 2.15

Item {
    id: focusManager
    property var rootItem
    property var gameGridView
    property var collectionListView
    property var gameInfo
    property var mediaPlayer
    property var gameDetails
    property var settingsImage
    property string currentFocus: "collections"
    property var focusHistory: []
    property bool restoringPosition: false

    function logFocus(message) {
        //console.log("[FocusManager]", message, "- Current focus:", currentFocus);
    }

    function setFocus(target, fromComponent) {
        if (fromComponent === "restore") {
            restoringPosition = true;
        } else if (fromComponent) {
            focusHistory.push(currentFocus);
        }

        switch(target) {
            case "collections":
                if (collectionListView) collectionListView.focus = true;
                if (gameGridView) gameGridView.focus = false;
                if (gameInfo) gameInfo.focus = false;
                if (settingsImage) settingsImage.focus = false;
                currentFocus = "collections";
            break;

            case "games":
                if (collectionListView) collectionListView.focus = false;
                if (gameGridView) gameGridView.focus = true;
                if (gameInfo) gameInfo.focus = false;
                if (settingsImage) settingsImage.focus = false;
                currentFocus = "games";
            break;

            case "settings":
                if (collectionListView) collectionListView.focus = false;
                if (gameGridView) gameGridView.focus = false;
                if (gameInfo) gameInfo.focus = false;
                if (settingsImage) settingsImage.focus = true;
                currentFocus = "settings";
            break;

            case "gameinfo":
                if (collectionListView) collectionListView.focus = false;
                if (gameGridView) gameGridView.focus = false;
                if (gameInfo) gameInfo.focus = true;
                if (settingsImage) settingsImage.focus = false;
                currentFocus = "gameinfo";
            break;

            case "mediaplayer":
                if (collectionListView) collectionListView.focus = false;
                if (gameGridView) gameGridView.focus = false;
                if (gameInfo) gameInfo.focus = false;
                if (mediaPlayer) mediaPlayer.focus = true;
                if (settingsImage) settingsImage.focus = false;
                currentFocus = "mediaplayer";
            break;

            case "gamedetails":
                if (collectionListView) collectionListView.focus = false;
                if (gameGridView) gameGridView.focus = false;
                if (gameInfo) gameInfo.focus = false;
                if (gameDetails) gameDetails.focus = true;
                if (settingsImage) settingsImage.focus = false;
                currentFocus = "gamedetails";
            break;

            case "search":
                if (collectionListView) collectionListView.focus = false;
                if (gameGridView) gameGridView.focus = false;
                if (gameInfo) gameInfo.focus = false;
                if (settingsImage) settingsImage.focus = false;
                currentFocus = "search";
            break;
        }

        if (fromComponent === "restore") {
            restoringPosition = false;
        }

        //logFocus("Focus changed to " + target);
    }

    function returnFocus() {
        if (focusHistory.length > 0 && !restoringPosition) {
            var previousFocus = focusHistory.pop();
            setFocus(previousFocus);
        } else if (!restoringPosition) {
            setFocus("collections");
        }
    }

    function resetFocus() {
        if (!restoringPosition) {
            focusHistory = [];
            setFocus("collections");
        }
    }
}
