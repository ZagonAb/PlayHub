import QtQuick 2.15
import SortFilterProxyModel 0.2

Item {
    id: gamesGridModel
    property var currentTheme
    property var rootItem: null

    function getCurrentModel() {
        return gameGridView.model
    }

    function toggleFavorite(game) {
        if (!game) return

            var collectionName = getNameCollecForGame(game)
            for (var i = 0; i < api.collections.count; ++i) {
                var collection = api.collections.get(i)
                if (collection.name === collectionName) {
                    for (var j = 0; j < collection.games.count; ++j) {
                        var currentGame = collection.games.get(j)
                        if (currentGame.title === game.title) {
                            currentGame.favorite = !currentGame.favorite
                            if (rootItem && rootItem.favSound) rootItem.favSound.play()
                                return
                        }
                    }
                    break
                }
            }
    }

    function getNameCollecForGame(game) {
        if (game && game.collections && game.collections.count > 0) {
            var firstCollection = game.collections.get(0)
            for (var i = 0; i < api.collections.count; ++i) {
                var collection = api.collections.get(i)
                if (collection.name === firstCollection.name) {
                    return collection.name
                }
            }
        }
        return "default"
    }
}
