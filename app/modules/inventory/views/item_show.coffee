ItemShowData = require './item_show_data'
EditionsList = require 'modules/entities/views/editions_list'
showAllAuthorsPreviewLists = require 'modules/entities/lib/show_all_authors_preview_lists'

module.exports = Marionette.LayoutView.extend
  id: 'itemShowLayout'
  template: require './templates/item_show'
  regions:
    itemData: '#itemData'
    authors: '.authors'
    scenarists: '.scenarists'
    illustrators: '.illustrators'
    colorists: '.colorists'

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
    @waitForAuthors.then showAllAuthorsPreviewLists.bind(@)

  showItemData: -> @itemData.show new ItemShowData { @model }

  events:
    'click .preciseEdition': 'preciseEdition'

  preciseEdition: ->
    { entity } = @model
    unless entity.type is 'work' then throw new Error('wrong entity type')

    app.layout.modal.show new EditionsList
      collection: entity.editions
      work: entity
      header: 'specify the edition'
      itemToUpdate: @model

    app.execute 'modal:open', 'large'

getAuthorsModels = (works)->
  Promise.all works
  .map (work)-> work.getExtendedAuthorsModels()
  .reduce aggregateAuthorsPerProperty, {}

getSeriePathname = (works)->
  unless works?.length is 1 then return
  work = works[0]
  seriesUris = work.get 'claims.wdt:P179'
  if seriesUris.length is 1
    [ uri, pathname ] = work.gets 'uri', 'pathname'
    # Hacky way to get the serie entity pathname without having to request its model
    return pathname.replace uri, seriesUris[0]

aggregateAuthorsPerProperty = (authorsPerProperty, workAuthors)->
  for property, authors of workAuthors
    authorsPerProperty[property] ?= []
    authorsPerProperty[property].push authors...
  return authorsPerProperty
