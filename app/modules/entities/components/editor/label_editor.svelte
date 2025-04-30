<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { assertString } from '#app/lib/assert_types'
  import { isNonEmptyString } from '#app/lib/boolean_tests'
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import { removeLabel, updateLabel } from '#entities/lib/entities'
  import { I18n, i18n } from '#modules/user/lib/i18n'
  import type { EntityUri } from '#server/types/entity'
  import EditModeButtons from './edit_mode_buttons.svelte'
  import { findMatchingSerieLabel } from './lib/title_tip'
  import type { WikimediaLanguageCode } from 'wikibase-sdk'

  export let uri: EntityUri = null
  export let lang: WikimediaLanguageCode
  export let value: string | symbol = ''

  export let serieUri: boolean
  export let showDelete = true
  export let serieLabels: string[]
  export let deleteButtonDisable = false

  let inputValue = value

  const dispatch = createEventDispatcher()

  let flash
  async function save () {
    assertString(inputValue)
    try {
      value = inputValue = inputValue.trim()
      if (inputValue === '') return deleteLabel()
      else if (uri != null) await updateLabel(uri, lang, value)
      dispatch('done', value)
    } catch (err) {
      flash = err
    }
  }

  let previousValue
  async function deleteLabel () {
    try {
      previousValue = value
      value = Symbol.for('removed')
      dispatch('done', value)
      if (uri != null) await removeLabel(uri, lang)
    } catch (err) {
      flash = err
    }
  }

  async function undo () {
    inputValue = previousValue
    save()
  }

  let matchingSerieLabel
  function onInputKeyup (e) {
    const key = getActionKey(e)
    if (key === 'esc') {
      cancel()
    } else if (e.ctrlKey && key === 'enter') {
      save()
    }
    if (serieLabels && isNonEmptyString(inputValue)) {
      matchingSerieLabel = findMatchingSerieLabel(inputValue, serieLabels)
    }
  }

  function cancel () {
    dispatch('done')
  }
</script>

<div class="label-editor-input">
  {#if flash}
    <Flash state={flash} />
  {:else if value === Symbol.for('removed')}
    <button
      class="undo"
      title={`${i18n('Recover previous value:')} ${previousValue}`}
      on:click={undo}
    >
      {@html icon('undo')}
      {I18n('undo')}
    </button>
  {:else}
    <input
      type="text"
      bind:value={inputValue}
      use:autofocus
      on:keyup={onInputKeyup}
    />
    {#if matchingSerieLabel}
      <p class="tip">
        {@html I18n('title_matches_serie_label_tip', {
          pathname: `/entity/${serieUri}/edit`,
        })}
      </p>
    {/if}
  {/if}
</div>

{#if value !== Symbol.for('removed')}
  <EditModeButtons
    on:cancel={cancel}
    on:save={save}
    on:delete={deleteLabel}
    {showDelete}
    deleteButtonDisableMessage={deleteButtonDisable ? i18n('There should be at least one label') : null}
  />
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  @import "#entities/scss/title_tip";

  .label-editor-input{
    position: relative;
    @include display-flex(row);
  }
  input{
    margin-block-end: 0;
  }
  .undo{
    flex: 1;
    padding: 0.6em 0;
    margin: 0 0.5em;
    @include shy(0.9);
    @include bg-hover(#ddd);
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    input{
      margin: 0;
    }
  }
</style>
