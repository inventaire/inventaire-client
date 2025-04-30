<script lang="ts">
  import { pick } from 'underscore'
  import { isEntityUri } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import { someMatch } from '#app/lib/utils'
  import { commands } from '#app/radio'
  import type { EntityDraft } from '#app/types/entity'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import EntityTypePicker from '#entities/components/editor/entity_type_picker.svelte'
  import { getMissingRequiredProperties, getPropertiesShortlist, removeNonTypeProperties } from '#entities/components/editor/lib/create_helpers'
  import { getTypePropertiesPerCategory } from '#entities/components/editor/lib/editors_properties'
  import { getPropertyValuesShortlist } from '#entities/components/editor/lib/suggestions/property_values_shortlist'
  import PropertyCategory from '#entities/components/editor/property_category.svelte'
  import { createAndGetEntity } from '#entities/lib/create_entities'
  import { propertiesPerType, requiredPropertiesPerType } from '#entities/lib/editor/properties_per_type'
  import { entityTypeNameBySingularType, typeDefaultP31, typesPossessiveForms } from '#entities/lib/types/entities_types'
  import type { EntityType, SimplifiedClaims } from '#server/types/entity'
  import { i18n, I18n } from '#user/lib/i18n'
  import { getEntityLabel } from '../../lib/entities'
  import LabelsEditor from './labels_editor.svelte'
  import PropertyClaimsEditor from './property_claims_editor.svelte'

  export let label: string = ''
  export let type: EntityType = null
  export let claims: SimplifiedClaims = null

  const canChangeType = !(type && claims)

  let showAllProperties = false, flash
  let typeProperties, typePropertiesPerCategory, propertiesShortlist, hasMonolingualTitle, createAndShowLabel, requiresLabel, requiredProperties
  let entity: EntityDraft = {
    type,
    labels: {},
    claims: claims || {},
  }

  function updatePropertiesList () {
    if (!type) return
    typeProperties = propertiesPerType[type]
    typePropertiesPerCategory = getTypePropertiesPerCategory(entity)
    removeNonTypeProperties(entity.claims, typeProperties)
    hasMonolingualTitle = typeProperties['wdt:P1476'] != null
    requiresLabel = !hasMonolingualTitle
    const typeP31values = getPropertyValuesShortlist({ type: entity.type, property: 'wdt:P31' })
    if (!someMatch(entity.claims['wdt:P31'], typeP31values)) {
      entity.claims['wdt:P31'] = [ typeDefaultP31[type] ]
    }
    propertiesShortlist = getPropertiesShortlist(entity)
    requiredProperties = requiredPropertiesPerType[type] || []
  }

  function onTypeChange () {
    flash = null
    entity.type = type
    updatePropertiesList()
    const typePossessive = typesPossessiveForms[type]
    createAndShowLabel = `create and go to the ${typePossessive} page`
    showAllProperties = false
    commands.execute('querystring:set', 'type', type)
  }

  $: if (type) onChange(type, onTypeChange)

  let missingRequiredProperties
  function onEntityChange () {
    updatePropertiesList()
    if (requiredProperties == null) return
    missingRequiredProperties = getMissingRequiredProperties({ entity, requiredProperties, requiresLabel })
    if (missingRequiredProperties.length > 0) {
      flash = {
        type: 'info',
        message: `${I18n('required properties are missing')}: ${missingRequiredProperties.join(', ')}`,
      }
    } else if (flash?.type === 'info') {
      flash = null
    }
  }

  $: if (entity) onChange(entity, onEntityChange)

  async function createAndShowEntity () {
    try {
      // entity.claims might still contain values that were entered
      // while `type` was set to another value
      // 'wdt:P31' might be missing in typeProperties, but is always required
      // TODO: include 'wdt:P31' in all typeProperties
      const propertiesToKeep = [ 'wdt:P31', ...Object.keys(typeProperties) ]
      entity.claims = pick(entity.claims, propertiesToKeep)
      const { uri } = await createAndGetEntity(entity)
      commands.execute('show:entity', uri)
    } catch (err) {
      if (err.message.includes('invalid claim value') && err.responseJSON.context) {
        const { value, property } = err.responseJSON.context
        err.message += `. ${i18n('Problematic claim')}: ${i18n(property)} (${property})=`
        if (isEntityUri(value)) {
          const { label } = await getEntityLabel(value)
          err.message += `${label} (${value})`
        } else {
          err.message += `${value}`
        }
      }
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
      <!-- Fully regenerate block on type change to get type-specific custom labels -->
      {#key type}
        {#if showAllProperties}
          {#each Object.entries(typePropertiesPerCategory) as [ category, categoryProperties ]}
            <PropertyCategory
              bind:entity
              {category}
              {categoryProperties}
              {requiredProperties}
            />
          {/each}
        {:else if propertiesShortlist}
          {#each propertiesShortlist as property (property)}
            <PropertyClaimsEditor
              bind:entity
              {property}
              required={requiredProperties.includes(property)}
            />
          {/each}
        {/if}
      {/key}
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
