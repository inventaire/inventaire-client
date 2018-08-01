getActionKey = require 'lib/get_action_key'

module.exports = Marionette.CompositeView.extend
  tagName: 'li'
  className: 'serie-cleanup-edition'
  template: require './templates/serie_cleanup_edition'

  ui:
    changeWork: '.changeWork'
    workPicker: '.workPicker'
    workPickerSelect: '.workPickerSelect'
    workPickerValidate: '.validate'

  initialize: ->
    @lazyRender = _.LazyRender @, 100
    @workUri = @model.get 'claims.wdt:P629.0'
    @editionLang = @model.get 'lang'

    @getWorksLabel()

  serializeData: ->
    _.extend @model.toJSON(),
      worksList: @getWorksList()
      workLabel: @workLabel

  events:
    'click .changeWork': 'changeWork'
    'change .workPickerSelect': 'onSelectChange'
    'click .validate': 'validateWorkChange'
    'keydown .workPickerSelect': 'onKeydown'
    'click .copyWorkLabel': 'copyWorkLabel'

  changeWork: (e)->
    if $(e.currentTarget).hasClass 'unavailable' then return
    @showWorkPicker()

  getWorksList: ->
    worksWithOrdinal = @options.getWorksWithOrdinalList()
    unless worksWithOrdinal? then return
    return worksWithOrdinal.filter (work)=> work.uri isnt @workUri

  onKeydown: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @hideWorkPicker()
      when 'enter' then @validateWorkChange()

  showWorkPicker: ->
    @ui.changeWork.hide()
    @ui.workPicker.removeClass 'hidden'
    @ui.workPickerSelect.focus()

  hideWorkPicker: ->
    @ui.changeWork.show()
    @ui.workPicker.addClass 'hidden'
    @ui.changeWork.focus()

  onSelectChange: ->
    uri = @ui.workPickerSelect.val()
    if _.isEntityUri uri then @ui.workPickerValidate.removeClass 'invisible'
    else @ui.workPickerValidate.addClass 'invisible'

  validateWorkChange: ->
    uri = @ui.workPickerSelect.val()
    unless _.isEntityUri(uri) and uri isnt @workUri then return

    newWork = @options.worksWithOrdinal.findWhere { uri }
    edition = @model
    currentWorkEditions = edition.collection
    currentWorkEditions.remove edition
    newWork.editions.add edition

    rollback = (err)->
      currentWorkEditions.add edition
      newWork.editions.remove edition
      throw err

    @model.setPropertyValue 'wdt:P629', @workUri, uri
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
