WorkPicker = require './work_picker'

module.exports = WorkPicker.extend
  tagName: 'li'
  className: 'serie-cleanup-edition'
  template: require './templates/serie_cleanup_edition'

  initialize: ->
    WorkPicker::initialize.call @
    @editionLang = @model.get 'lang'
    @workUri = @model.get 'claims.wdt:P629.0'
    @getWorksLabel()

  serializeData: ->
    _.extend @model.toJSON(),
      workLabel: @workLabel
      worksList: if @_showWorkPicker then @getWorksList()
      workPickerValidateLabel: 'validate'

  events: _.extend {}, WorkPicker::events,
    'click .copyWorkLabel': 'copyWorkLabel'

  onWorkSelected: (newWork)->
    if newWork.get('uri') is @workUri then return

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
