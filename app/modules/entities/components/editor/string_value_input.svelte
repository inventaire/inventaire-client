<script>
  import { autofocus } from '#lib/components/actions/autofocus'
  import error_ from '#lib/error'
  import { BubbleUpComponentEvent } from '#lib/svelte/svelte'
  import { findMatchingSerieLabel, getEditionSeriesLabels } from '#entities/components/editor/lib/title_tip'
  import { createEventDispatcher, tick } from 'svelte'
  import { I18n } from '#user/lib/i18n'

  export let currentValue, getInputValue, entity, property

  const dispatch = createEventDispatcher()
  const bubbleUpEvent = BubbleUpComponentEvent(dispatch)

  let input
  getInputValue = async () => {
    // Wait for input to be mounted
    await tick()
    const { value } = input
    // Testing the length in addition to the minlength setting
    // as that setting does not seem to set input.validity.valid=false correctly
    // (Tested only in Firefox v99)
    if (value.length === 0 || !input.validity.valid) {
      throw error_.new('invalid value', 400, { value })
    }
    return input.value
  }

  let serieUri, serieLabels, matchingSerieLabel
  if (entity.type === 'edition' && property === 'wdt:P1476') {
    getEditionSeriesLabels(entity)
      .then(res => {
        if (!res) return
        serieUri = res.uri
        serieLabels = res.labels
      })
      .catch(err => dispatch('error', err))
  }

  function onInputKeyup (e) {
    bubbleUpEvent(e)
    if (serieLabels) {
      const { value } = input
      matchingSerieLabel = findMatchingSerieLabel(value, serieLabels)
    }
  }
</script>

<div class="wrapper">
  <input
    type="text"
    value={currentValue || ''}
    on:keyup={onInputKeyup}
    bind:this={input}
    use:autofocus
  />
  {#if matchingSerieLabel}
    <p class="tip">
      {@html I18n('title_matches_serie_label_tip', {
        pathname: `/entity/${serieUri}/edit`
      })}
    </p>
  {/if}
</div>

<style lang="scss">
  @import "#entities/scss/title_tip";
  .wrapper{
    position: relative;
    flex: 1;
  }
  input{
    margin: 0 0.2em 0 0;
  }
  input:invalid{
    border: 2px red solid;
  }
</style>
