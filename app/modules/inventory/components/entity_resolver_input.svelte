<script>
  import EntityValueDisplay from '#entities/components/editor/entity_value_display.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { I18n } from '#user/lib/i18n'

  export let type, entity

  const { label } = entity
  let currentEntityLabel = label

  let uri

  let flash, valueBasicInfo, editMode = false

  function select (e) {
    uri = entity.uri = e.detail
    editMode = false
  }

  function setInfo () {
    type = valueBasicInfo.type
    if (uri && valueBasicInfo.redirection) {
      uri = valueBasicInfo.redirection
      currentEntityLabel = valueBasicInfo.label
    }
  }

  $: if (valueBasicInfo) setInfo()

  $: entity.label = currentEntityLabel
</script>

{#if uri && !editMode}
  <div class="row">
    <EntityValueDisplay
      value={uri}
      bind:valueBasicInfo
      on:edit={() => editMode = true}
    />
    <button
      class="unselect"
      title={I18n('unselect')}
      on:click|stopPropagation={() => uri = null}
    >
      {@html icon('close')}
    </button>
  </div>
{:else}
  <EntityAutocompleteSelector
    searchTypes={type}
    currentEntityUri={uri}
    bind:currentEntityLabel
    displaySuggestionType={false}
    autofocus={false}
    on:close={() => editMode = false}
    on:error={e => flash = e.detail}
    on:select={select}
  />
{/if}

<Flash bind:state={flash}/>

<style lang="scss">
  @import '#general/scss/utils';
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
