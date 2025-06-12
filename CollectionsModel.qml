import QtQuick 2.15
import SortFilterProxyModel 0.2

Item {
    id: collectionsItem
    property alias favoritesModel: favoritesProxyModel

    ListModel {
        id: collectionsModel
        property int favoritesIndex: -1
        property int historyIndex: -1
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

    function getModel() {
        return collectionsModel;
    }
}
