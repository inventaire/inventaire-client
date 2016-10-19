BookLi = require 'modules/entities/views/book_li'
AuthorLayout = require 'modules/entities/views/author_layout'

module.exports = Marionette.CompositeView.extend
  template: require './templates/results_list'
  childViewContainer: '.resultsList'
  getChildView: ->
    switch @options.type
      when 'authors' then AuthorLayout
      when 'books', 'editions' then BookLi
      else throw new Error 'unvalid type provided: cant choose getChildView'
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
