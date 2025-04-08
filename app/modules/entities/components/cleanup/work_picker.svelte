<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { isEntityUri } from '#app/lib/boolean_tests'
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import { getActionKey } from '#app/lib/key_events'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { getRichSeriePartLabel } from '#entities/lib/types/serie_alt'
  import type { EntityUri } from '#server/types/entity'
  import { I18n } from '#user/lib/i18n'
  import { sortByOrdinal } from './lib/serie_cleanup_helpers'

  export let work: SerializedEntity
  export let allSerieParts: SerializedEntity[]
  export let validateLabel: string = 'validate'

  let selectedUri: EntityUri
  const dispatch = createEventDispatcher()

  function validate () {
    if (!isEntityUri(selectedUri)) return
    const selectedWork = allSerieParts.find(part => part.uri === selectedUri)
    if (!selectedWork) return
    dispatch('selectWork', selectedWork)
  }

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'esc') dispatch('close')
    else if (key === 'enter') validate()
  }

  $: otherSerieParts = allSerieParts.filter(part => part.uri !== work.uri).sort(sortByOrdinal)
  $: showValidateButton = isEntityUri(selectedUri)
</script>

<div class="work-picker">
  <select bind:value={selectedUri} use:autofocus on:keydown={onKeyDown}>
    <option>--</option>
    {#each otherSerieParts as part (part.uri)}
      <option value={part.uri} title={part.uri}>{getRichSeriePartLabel(part)}</option>
    {/each}
  </select>
  {#if showValidateButton}
    <button class="validate tiny-success-button" on:click={validate}>{I18n(validateLabel)}</button>
  {/if}
</div>

<style lang="scss">
  @use '#general/scss/utils';
  .work-picker{
    display: block;
    margin-block-start: 1em;
    @include display-flex(column, stretch);
  }
  .validate{
    display: block;
    margin-block-start: 0;
    width: 100%;
  }
</style>
