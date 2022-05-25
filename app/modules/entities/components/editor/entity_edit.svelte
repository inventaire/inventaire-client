<script>
  import LabelsEditor from './labels_editor.svelte'
  import { propertiesPerType } from '#entities/lib/editor/properties_per_type'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import EntityEditMenu from './entity_edit_menu.svelte'
  import EntityHeader from '../entity_header.svelte'

  export let entity

  const { type, labels } = entity
  const typeProperties = propertiesPerType[type]
  const hasMonolingualTitle = typeProperties['wdt:P1476'] != null

  let favoriteLabel
  $: {
    if (hasMonolingualTitle) {
      favoriteLabel = entity.claims['wdt:P1476']?.[0]
    } else {
      favoriteLabel = getBestLangValue(app.user.lang, null, labels).value
    }
  }
</script>

<div class="entity-edit">
  <div class="header">
    <EntityHeader {entity}/>
    <EntityEditMenu {entity} />
  </div>

  {#if !hasMonolingualTitle}
    <LabelsEditor {entity} bind:favoriteLabel />
  {/if}

  {#each Object.keys(typeProperties) as property}
    <PropertyClaimsEditor
      bind:entity
      {property}
    />
  {/each}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .entity-edit{
    @include display-flex(column, stretch, center);
    max-width: 50em;
    margin: 0 auto;
  }
  .header{
    position: relative;
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .header{
      @include display-flex(row, center, space-between, wrap);
    }
  }
</style>
