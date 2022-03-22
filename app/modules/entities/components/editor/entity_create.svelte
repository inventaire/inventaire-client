<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import LabelsEditor from './labels_editor.svelte'
  import propertiesPerType from '#entities/lib/editor/properties_per_type'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import { getPropertiesShortlist } from '#entities/lib/entity_draft_model'
  import { entityTypeNameBySingularType, typesPossessiveForms } from '#entities/lib/types/entities_types'

  export let type = 'works'

  let showAllProperties = false, displayedProperties

  const entity = {
    labels: {},
    claims: {},
  }

  let typeProperties, propertiesShortlist, hasMonolingualTitle, createAndShowLabel
  $: {
    typeProperties = propertiesPerType[type]
    hasMonolingualTitle = typeProperties['wdt:P1476'] != null
    propertiesShortlist = getPropertiesShortlist(type, entity.claims)
    const typePossessive = typesPossessiveForms[type]
    createAndShowLabel = `create and go to the ${typePossessive} page`
    showAllProperties = false
  }
  $: {
    displayedProperties = showAllProperties ? typeProperties : _.pick(typeProperties, propertiesShortlist)
  }
</script>

<div class="entity-create">
  <ul class="type-picker" role="listbox">
    {#each Object.entries(entityTypeNameBySingularType) as [ t, name ]}
      <li role="option">
        <button
          on:click={() => type = t}
          class:selected={type === t}
          >
          {I18n(name)}
        </button>
      </li>
    {/each}
  </ul>

  {#if !hasMonolingualTitle}
    <LabelsEditor {entity} />
  {/if}

  {#if typeProperties}
    {#each Object.keys(displayedProperties) as property}
      <PropertyClaimsEditor
        {entity}
        {property}
        {typeProperties}
      />
    {/each}
  {/if}

  {#if !showAllProperties}
    <button
      class="show-all-properties"
      on:click={() => showAllProperties = true}
      >
      {@html icon('chevron-down')}
      {I18n('add more details')}
    </button>
  {/if}

  <div class="next">
    <button class="light-blue-button">
      {@html icon('arrow-right')}
      {I18n(createAndShowLabel)}
    </button>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .entity-create{
    @include display-flex(column, stretch, center);
    max-width: 50em;
    margin: 0 auto;
  }
  .type-picker{
    flex: 1;
    text-align: center;
    @include display-flex(row, center, center, wrap);
    margin: 2em 0.5em 2em 0.5em;
    li{
      flex: 1 0 5em;
      max-width: 10em;
      margin: 0.1em;
    }
    button{
      @include big-button($grey);
      padding: 1em;
      width: 100%;
      &.selected{
        @include bg-hover(white, 0%);
        color: $dark-grey;
      }
    }
  }
  .show-all-properties{
    @include shy;
  }
  .next{
    margin: 1em auto;
    @include display-flex(row, center, center);
  }
</style>
