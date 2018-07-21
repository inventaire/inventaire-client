module.exports = Marionette.CompositeView.extend
  className: 'serie-cleanup-works'
  template: require './templates/serie_cleanup_works'
  childViewContainer: '.worksContainer'
  childView: require './serie_cleanup_work'
  serializeData: ->
    sectionLabel: @options.label

  filter: (child)->
    if @options.name isnt 'withOrdinal' then return true
    ordinal = child.get 'ordinal'
    return ordinal? and ordinal isnt 0

  childViewOptions: ->
    possibleOrdinals: @options.possibleOrdinals
    getWorksWithOrdinalList: @options.getWorksWithOrdinalList
