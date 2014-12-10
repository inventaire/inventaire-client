module.exports = class ResultsList extends Backbone.Marionette.CollectionView
  getChildView: ->
    switch @options.type
      when 'books' then require './book_li'
      when 'authors' then require './author_li'
      else _.log @options, 'no result type provided: cant choose getChildView'
  emptyView: require 'modules/inventory/views/no_item'
  tagName: 'ul'
  className: 'jk'
  onShow: ->
    @addHeader()

  addHeader: (type)->
    type or= @options.type
    if type?
      type = _.i18n(type)
      @$el.prepend "<h3 class='subheader'>#{type}</h3>"