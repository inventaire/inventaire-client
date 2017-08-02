module.exports = Marionette.ItemView.extend
  template: require './templates/work_li'
  className: ->
    prefix = @model.get 'prefix'
    "workLi entity-prefix-#{prefix}"

  attributes: ->
    # Used by deduplicate_layout
    'data-uri': @model.get('uri')

  initialize: ->
    @listenTo @model, 'change', @render
    app.execute 'uriLabel:update'

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
    if attrs.extract? then attrs.description = attrs.extract
    return attrs

  # TODO: recover this feature by grabbing entities items with
  # app.request('items:getByEntities'), with a mutualized call for all the 'li'
  counter: ->
  #   count = app.request 'items:count:byEntity', @model.get('uri')
  #   return counter =
  #     count: count
  #     highlight: count > 0

  toggleZoom: ->
    _.invertAttr @ui.cover, 'src', 'data-zoom-toggle'
    @ui.zoomButtons.toggle()
    @$el.toggleClass 'zoom', {duration:500}
