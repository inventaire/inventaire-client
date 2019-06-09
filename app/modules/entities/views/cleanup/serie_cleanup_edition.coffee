getActionKey = require 'lib/get_action_key'

module.exports = Marionette.CompositeView.extend
  tagName: 'li'
  className: 'serie-cleanup-edition'
  template: require './templates/serie_cleanup_edition'

  ui:
    workPickerSelect: '.workPickerSelect'
    workPickerValidate: '.validate'

  initialize: ->
    { @worksWithOrdinal } = @options
    @lazyRender = _.LazyRender @, 100
    @editionLang = @model.get 'lang'
    @workUri = @model.get 'claims.wdt:P629.0'
    @getWorksLabel()
    @_showWorkPicker = false

  serializeData: ->
    _.extend @model.toJSON(),
      workLabel: @workLabel
      worksList: if @_showWorkPicker then @getWorksList()

  events:
    'click .changeWork': 'showWorkPicker'
    'change .workPickerSelect': 'onSelectChange'
    'click .validate': 'validateWorkChange'
    'keydown .workPickerSelect': 'onKeyDown'
    'click .copyWorkLabel': 'copyWorkLabel'

  getWorksList: ->
    nonPlaceholderWorksWithOrdinal = @worksWithOrdinal.serializeNonPlaceholderWorks()
    unless nonPlaceholderWorksWithOrdinal? then return
    return nonPlaceholderWorksWithOrdinal.filter (work)=> work.uri isnt @workUri

  onKeyDown: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @hideWorkPicker()
      when 'enter' then @validateWorkChange()

  showWorkPicker: ->
    @_showWorkPicker = true
    @lazyRender()

  hideWorkPicker: ->
    @_showWorkPicker = false
    @lazyRender()

  onRender: ->
    if @_showWorkPicker
      @ui.workPickerSelect.focus()
      @startListingForChanges()

  startListingForChanges: ->
    if @_listingForChanges then return
    @_listingForChanges = true
    @listenTo @worksWithOrdinal, 'update', @lazyRender

  onSelectChange: ->
    uri = @ui.workPickerSelect.val()
    if _.isEntityUri uri then @ui.workPickerValidate.removeClass 'invisible'
    else @ui.workPickerValidate.addClass 'invisible'

  validateWorkChange: ->
    uri = @ui.workPickerSelect.val()
    unless _.isEntityUri(uri) and uri isnt @workUri then return

    newWork = @worksWithOrdinal.findWhere { uri }
    edition = @model
    currentWorkEditions = edition.collection

    rollback = (err)->
      currentWorkEditions.add edition
      newWork.editions.remove edition
      throw err

    edition.setPropertyValue 'wdt:P629', @workUri, uri
    .then ->
      # Moving the edition after the property is set is required to make sure
      # that the new edition view is initialized with the right work model and thus
      # with the right workLabel
      currentWorkEditions.remove edition
      newWork.editions.add edition
    .catch rollback

  getWorksLabel: ->
    unless @editionLang? then return

    @model.waitForWorks
    .then (works)=>
      if works.length isnt 1 then return
      work = works[0]
      workLabel = work.get "labels.#{@editionLang}"
      if workLabel? and workLabel isnt @model.get('label')
        @workLabel = workLabel
        @lazyRender()

  copyWorkLabel: ->
    unless @workLabel? then return
    currentTitle = @model.get 'claims.wdt:P1476.0'
    @model.setPropertyValue 'wdt:P1476', currentTitle, @workLabel
    @model.setLabelFromTitle()
    @workLabel = null
    @lazyRender()
