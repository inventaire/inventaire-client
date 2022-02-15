<script>
  import { simpleDay } from 'lib/utils'
  import { i18n } from 'modules/user/lib/i18n'
  import SimpleDayValueInputField from './simple_day_value_input_field.svelte'

  export let currentValue, getInputValue

  getInputValue = () => {
    if (day) return `${year}-${padField(month)}-${padField(day)}`
    else if (month) return `${year}-${padField(month)}`
    else return year.toString()
  }

  const getDateParts = date => date.split('-').map(num => parseInt(num))
  const padField = fieldValue => fieldValue.toString().padStart(2, '0')

  const [ currentYear, currentMonth, currentDay ] = getDateParts(simpleDay())
  const nextYear = parseInt(currentYear) + 1

  let year, month, day
  if (currentValue) {
    [ year, month, day ] = getDateParts(currentValue)
  } else {
    [ year ] = getDateParts(simpleDay())
  }

  const initMonth = () => month = month || 1
  const resetDay = () => day = null

  // Use functions to refresh only when the variables
  // in the reactive statement change
  $: if (day != null) initMonth()
  $: if (month == null) resetDay()
</script>

<form>
  <SimpleDayValueInputField
    name='year'
    bind:value={year}
    min=-3000
    max={nextYear}
    placeholder={currentYear}
    optional={false}
  />

  <SimpleDayValueInputField
    name='month'
    bind:value={month}
    min=1
    max=12
    placeholder={currentMonth}
    closeButtonTitle={i18n('Remove month precision')}
  />

  <SimpleDayValueInputField
    name='day'
    bind:value={day}
    min=1
    max=31
    placeholder={currentDay}
    closeButtonTitle={i18n('Remove day precision')}
  />
</form>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  form{
    @include display-flex(row);
    margin-right: auto;
  }
</style>
