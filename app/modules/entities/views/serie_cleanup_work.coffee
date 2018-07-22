getActionKey = require 'lib/get_action_key'
getLangsData = require 'modules/entities/lib/editor/get_langs_data'

module.exports = Marionette.CompositeView.extend
  tagName: 'li'
  template: require './templates/serie_cleanup_work'
  className: ->
    classes = 'serie-cleanup-work'
    if @model.get('isPlaceholder') then classes += ' placeholder'
    return classes

  childViewContainer: '.editionsContainer'
  childView: require './serie_cleanup_edition'

  childViewOptions: ->
    getWorksWithOrdinalList: @options.getWorksWithOrdinalList
    worksWithOrdinal: @options.worksWithOrdinal

  # Keeping a consistent sorting function so that rolling back an edition
  # puts it back at the same spot
  viewComparator: 'label'

  # Filter-out composite editions as it would be a mess to handle the work picker
  # with several existing work claims
  filter: (child)-> child.get('claims.wdt:P629')?.length is 1

  ui:
    head: '.head'
    placeholderEditor: '.placeholderEditor'
    placeholderLabelEditor: '.placeholderEditor input'
    langSelector: '.langSelector'

  initialize: ->
    @collection = @model.editions
    lazyLangSelectorUpdate = _.debounce @onOtherLangSelectorChange.bind(@), 500
    @listenTo app.vent, 'lang:local:change', lazyLangSelectorUpdate

  serializeData: ->
    lang = app.request 'lang:local:get'
    _.extend @model.toJSON(),
      possibleOrdinals: @options.possibleOrdinals
      langs: getLangsData lang, @model.get('labels')

  onRender: ->
    if @model.get('isPlaceholder') then @$el.attr 'tabindex', 0

  events:
    'change .ordinalSelector': 'updateOrdinal'
    'click .create': 'create'
    'click': 'showPlaceholderEditor'
    'keydown': 'onKeydown'
    'change .langSelector': 'propagateLangChange'

  updateOrdinal: (e)->
    { value } = e.currentTarget
    @model.setPropertyValue 'wdt:P1545', null, value

  showPlaceholderEditor: ->
    unless @model.get('isPlaceholder') then return
    unless @ui.placeholderEditor.hasClass 'hidden' then return
    @ui.head.addClass 'force-hidden'
    @ui.placeholderEditor.removeClass 'hidden'
    @$el.attr 'tabindex', null
    # Wait to avoid the enter event to be propagated as an enterClick to 'create'
    @setTimeout _.focusInput.bind(null, @ui.placeholderLabelEditor), 100

  hidePlaceholderEditor: ->
    @ui.head.removeClass 'force-hidden'
    @ui.placeholderEditor.addClass 'hidden'
    @$el.attr 'tabindex', 0
    @$el.focus()

  create: ->
    unless @model.get('isPlaceholder') then return
    lang = @ui.langSelector.val()
    label = @ui.placeholderLabelEditor.val()
    @model.setLabel lang, label
    @model.create()
    .then @replaceModel.bind(@)

  replaceModel: (newModel)->
    newModel.set 'ordinal', @model.get('ordinal')
    @model.collection.add newModel
    @model.collection.remove @model

  onKeydown: (e)->
    key = getActionKey e
    switch key
      when 'enter' then @showPlaceholderEditor()
      when 'esc' then @hidePlaceholderEditor()

  propagateLangChange: (e)->
    { value } = e.currentTarget
    app.vent.trigger 'lang:local:change', value

  onOtherLangSelectorChange: (value)->
    if @ui.placeholderEditor.hasClass 'hidden' then @ui.langSelector.val value
