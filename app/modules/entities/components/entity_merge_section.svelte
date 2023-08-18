<script>
  import EntityValueDisplay from '#entities/components/editor/entity_value_display.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { typesBySection } from '#search/lib/search_sections'
  import { I18n } from '#user/lib/i18n'

  export let type, uri

  let flash, valueBasicInfo, editMode = false

  function select (e) {
    uri = e.detail.uri
    editMode = false
  }

  function setInfo () {
    type = valueBasicInfo.type
    if (uri && valueBasicInfo.redirection) {
      uri = valueBasicInfo.redirection
    }
  }

  $: if (valueBasicInfo) setInfo()
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
      on:click={() => uri = null}
    >
      {@html icon('close')}
    </button>
  </div>
{:else}
  <EntityAutocompleteSelector
    searchTypes={type || typesBySection.entity.all}
    currentEntityUri={uri}
    currentEntityLabel={uri ? valueBasicInfo?.label : null}
    displaySuggestionType={type == null}
    autofocus={false}
    on:close={() => editMode = false}
    on:error={e => flash = e.detail}
    on:select={select}
  />
{/if}

<Flash bind:state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
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
