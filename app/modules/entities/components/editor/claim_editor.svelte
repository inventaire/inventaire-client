<script>
  import properties from 'modules/entities/lib/properties'
  import { editors } from '../lib/editors'
  export let entity, property, value
  const { uri } = entity
  const { editorType } = properties[property]
  const ValueEditor = editors[editorType]
</script>

<ValueEditor {uri} {property} {value} />
