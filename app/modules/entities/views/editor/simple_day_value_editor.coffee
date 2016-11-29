EditorCommons = require './editor_commons'
error_ = require 'lib/error'

currentYear = new Date().getFullYear()
yearsList = [currentYear..1800]
monthsList = [1..12]
daysList = [1..31]

module.exports = EditorCommons.extend
  className: 'simple-day-value-editor'
  template: require './templates/simple_day_value_editor'
  behaviors:
    AlertBox: {}
    ConfirmationModal: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    # If the value is null, start directly in edit mode
    if not @model.get('value')? then @editMode = true
    @focusTarget = 'yearPicker'

  ui:
    yearPicker: '#yearPicker'
    monthPicker: '#monthPicker'
    dayPicker: '#dayPicker'

  events:
    'click .edit, .data': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'click .delete': 'delete'
    # Not setting a particular selector so that any keyup event on the element triggers the event
    'keyup': 'onKeyup'
    'click .showMonthsAndDays': 'displayMonthsAndDays'

  serializeData: ->
    attrs = @model.toJSON()
    [ year, month, day ] = simpleDayData attrs.value
    attrs.editMode = @editMode
    attrs.showMonthsAndDays = @showMonthsAndDays or month?
    year = @currentlySelectedYear or year
    attrs.years = getUnits yearsList, currentYear, year
    attrs.months = getUnits monthsList, currentYear, month
    attrs.days = getUnits daysList, currentYear, day
    return attrs

  displayMonthsAndDays: ->
    # Save year value to make it the selected one later
    # As rerendering would have lost the currently selected year otherwise
    @currentlySelectedYear = parseInt @ui.yearPicker.val()
    @showMonthsAndDays = true
    @focusTarget = 'monthPicker'
    @lazyRender()

  onRender: ->
    focus = => @ui[@focusTarget].focus()
    setTimeout focus, 200

  save: ->
    year = @ui.yearPicker.val()
    month = paddedValue @ui.monthPicker?.val()
    day = paddedValue @ui.dayPicker?.val()
    if month? then date = "#{year}-#{month}-#{day}"
    else if year? then date = "#{year}"
    else throw error_.new "couldn't extract date", [ year, month, day ]

    @_save date

getUnits = (unitsList, defaultValue, selected)->
  units = []
  selected or= defaultValue
  for unit in unitsList
    unitObj = { num: unit }
    if unit is selected then unitObj.selected = true
    units.push unitObj

  return units

simpleDayData = (simpleDay)->
  if _.isNonEmptyString simpleDay
    return simpleDay.split('-').map parseDateInt
  else
    return []

parseDateInt = (date)->
  if _.isNonEmptyString date then parseInt date.replace(/^0/, '')
  else null

paddedValue = (value)-> if value.toString().length is 1 then "0#{value}" else value
