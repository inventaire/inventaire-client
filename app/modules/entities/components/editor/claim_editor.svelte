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
  {uri} {property} {value}
  on:remove={() => dispatch('remove')}
  on:set={e => dispatch('set', e.detail)}
/>
