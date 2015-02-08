BookLi = require 'modules/entities/views/book_li'
AuthorLi = require 'modules/entities/views/author_li'

module.exports = class ResultsList extends Backbone.Marionette.CompositeView
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
    return _.log attrs =
      type: _.i18n @options.type