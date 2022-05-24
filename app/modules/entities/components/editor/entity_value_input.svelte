<script>
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { createEventDispatcher } from 'svelte'
  import { BubbleUpComponentEvent } from '#lib/svelte'
  import properties from '#entities/lib/properties'

  export let currentValue, property, valueLabel, entity

  const { searchType, allowEntityCreation, entityTypeName } = properties[property]
  const createOnWikidata = entity.uri?.startsWith('wd:')

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)
</script>

<EntityAutocompleteSelector
  searchTypes={searchType}
  currentEntityUri={currentValue}
  currentEntityLabel={valueLabel}
  relationSubjectEntity={entity}
  relationProperty={property}
  {allowEntityCreation}
  {createOnWikidata}
  createdEntityTypeName={entityTypeName}
  on:select={e => dispatch('save', e.detail.uri)}
  on:close={bubbleUpComponentEvent}
  on:error={bubbleUpComponentEvent}
/>
