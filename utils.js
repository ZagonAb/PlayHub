function calculateLastPlayedText(lastPlayed) {
    if (!lastPlayed) {
        return "Never"
    }
    let date = new Date(lastPlayed)
    if (isNaN(date.getTime())) {
        return "Never"
    }
    let now = new Date()
    let today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    let yesterday = new Date(today.getTime() - (1000 * 60 * 60 * 24))
    if (date >= today) {
        return "Today"
    } else if (date >= yesterday) {
        return "Yesterday"
    } else {
        return date.toLocaleDateString("en-GB")
    }
}

function calculatePlayTimeText(playTime, includePrefix) {
    let seconds = playTime || 0;
    let totalMinutes = Math.floor(seconds / 60);
    let hours = Math.floor(totalMinutes / 60);
    let minutes = totalMinutes % 60;

    if (hours > 0) {
        return hours + "." + (minutes < 10 ? "0" : "") + Math.floor(minutes/6) + " hours";
    } else {
        return totalMinutes + " minutes";
    }
}

function getNameCollecForGame(game, api) {
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

Qt.include.exports = {
    calculateLastPlayedText,
    calculatePlayTimeText,
    getNameCollecForGame
}
