import { isNonEmptyString } from 'lib/boolean_tests'
import { simpleDay } from 'lib/utils'
import { i18n } from 'modules/user/lib/i18n'
import ClaimsEditorCommons from './claims_editor_commons'
let noValueI18n = null

export default ClaimsEditorCommons.extend({
  mainClassName: 'simple-day-value-editor',
  template: require('./templates/simple_day_value_editor.hbs'),

  initialize () {
    this.initEditModeState()
    this.focusTarget = 'yearPicker'
    const [ year, month, day ] = simpleDayParts(this.model.get('value'))
    this.initialValues = { year, month, day }
    this.currentlySelected = {}
    this.setCurrentValues(year, month, day)

    // Add the translated version of 'no value' once the i18n
    // function is accessible
    if (noValueI18n == null) {
      if (!noValueI18n) { noValueI18n = i18n('no value') }
      selectorValues.month.unshift(noValueI18n)
      return selectorValues.day.unshift(noValueI18n)
    }
  },

  ui: {
    yearPicker: '#yearPicker',
    monthPicker: '#monthPicker',
    dayPicker: '#dayPicker'
  },

  events: {
    'click .edit, .displayModeData': 'showEditMode',
    'click .cancel': 'hideEditMode',
    'click .save': 'save',
    'click .delete': 'delete',
    // Not setting a particular selector so that
    // any keyup event on the element triggers the event
    keyup: 'onKeyUp',
    'click .addUnit': 'addUnit',
    'change select': 'updateSelectors'
  },

  serializeData () {
    const attrs = this.model.toJSON()
    attrs.editMode = this.editMode
    if (this.editMode) {
      attrs.yearData = this.getUnitData('year', currentYear)
      attrs.monthData = this.getUnitData('month', null)
      attrs.dayData = this.getUnitData('day', null)
    }
    return attrs
  },

  onToggleEditMode () {
    // Reset values so that escaping the edit mode and coming back in edit mode
    // results in the value being restored to its saved state
    return this.setCurrentValues(...simpleDayParts(this.model.get('value')) || [])
  },

  getUnitData (name, defaultValue) {
    const value = this.currentlySelected[name] || defaultValue
    const possibleValues = getPossibleValues(selectorValues[name], defaultValue, value)
    return { name, value, possibleValues }
  },

  onRender () {
    return this.focusOnRender()
  },

  updateSelectors (e) {
    const { id, value } = e.currentTarget
    const name = id.replace('Picker', '')
    if (value === noValueI18n) {
      if (name === 'month') {
        this.currentlySelected.month = null
        this.focusTarget = 'yearPicker'
      } else {
        this.focusTarget = 'monthPicker'
      }

      this.currentlySelected.day = null
      this.lazyRender()
    } else {
      this.currentlySelected[name] = parseInt(value)
    }
  },

  setCurrentValues (year, month, day) {
    // Make sure those are of type number as that's what
    // getPossibleValues needs to find the selected value
    this.currentlySelected.year = parseIntIfVal(year)
    this.currentlySelected.month = parseIntIfVal(month)
    this.currentlySelected.day = parseIntIfVal(day)
  },

  addUnit (e) {
    const name = e.currentTarget.attributes['data-name'].value
    this.currentlySelected[name] = this.initialValues[name] || 1
    if ((name === 'day') && (this.currentlySelected.month == null)) {
      this.currentlySelected.month = this.initialValues.month || 1
    }
    this.focusTarget = `${name}Picker`
    this.lazyRender()
  },

  save () {
    const year = this.ui.yearPicker.val()
    const month = paddedValue(this.ui.monthPicker?.val())
    const day = paddedValue(this.ui.dayPicker?.val())

    let date = year
    if (month != null) {
      date += `-${month}`
      if (day != null) { date += `-${day}` }
    }

    return this._save(date)
  }
})

const getPossibleValues = function (values, defaultValue, selected) {
  if (!selected) { selected = defaultValue }
  return values.map(value => {
    const valueObj = { num: value }
    if ((selected != null) && (value === selected)) { valueObj.selected = true }
    return valueObj
  })
}

const simpleDayParts = function (simpleDay) {
  if (isNonEmptyString(simpleDay)) {
    return simpleDay.split('-').map(parseDateInt)
  } else {
    return []
  }
}

const parseDateInt = function (date) {
  if (isNonEmptyString(date)) {
    return parseInt(date.replace(/^0/, ''))
  } else {
    return null
  }
}

const paddedValue = function (value) {
  if (value?.toString().length === 1) { return `0${value}` } else { return value }
}

const parseIntIfVal = function (value) { if (value != null) { return parseInt(value) } }

const currentYear = parseInt(simpleDay().split('-')[0])
const nextYear = currentYear + 1

const selectorValues = {
  day: __range__(1, 31, true),
  month: [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ],
  // Start with the latest years first, as those are likely
  // to be the most used values
  year: __range__(nextYear, 1800, true)
}

function __range__ (left, right, inclusive) {
  const range = []
  const ascending = left < right
  const end = !inclusive ? right : ascending ? right + 1 : right - 1
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i)
  }
  return range
}
