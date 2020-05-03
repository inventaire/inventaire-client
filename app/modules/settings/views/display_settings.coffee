module.exports = Marionette.ItemView.extend
  template: require './templates/display_settings'
  className: 'displaySettings'
  initialize: ->
    @lazyRender = _.LazyRender @
    @entitiesDisplay = localStorageProxy.getItem('entitiesDisplay') or 'entitiesCascade'
    @inventoryDisplay = localStorageProxy.getItem('inventoryDisplay') or 'inventoryCascade'

  serializeData: ->
    data = {}
    data[@entitiesDisplay] = true
    data[@inventoryDisplay] = true
    return data

  events:
    'click #entitiesDisplayOptions li': 'selectDisplay'
    'click #inventoryDisplayOptions li': 'selectDisplay'

  selectDisplay: (e)->
    newDisplay = e.currentTarget.id
    type = e.currentTarget.attributes['displayType'].value
    @[type] = newDisplay
    @lazyRender()
    localStorageProxy.setItem type, newDisplay
    localStorageProxy.setItem 'entities:display', newDisplay
