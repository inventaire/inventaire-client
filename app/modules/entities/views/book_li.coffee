mainUserInstance = require '../plugins/main_user_has_one'
plainTextAuthorLink = require '../plugins/plain_text_author_link'

module.exports = Marionette.ItemView.extend
  template: require './templates/book_li'
  tagName: 'li'
  className: 'bookLi'

  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @model, 'add:pictures', @render
    app.request 'qLabel:update'
    @initPlugins()

  initPlugins: ->
    mainUserInstance.call @
    plainTextAuthorLink.call @

  behaviors:
    PreventDefault: {}

  ui:
    zoomButtons: '.zoom-button .buttons span'
    cover: 'img'

  events:
    'click a.addToInventory': 'showItemCreationForm'
    'click a.zoom-button': 'toggleZoom'

  showItemCreationForm: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:item:creation:form', {entity: @model}

  serializeData: ->
    attrs = _.extend @model.toJSON(),
      counter: @counter()
      mainUserHasOne: @mainUserHasOne()
    if attrs.extract? then attrs.description = attrs.extract
    return attrs

  counter: ->
    count = app.request 'items:count:byEntity', @model.get('uri')
    return counter =
      count: count
      highlight: count > 0

  toggleZoom: ->
    _.invertAttr @ui.cover, 'src', 'data-zoom-toggle'
    @ui.zoomButtons.toggle()
    @$el.toggleClass 'zoom', {duration:500}
