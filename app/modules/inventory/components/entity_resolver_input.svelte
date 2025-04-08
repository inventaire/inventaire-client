<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import EntityValueDisplay from '#entities/components/editor/entity_value_display.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import type { EntityType, EntityUri } from '#server/types/entity'
  import { I18n } from '#user/lib/i18n'

  export let type: EntityType
  export let entity
  export let label: string = null
  export let currentEntityLabel: string = null
  export let uri: EntityUri = null

  if (!entity.claims) entity.claims = {}

  const initialEntity = entity
  const initialLabel = label || entity?.label

  currentEntityLabel = initialLabel
  let flash, editMode = false

  function selectSuggestion (e) {
    // Since autocomplete suggestion does not have labels key,
    // e.detail is the full autocomplete suggestion (not only its uri).
    // Which allows to use suggestion.label when creating edition from work,
    // without having the server fetch the entity again
    entity = e.detail
    uri = entity.uri
    editMode = false
  }

  function unselectSuggestion () {
    // rewrite entity to trigger candidateRow statuses
    entity = initialEntity
    uri = null
    currentEntityLabel = initialLabel
  }
</script>

{#if uri && !editMode}
  <div class="row">
    <EntityValueDisplay
      value={uri}
      on:edit={() => editMode = true}
    />
    <button
      class="unselect"
      title={I18n('unselect')}
      on:click|stopPropagation={unselectSuggestion}
    >
      {@html icon('close')}
    </button>
  </div>
{:else}
  <EntityAutocompleteSelector
    searchTypes={[ type ]}
    currentEntityUri={uri}
    bind:currentEntityLabel
    createdEntityType="work"
    displaySuggestionType={false}
    autofocus={false}
    relationSubjectEntity={entity}
    relationProperty="wdt:P629"
    allowEntityCreation={true}
    showDefaultSuggestions={false}
    on:close={() => editMode = false}
    on:error={e => flash = e.detail}
    on:select={selectSuggestion}
  />
{/if}

<Flash bind:state={flash} />

<style lang="scss">
  @use "#general/scss/utils";
  .row{
    @include display-flex(row, center);
    margin: 0.5em 0;
    :global(.bottom){
      padding: 0.2em 0;
    }
  }
  .unselect{
    @include shy;
    :global(.fa){
      font-size: 1.2rem;
    }
  }
</style>
