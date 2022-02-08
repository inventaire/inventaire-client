<script>
  import properties from 'modules/entities/lib/properties'
  import { editors } from '../lib/editors'
  import { createEventDispatcher } from 'svelte'
  export let entity, property, value
  const dispatch = createEventDispatcher()
  const { uri } = entity
  const { editorType } = properties[property]
  const ValueEditor = editors[editorType]
</script>

<ValueEditor
  {entity} {uri} {property} {value}
  on:set={e => dispatch('set', e.detail)}
/>
