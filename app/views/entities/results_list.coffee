module.exports = class ResultsList extends Backbone.Marionette.CollectionView
  getChildView: ->
    switch @options.type
      when 'books' then require 'views/entities/book_li'
      when 'authors' then require 'views/entities/author_li'
      else _.log @options, 'no result type provided'
  emptyView: require 'views/items/no_item'
  tagName: 'ul'
  onShow: ->
    @options.type.label 'results list type'
    @options.entity.label 'could use this entity label instead'
    type = _.i18n(@options.type)
    @$el.prepend "<h3 class='subheader'>#{type}</h3>"