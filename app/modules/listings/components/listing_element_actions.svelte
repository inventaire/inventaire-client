<script>
  import { clone } from 'underscore'
  import { icon } from '#app/lib/icons'
  import { moveArrayElement } from '#app/lib/utils'
  import Spinner from '#general/components/spinner.svelte'
  import { updateElement } from '#listings/lib/listings'
  import { i18n } from '#user/lib/i18n'

  export let element, elements, flash, index

  let isReordering, reorderPromise

  async function waitingForReorder (newIndex) {
    reorderPromise = reorder(newIndex)
    await reorderPromise
    reorderPromise = null
  }

  async function reorder (newIndex) {
    isReordering = true
    flash = null
    const oldElements = clone(elements)
    elements = moveArrayElement(elements, index, newIndex)
    const exclusiveOrdinal = newIndex + 1
    await updateElement({
      id: element._id,
      ordinal: exclusiveOrdinal,
    })
      .then(() => {
        isReordering = false
      })
      .catch(err => {
        flash = err
        elements = oldElements
      })
  }

  $: hasSeveralElements = elements.length > 1
</script>
{#if hasSeveralElements}
  <div class="reorder-section">
    {#if index !== 0}
      <button
        disabled={isReordering}
        on:click={() => waitingForReorder(index - 1)}
        title={i18n('Move up')}
      >
        {@html icon('chevron-up')}
      </button>
    {/if}
    <div class="list-index">
      {#if reorderPromise}
        <Spinner />
      {:else}
        {index + 1}
      {/if}
    </div>
    {#if index !== elements.length - 1}
      <button
        disabled={isReordering}
        on:click={() => waitingForReorder(index + 1)}
        title={i18n('Move down')}
      >
        {@html icon('chevron-down')}
      </button>
    {/if}
  </div>
{/if}
<style lang="scss">
  @use "#general/scss/utils";
  .reorder-section{
    @include display-flex(column, center);
    margin-inline-start: 1em;
    button{
      color: $grey;
    }
  }
  .list-index{
    font-size: 1.3em;
  }
</style>
