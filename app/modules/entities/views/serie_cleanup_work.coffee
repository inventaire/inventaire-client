getActionKey = require 'lib/get_action_key'

module.exports = Marionette.CompositeView.extend
  tagName: 'li'
  attributes:
    tabindex: '0'

  template: require './templates/serie_cleanup_work'
  className: ->
    classes = 'serie-cleanup-work'
    if @model.get('isPlaceholder') then classes += ' placeholder'
    return classes

  childViewContainer: '.editionsContainer'
  childView: require './serie_cleanup_edition'

  childViewOptions: ->
    getWorksWithOrdinalList: @options.getWorksWithOrdinalList

  # Filter-out composite editions as it would be a mess to handle the work picker
  # with several existing work claims
  filter: (child)-> child.get('claims.wdt:P629')?.length is 1

  ui:
    head: '.head'
    placeholderEditor: '.placeholderEditor'
    placeholderLabelEditor: '.placeholderEditor input'

  initialize: ->
    @collection = @model.editions

  serializeData: ->
    _.extend @model.toJSON(),
      possibleOrdinals: @options.possibleOrdinals

  events:
    'change .ordinalSelector': 'updateOrdinal'
    'click .create': 'create'
    'click': 'showPlaceholderEditor'
    'keydown': 'onKeydown'

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
    setTimeout _.focusInput.bind(null, @ui.placeholderLabelEditor), 100

  hidePlaceholderEditor: ->
    @ui.head.removeClass 'force-hidden'
    @ui.placeholderEditor.addClass 'hidden'
    @$el.attr 'tabindex', 0
    @$el.focus()

  create: ->
    label = @ui.placeholderLabelEditor.val()
    @model.setLabel app.user.lang, label
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
