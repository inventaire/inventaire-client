# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collectionview.coffee

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  className: 'ac-suggestions hidden'
  emptyView: require './no_suggestion'
