<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import LabelsEditor from './labels_editor.svelte'
  import { propertiesPerType, propertiesPerTypeAndCategory, requiredPropertiesPerType } from '#entities/lib/editor/properties_per_type'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import { entityTypeNameBySingularType, typeDefaultP31, typesPossessiveForms } from '#entities/lib/types/entities_types'
  import { createAndGetEntity } from '#entities/lib/create_entities'
  import Flash from '#lib/components/flash.svelte'
  import { getMissingRequiredProperties, getPropertiesShortlist, removeNonTypeProperties } from '#entities/components/editor/lib/create_helpers'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import EntityTypePicker from '#entities/components/editor/entity_type_picker.svelte'
  import PropertyCategory from '#entities/components/editor/property_category.svelte'

  export let type = 'works', claims, label

  const canChangeType = !(type && claims)

  let showAllProperties = false, flash
  let typeProperties, typePropertiesPerCategory, propertiesShortlist, hasMonolingualTitle, createAndShowLabel, requiresLabel, requiredProperties
  let entity = {
    type,
    labels: {},
    claims: claims || {},
  }

  function onTypeChange () {
    entity.type = type
    typeProperties = propertiesPerType[type]
    typePropertiesPerCategory = propertiesPerTypeAndCategory[type]
    removeNonTypeProperties(entity.claims, typeProperties)
    hasMonolingualTitle = typeProperties['wdt:P1476'] != null
    requiresLabel = !hasMonolingualTitle
    entity.claims['wdt:P31'] = [ typeDefaultP31[type] ]
    propertiesShortlist = getPropertiesShortlist(type, entity.claims)
    requiredProperties = requiredPropertiesPerType[type] || []
    const typePossessive = typesPossessiveForms[type]
    createAndShowLabel = `create and go to the ${typePossessive} page`
    showAllProperties = false
    app.execute('querystring:set', 'type', type)
  }

  $: type && onTypeChange()

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
  <h2>{I18n(`create a new ${entityTypeNameBySingularType[type] || 'entity'}`)}</h2>
  {#if canChangeType}
    <EntityTypePicker bind:selectedType={type} />
  {/if}

  {#if type}
    {#if !hasMonolingualTitle}
      <LabelsEditor
        bind:entity
        inputLabel={label}
      />
    {/if}

    {#if typePropertiesPerCategory}
      <ul>
        <!-- Fully regenerate block on type change to get type-specific custom labels -->
        {#key type}
          {#if showAllProperties}
            {#each Object.entries(typePropertiesPerCategory) as [ category, categoryProperties ]}
              <PropertyCategory
                {entity}
                {category}
                {categoryProperties}
                {requiredProperties}
              />
            {/each}
          {:else}
            {#each propertiesShortlist as property (property)}
              <PropertyClaimsEditor
                bind:entity
                {property}
                required={requiredProperties.includes(property)}
              />
            {/each}
          {/if}
        {/key}
      </ul>
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
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .column{
    @include display-flex(column, stretch, center);
    max-inline-size: 50em;
    margin: 0 auto;
    :global(.wrap-toggler){
      margin-block-end: 1em;
    }
  }
  h2{
    text-align: center;
    margin-block-start: 0.5em;
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
