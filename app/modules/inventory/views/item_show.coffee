ItemShowData = require './item_show_data'
AuthorsPreviewList = require 'modules/entities/views/authors_preview_list'
EditionsList = require 'modules/entities/views/editions_list'

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
    @waitForAuthors = @model.waitForWorks.then getAuthorsModels

    @listenTo @model, 'grab', @lazyRender

  serializeData: ->
    attrs = @model.serializeData()
    attrs.works = @model.works?.map (work)-> work.toJSON()
    attrs.seriePathname = getSeriePathname @model.works
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

  events:
    'click .preciseEdition': 'preciseEdition'

  preciseEdition: ->
    { entity } = @model
    unless entity.type is 'work' then throw new Error('wrong entity type')

    app.layout.modal.show new EditionsList
      collection: entity.editions
      work: entity
      header: 'precise the edition'
      itemToUpdate: @model

    app.execute 'modal:open', 'large'

getAuthorsModels = (works)->
  authorsUris = _.chain works
    .map (work)-> work.get('claims.wdt:P50') or []
    .flatten()
    .uniq()
    .value()

  return app.request 'get:entities:models', { uris: authorsUris }

getSeriePathname = (works)->
  unless works? then return
  serieUris = works.map getWorkSerieUri
  if _.compact(serieUris).length is works.length and _.uniq(serieUris) is 1
    [ uri, pathame ] = works[0].gets 'uri', 'pathname'
    # Hacky way to get the serie entity pathname without having to request its model
    return pathname.replace uri, serieUris[0]

getWorkSerieUri = (work)-> work.get 'claims.wdt:P179.0'
