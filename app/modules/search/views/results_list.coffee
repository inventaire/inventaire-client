workLi = require 'modules/entities/views/work_li'
AuthorLayout = require 'modules/entities/views/author_layout'
SerieLayout = require 'modules/entities/views/serie_layout'

module.exports = Marionette.CompositeView.extend
  template: require './templates/results_list'
  childViewContainer: '.resultsList'
  getChildView: ->
    { type } = @options
    switch type
      when 'authors' then AuthorLayout
      when 'series' then SerieLayout
      when 'works', 'editions' then workLi
      else throw new Error "unvalid type provided #{type}: cant choose getChildView"

  emptyView: require 'modules/inventory/views/no_item'

  serializeData: ->
    type: @options.type

  collectionEvents:
    'add': 'hideIfEmpty'

  onShow: -> @hideIfEmpty()

  hideIfEmpty: ->
    if @options.hideIfEmpty
      if @collection.length is 0
        @$el.addClass 'hidden'
        @_hidden = true
      else if @_hidden
        @$el.removeClass 'hidden'
        @_hidden = false

  childViewOptions:
    standalone: false
