module.exports = Marionette.ItemView.extend
  template: require './templates/entity_data'
  className: 'entityData'
  initialize: (options)->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender

    @hidePicture = options.hidePicture
    unless @hidePicture
      @listenTo @model, 'add:pictures', @lazyRender

  serializeData: ->
    attrs = @model.toJSON()
    attrs = @setDescriptionAttributes(attrs)
    attrs.entityPage = @options.entityPage
    attrs.hidePicture = @hidePicture
    return attrs

  ui:
    description: '.description'
    togglers: '.toggler i'

  behaviors:
    PreventDefault: {}
    PlainTextAuthorLink: {}

  onRender: ->
    app.execute 'uriLabel:update'

  events:
    'click .toggler': 'toggleDescLength'
    'click .editEntityData': 'showEntityEdit'

  toggleDescLength: ->
    @ui.description.toggleClass 'clamped'
    @ui.togglers.toggleClass 'hidden'

  setDescriptionAttributes: (attrs)->
    if attrs.extract? then attrs.description = attrs.extract
    if attrs.description?
      attrs.descOverflow = attrs.description.length > 400

    return attrs

  showEntityEdit: ->
    # If it's a Wikidata entity, clicking on .editEntityData shouldn't be
    # preventDefaulted and should open the entity page in Wikidata
    if @model.prefix isnt 'wd'
      app.execute 'show:entity:edit:from:model', @model
