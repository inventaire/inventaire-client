module.exports = Marionette.CollectionView.extend
  className: 'inner-merge-suggestions'
  childView: require './merge_suggestion'
  childViewOptions: ->
    toEntity: @options.toEntity
