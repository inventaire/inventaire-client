<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { BubbleUpComponentEvent } from '#app/lib/svelte/svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { propertiesEditorsConfigs } from '#entities/lib/properties'

  export let currentValue, property, valueLabel, entity

  const { allowEntityCreation, entityValueTypes } = propertiesEditorsConfigs[property]
  const createOnWikidata = entity.uri?.startsWith('wd:')

  const createdEntityType = entityValueTypes?.[0]

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)
</script>

<!-- TODO: allow to select which entity type to use when entityValueTypes.length > 1 -->
<EntityAutocompleteSelector
  searchTypes={entityValueTypes}
  currentEntityUri={currentValue}
  currentEntityLabel={valueLabel}
  relationSubjectEntity={entity}
  relationProperty={property}
  {allowEntityCreation}
  {createOnWikidata}
  {createdEntityType}
  on:select={e => dispatch('save', e.detail.uri)}
  on:close={bubbleUpComponentEvent}
  on:error={bubbleUpComponentEvent}
/>
