module.exports = Marionette.CollectionView.extend
  className: 'inner-merge-suggestions'
  childView: require './merge_suggestion'
  childViewOptions: ->
    fromEntity: _.log @options.fromEntity, 'fromEntity @ bla'
