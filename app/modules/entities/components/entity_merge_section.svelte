<script>
  import EntityValueDisplay from '#entities/components/editor/entity_value_display.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { BubbleUpComponentEvent } from '#lib/svelte'
  import { I18n } from '#user/lib/i18n'

  export let type, uri

  let flash
  const bubbleUpComponentEvent = BubbleUpComponentEvent()
</script>

{#if uri}
  <div class="row">
    <EntityValueDisplay value={uri} />
    <button
      class="unselect"
      title={I18n('unselect')}
      on:click={() => uri = null}
    >
      {@html icon('close')}
    </button>
  </div>
{:else}
  <EntityAutocompleteSelector
    {type}
    displaySuggestionType={true}
    on:error={e => flash = e.detail}
    on:select={bubbleUpComponentEvent}
  />
{/if}

<Flash bind:state={flash}/>

<style lang="scss">
  @import '#general/scss/utils';
  .row{
    @include display-flex(row, center);
  }
  .unselect{
    @include shy;
    :global(.fa){
      font-size: 1.2rem;
    }
  }
</style>
