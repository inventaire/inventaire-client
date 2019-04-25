ClaimsEditorCommons = require './claims_editor_commons'
error_ = require 'lib/error'
noValueI18n = null

module.exports = ClaimsEditorCommons.extend
  mainClassName: 'simple-day-value-editor'
  template: require './templates/simple_day_value_editor'
  behaviors:
    AlertBox: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @initEditModeState()
    @focusTarget = 'yearPicker'
    [ year, month, day ] = simpleDayParts @model.get 'value'
    @initialValues = { year, month, day }
    @currentlySelected = {}
    @setCurrentValues year, month, day

    # Add the translated version of 'no value' once the _.i18n
    # function is accessible
    unless noValueI18n?
      noValueI18n or= _.i18n 'no value'
      selectorValues.month.unshift noValueI18n
      selectorValues.day.unshift noValueI18n

  ui:
    yearPicker: '#yearPicker'
    monthPicker: '#monthPicker'
    dayPicker: '#dayPicker'

  events:
    'click .edit, .displayModeData': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'click .delete': 'delete'
    # Not setting a particular selector so that
    # any keyup event on the element triggers the event
    'keyup': 'onKeyUp'
    'click .addUnit': 'addUnit'
    'change select': 'updateSelectors'

  serializeData: ->
    attrs = @model.toJSON()
    attrs.editMode = @editMode
    if @editMode
      attrs.yearData = @getUnitData 'year', currentYear
      attrs.monthData = @getUnitData 'month', null
      attrs.dayData = @getUnitData 'day', null
    return attrs

  onToggleEditMode: ->
    # Reset values so that escaping the edit mode and coming back in edit mode
    # results in the value being restored to its saved state
    @setCurrentValues simpleDayParts(@model.get('value'))...

  getUnitData: (name, defaultValue)->
    value = @currentlySelected[name] or defaultValue
    possibleValues = getPossibleValues selectorValues[name], defaultValue, value
    return { name, value, possibleValues }

  onRender: ->
    @focusOnRender()

  updateSelectors: (e)->
    { id, value } = e.currentTarget
    name = id.replace 'Picker', ''
    if value is noValueI18n
      if name is 'month'
        @currentlySelected.month = null
        @focusTarget = 'yearPicker'
      else
        @focusTarget = 'monthPicker'

      @currentlySelected.day = null
      @lazyRender()
    else
      @currentlySelected[name] = parseInt value

  setCurrentValues: (year, month, day)->
    # Make sure those are of type number as that's what
    # getPossibleValues needs to find the selected value
    @currentlySelected.year = parseIntIfVal year
    @currentlySelected.month = parseIntIfVal month
    @currentlySelected.day = parseIntIfVal day

  addUnit: (e)->
    name = e.currentTarget.attributes['data-name'].value
    @currentlySelected[name] = @initialValues[name] or 1
    if name is 'day' and not @currentlySelected.month?
      @currentlySelected.month = @initialValues.month or 1
    @focusTarget = "#{name}Picker"
    @lazyRender()

  save: ->
    year = @ui.yearPicker.val()
    month = paddedValue @ui.monthPicker?.val()
    day = paddedValue @ui.dayPicker?.val()

    date = year
    if month?
      date += "-#{month}"
      if day? then date += "-#{day}"

    @_save date

getPossibleValues = (values, defaultValue, selected)->
  selected or= defaultValue
  return values.map (value)->
    valueObj = { num: value }
    if selected? and value is selected then valueObj.selected = true
    return valueObj

simpleDayParts = (simpleDay)->
  if _.isNonEmptyString simpleDay
    return simpleDay.split('-').map parseDateInt
  else
    return []

parseDateInt = (date)->
  if _.isNonEmptyString date then parseInt date.replace(/^0/, '')
  else null

paddedValue = (value)->
  if value?.toString().length is 1 then "0#{value}" else value

parseIntIfVal = (value)-> if value? then parseInt value

currentYear = parseInt _.simpleDay().split('-')[0]
nextYear = currentYear + 1

selectorValues =
  day: [ 1..31 ]
  month: [ 1..12 ]
  # Start with the latest years first, as those are likely
  # to be the most used values
  year: [ nextYear..1800 ]
