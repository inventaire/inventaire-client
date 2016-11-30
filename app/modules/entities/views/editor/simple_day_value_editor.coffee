EditorCommons = require './editor_commons'
error_ = require 'lib/error'

currentYear = new Date().getFullYear()
yearsList = [currentYear..1800]
monthsList = [1..12]
daysList = [1..31]

module.exports = EditorCommons.extend
  mainClassName: 'simple-day-value-editor'
  template: require './templates/simple_day_value_editor'
  behaviors:
    AlertBox: {}
    ConfirmationModal: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    # If the value is null, start directly in edit mode
    if not @model.get('value')? then @editMode = true
    @focusTarget = 'yearPicker'
    [ year, month, day ] = simpleDayData @model.get 'value'
    @setCurrentValues year, month, day
    if month? then @showMonthsAndDays = true

  ui:
    yearPicker: '#yearPicker'
    monthPicker: '#monthPicker'
    dayPicker: '#dayPicker'

  events:
    'click .edit, .displayModeData': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'click .delete': 'delete'
    # Not setting a particular selector so that any keyup event on the element triggers the event
    'keyup': 'onKeyup'
    'click .showMonthsAndDays': 'displayMonthsAndDays'
    'click .showYearsOnly': 'displayYearsOnly'

  serializeData: ->
    attrs = @model.toJSON()
    attrs.editMode = @editMode
    if @editMode
      attrs.showMonthsAndDays = @showMonthsAndDays
      [ year, month, day ] = simpleDayData attrs.value
      year = @currentlySelectedYear or year
      month = @currentlySelectedMonth or month
      day = @currentlySelectedDay or day
      attrs.years = getUnits yearsList, currentYear, year
      attrs.months = getUnits monthsList, currentYear, month
      attrs.days = getUnits daysList, currentYear, day
    return attrs

  displayMonthsAndDays: ->
    @changeDisplayedUnits true, 'monthPicker'
    recoverDefaultFocusTarget = => @focusTarget = 'yearPicker'
    # Change the focus target to years once this as been re-rendered focusing on months
    # so that it focuses on years at next re-render
    setTimeout recoverDefaultFocusTarget, 500
  displayYearsOnly: -> @changeDisplayedUnits false, 'yearPicker'
  changeDisplayedUnits: (showMonthsAndDays, focusTarget)->
    # Save year value to make it the selected one later
    # As rerendering would have lost the currently selected year otherwise
    @setCurrentValues @ui.yearPicker.val(), @ui.monthPicker.val(), @ui.dayPicker.val()
    @showMonthsAndDays = showMonthsAndDays
    @focusTarget = focusTarget
    @lazyRender()

  onRender: ->
    @focusOnRender()

  save: ->
    year = @ui.yearPicker.val()
    month = paddedValue @ui.monthPicker?.val()
    day = paddedValue @ui.dayPicker?.val()
    @setCurrentValues year, month, day
    if month? then date = "#{year}-#{month}-#{day}"
    else if year? then date = "#{year}"
    else throw error_.new "couldn't extract date", [ year, month, day ]

    @_save date

  setCurrentValues: (year, month, day)->
    # Make sure those are of type number as that's what getUnits needs to find
    # the selected value
    @currentlySelectedYear = parseIntIfVal year
    @currentlySelectedMonth = parseIntIfVal month
    @currentlySelectedDay = parseIntIfVal day

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

paddedValue = (value)-> if value?.toString().length is 1 then "0#{value}" else value

parseIntIfVal = (value)-> if value? then parseInt value
