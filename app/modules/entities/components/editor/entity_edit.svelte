<script>
  import { I18n } from 'modules/user/lib/i18n'
  import LabelsEditor from './labels_editor.svelte'
  import propertiesPerType from 'modules/entities/lib/editor/properties_per_type'
  import PropertyClaimsEditor from './property_claims_editor.svelte'

  export let entity

  const { type } = entity
  const typeProperties = propertiesPerType[type]
</script>

<div class="entity-edit">
  <h2>{I18n(entity.type)}</h2>
  <LabelsEditor {entity} />
  {#each Object.keys(typeProperties) as property}
    <PropertyClaimsEditor
      {entity}
      {property}
      {typeProperties}
    />
  {/each}
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .entity-edit{
    @include display-flex(column, center, center);
    max-width: 50em;
    margin: 0 auto;
  }
  h2{
    text-align: center;
  }
</style>
