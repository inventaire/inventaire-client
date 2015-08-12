BookLi = require 'modules/entities/views/book_li'
AuthorLi = require 'modules/entities/views/author_li'

module.exports = Marionette.CompositeView.extend
  template: require './templates/results_list'
  childViewContainer: '.resultsList'
  getChildView: ->
    switch @options.type
      when 'books' then BookLi
      when 'editions' then BookLi
      when 'authors' then AuthorLi
      else throw new Error 'unvalid type provided: cant choose getChildView'
  emptyView: require 'modules/inventory/views/no_item'

  serializeData: ->
    type: _.i18n @options.type

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
