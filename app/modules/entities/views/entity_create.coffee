module.exports = class EntityCreate extends Backbone.Marionette.ItemView
  template: require './templates/entity_create'
  className: 'entityCreate'
  events:
    'click #addToInventory, #inventorying': 'inventorying'
    'click #giving': 'giving'
    'click #lending': 'lending'
    'click #selling': 'selling'

  ui:
    title: '#title'
    author: '#author'
    isbn: '#isbn'

  onShow: -> @suggestQueryAsTitle()

  suggestQueryAsTitle: ->
    {data} = @options
    @ui.title.val data

  giving: -> @showItemCreation 'giving'
  lending: -> @showItemCreation 'lending'
  selling: -> @showItemCreation 'selling'
  inventorying: -> @showItemCreation 'inventorying'

  showItemCreation: (transaction)->
    @createEntity()
    .then (entityModel)->
      params =
        entity: entityModel
        transaction: transaction
      _.log params, 'item:creation:params'
      app.execute 'show:item:creation:form', params
    .catch (err)-> _.log err, 'showItemCreation err'

  createEntity: ->
    entityData = @getEntityFormData()
    return app.request 'create:entity', entityData

  getEntityFormData: ->
    entity =
      title: @ui.title.val()
      authors: [@ui.author.val()]
      isbn: @ui.isbn.val()
    return _.log entity, 'entity?'
