ItemShowData = require './item_show_data'
AuthorsPreviewList = require 'modules/entities/views/authors_preview_list'

module.exports = Marionette.LayoutView.extend
  id: 'itemShowLayout'
  template: require './templates/item_show'
  regions:
    itemData: '#itemData'
    authors: '.authors'

  behaviors:
    General: {}
    PreventDefault: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @waitForEntity = @model.grabEntity()
    @waitForAuthors = @model.work.getAuthorsModels()

    @listenTo @model, 'grab', @lazyRender

  serializeData: ->
    attrs = @model.serializeData()
    attrs.work = @model.work.toJSON()
    attrs.seriePathname = getSeriePathname @model.work
    return attrs

  onShow: ->
    app.execute 'modal:open', 'large'

  onRender: ->
    @showItemData()
    @waitForAuthors.then @showAuthorsPreviewList.bind(@)

  showItemData: -> @itemData.show new ItemShowData { @model }
  showAuthorsPreviewList: (authors)->
    if authors.length is 0 then return

    collection = new Backbone.Collection authors
    @authors.show new AuthorsPreviewList { collection }

  # TODO: allow to precise which edition of a work an item refers to

getSeriePathname = (work)->
  [ uri, pathname, serieUri ] = work.gets 'uri', 'pathname', 'claims.wdt:P179.0'
  unless serieUri? then return
  # Hacky way to get the serie entity pathname without having to request its model
  return pathname.replace uri, serieUri
