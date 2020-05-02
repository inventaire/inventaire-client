module.exports = Marionette.ItemView.extend
  template: require './templates/display_settings'
  className: 'displaySettings'
  initialize: ->
    @lazyRender = _.LazyRender @
<<<<<<< HEAD
    @entitiesDisplay = localStorageProxy.getItem('entitiesDisplay') or 'entitiesCascade'
    @inventoryDisplay = localStorageProxy.getItem('inventoryDisplay') or 'inventoryCascade'
=======
    @entitiesDisplay = localStorageProxy.getItem('entities:display') or 'cascade'
>>>>>>> 0fe5a5f6... add a display tab setting

  serializeData: ->
    data = {}
    data[@entitiesDisplay] = true
<<<<<<< HEAD
    data[@inventoryDisplay] = true
=======
>>>>>>> 0fe5a5f6... add a display tab setting
    return data

  events:
    'click #entitiesDisplayOptions li': 'selectDisplay'
<<<<<<< HEAD
    'click #inventoryDisplayOptions li': 'selectDisplay'
=======
>>>>>>> 0fe5a5f6... add a display tab setting

  selectDisplay: (e)->
    newDisplay = e.currentTarget.id
    type = e.currentTarget.attributes['displayType'].value
<<<<<<< HEAD
    @[type] = newDisplay
    @lazyRender()
    localStorageProxy.setItem type, newDisplay
=======
    if newDisplay is @[type] then return
    @[type] = newDisplay
    @lazyRender()
    localStorageProxy.setItem 'entities:display', newDisplay
>>>>>>> 0fe5a5f6... add a display tab setting
