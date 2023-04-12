<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/handlebars_helpers/icons'

  export let elements, index, elementId

  function moveElement (isMoveUp) {
    const index = elements.findIndex(obj => obj._id === elementId)
    const element = elements[index]
    let newIndex
    if (isMoveUp) newIndex = index - 1
    else newIndex = index + 1
    elements[index] = elements[newIndex]
    elements[newIndex] = element
  }
</script>
<div class="reorder-section">
  {#if index !== 0}
    <button
      on:click={() => moveElement(true)}
      class="tiny-button"
      title={i18n('Move up')}
    >
      {@html icon('chevron-up')}
    </button>
  {/if}
  {#if index !== elements.length - 1}
    <button
      on:click={() => moveElement(false)}
      class="tiny-button"
      title={i18n('Move down')}
    >
      {@html icon('chevron-down')}
    </button>
  {/if}
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .reorder-section{
    @include display-flex(column);
  }
  .tiny-button{
    margin: 0.3em;
  }
</style>
