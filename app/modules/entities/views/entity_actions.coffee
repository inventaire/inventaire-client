module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/entity_actions'
  className: 'entityActions'
  events:
    'click #addToInventory, #inventorying': 'inventorying'
    'click #giving': 'giving'
    'click #lending': 'lending'
    'click #selling': 'selling'

  giving: -> @showItemCreation 'giving'
  lending: -> @showItemCreation 'lending'
  selling: -> @showItemCreation 'selling'
  inventorying: -> @showItemCreation 'inventorying'

  showItemCreation: (transaction)->
    params =
      entity: @model
      transaction: transaction
    _.log params, 'item:creation:params'
    app.execute 'show:item:creation:form', params
