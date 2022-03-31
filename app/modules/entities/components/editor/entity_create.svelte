<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import LabelsEditor from './labels_editor.svelte'
  import propertiesPerType from '#entities/lib/editor/properties_per_type'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import { getPropertiesShortlist, typeDefaultP31 } from '#entities/lib/entity_draft_model'
  import { entityTypeNameBySingularType, typesPossessiveForms } from '#entities/lib/types/entities_types'
  import { createAndGetEntity } from '#entities/lib/create_entities'
  import Flash from '#lib/components/flash.svelte'
  import { requiredPropertiesPerType } from '#entities/views/editor/entity_edit'
  import { getMissingRequiredProperties } from '#entities/components/lib/create_helpers'
  import WrapToggler from '#components/wrap_toggler.svelte'

  export let type = 'works'

  let showAllProperties = false, displayedProperties, flash
  let typeProperties, propertiesShortlist, hasMonolingualTitle, createAndShowLabel, requiresLabel, requiredProperties
  let entity = {
    type,
    labels: {},
    claims: {},
  }

  function onTypeChange () {
    typeProperties = propertiesPerType[type]
    hasMonolingualTitle = typeProperties['wdt:P1476'] != null
    requiresLabel = !hasMonolingualTitle
    propertiesShortlist = getPropertiesShortlist(type, entity.claims)
    requiredProperties = requiredPropertiesPerType[type] || []
    const typePossessive = typesPossessiveForms[type]
    createAndShowLabel = `create and go to the ${typePossessive} page`
    showAllProperties = false
    entity.type = type
    entity.claims['wdt:P31'] = [ typeDefaultP31[type] ]
    app.execute('querystring:set', 'type', type)
  }

  $: type && onTypeChange()

  $: {
    displayedProperties = showAllProperties ? typeProperties : _.pick(typeProperties, propertiesShortlist)
  }

  let missingRequiredProperties
  function onEntityChange () {
    if (requiredProperties == null) return
    missingRequiredProperties = getMissingRequiredProperties({ entity, requiredProperties, requiresLabel })
    if (missingRequiredProperties.length > 0) {
      flash = {
        type: 'info',
        message: `${I18n('required properties are missing')}: ${missingRequiredProperties.join(', ')}`
      }
    } else if (flash?.type === 'info') {
      flash = null
    }
  }

  $: entity && onEntityChange()

  async function createAndShowEntity () {
    try {
      const { uri } = await createAndGetEntity(entity)
      app.execute('show:entity', uri)
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="column">
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
    <LabelsEditor bind:entity />
  {/if}

  {#if typeProperties}
    {#each Object.keys(displayedProperties) as property (property)}
      <PropertyClaimsEditor
        bind:entity
        {property}
        required={requiredProperties.includes(property)}
      />
    {/each}
  {/if}

  <WrapToggler
    bind:show={showAllProperties}
    moreText={I18n('add more details')}
  />

  <Flash state={flash} />

  <div class="next">
    <button
      class="light-blue-button"
      disabled={missingRequiredProperties?.length > 0}
      on:click={createAndShowEntity}
      >
      {@html icon('arrow-right')}
      {I18n(createAndShowLabel)}
    </button>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .column{
    @include display-flex(column, stretch, center);
    max-width: 50em;
    margin: 0 auto;
    :global(.wrap-toggler) {
      margin-bottom: 1em;
    }
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
  .next{
    margin: 1em auto;
    @include display-flex(row, center, center);
    button:disabled{
      background-color: $grey;
      opacity: 0.6;
    }
  }
</style>
