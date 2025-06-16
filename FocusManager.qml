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

    function logFocus(message) {
        //console.log("[FocusManager]", message, "- Current focus:", currentFocus);
    }

    function setFocus(target, fromComponent) {
        if (fromComponent) {
            focusHistory.push(currentFocus);
            // logFocus("Focus change requested from " + fromComponent);
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

        //logFocus("Focus changed to " + target);
    }

    function returnFocus() {
        if (focusHistory.length > 0) {
            var previousFocus = focusHistory.pop();
            setFocus(previousFocus);
            //logFocus("Returned to previous focus: " + previousFocus);
        } else {
            setFocus("collections");
            //logFocus("No focus history, defaulting to collections");
        }
    }

    function resetFocus() {
        focusHistory = [];
        setFocus("collections");
        //logFocus("Focus reset to initial state");
    }
}
