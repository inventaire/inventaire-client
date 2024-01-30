<script>
  import { getISODay } from '#lib/time'
  import SimpleDayValueInputField from './simple_day_value_input_field.svelte'
  import SimpleDayValueInputLabel from './simple_day_value_input_label.svelte'
  import { uniqueId } from 'underscore'
  import { BubbleUpComponentEvent } from '#lib/svelte/svelte'

  export let currentValue, getInputValue

  const bubbleUpEvent = BubbleUpComponentEvent()
  const componentId = uniqueId('component')

  getInputValue = () => {
    if (day) return `${year}-${padField(month)}-${padField(day)}`
    else if (month) return `${year}-${padField(month)}`
    else return year.toString()
  }

  const getDateParts = date => date.split('-').map(num => parseInt(num))
  const padField = fieldValue => fieldValue.toString().padStart(2, '0')

  const [ currentYear, currentMonth, currentDay ] = getDateParts(getISODay())
  const nextYear = parseInt(currentYear) + 1

  let year, month, day
  if (currentValue) {
    [ year, month, day ] = getDateParts(currentValue)
  } else {
    [ year ] = getDateParts(getISODay())
  }

  const initMonth = () => month = month || 1
  const resetDay = () => day = null

  // Use functions to refresh only when the variables
  // in the reactive statement change
  $: if (day != null) initMonth()
  $: if (month == null) resetDay()
</script>

<div class="wrapper">
  <!-- Separate the labels from the inputs so that inputs can follow each others in tab order -->
  <div class="labels">
    <SimpleDayValueInputLabel
      name="year"
      bind:value={year}
      optional={false}
    />

    <SimpleDayValueInputLabel
      name="month"
      bind:value={month}
      {componentId}
    />

    <SimpleDayValueInputLabel
      name="day"
      bind:value={day}
      {componentId}
    />
  </div>

  <div class="inputs">
    <SimpleDayValueInputField
      name="year"
      bind:value={year}
      min="-3000"
      max={nextYear}
      placeholder={currentYear}
      on:keyup={bubbleUpEvent}
      optional={false}
      {componentId}
    />

    <SimpleDayValueInputField
      name="month"
      bind:value={month}
      min="1"
      max="12"
      placeholder={currentMonth}
      on:keyup={bubbleUpEvent}
      {componentId}
    />

    <SimpleDayValueInputField
      name="day"
      bind:value={day}
      min="1"
      max="31"
      placeholder={currentDay}
      on:keyup={bubbleUpEvent}
      {componentId}
    />
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .wrapper{
    margin-inline-end: auto;
    /* Small screens */
    @media screen and (max-width: $smaller-screen){
      margin-inline-start: auto;
    }
  }

  .labels, .inputs{
    @include display-flex(row);
  }
  .labels{
    margin-block-end: 0.1em;
  }
</style>
