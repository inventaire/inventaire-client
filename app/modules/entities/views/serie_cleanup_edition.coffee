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
    @workUri = @model.get 'claims.wdt:P629.0'

  serializeData: ->
    _.extend @model.toJSON(),
      worksList: @getWorksList()

  events:
    'click .changeWork': 'changeWork'
    'change .workPickerSelect': 'onSelectChange'
    'click .validate': 'validateWorkChange'
    'keydown .workPickerSelect': 'onKeydown'

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
    if _.isEntityUri(uri) and uri isnt @workUri
      @model.setPropertyValue 'wdt:P629', @workUri, uri
