import { property, values } from 'underscore'
import { propertiesEditorsConfigs } from './properties.ts'

const graphRelationEditorType = [ 'entity', 'fixed-entity' ]

export default values(propertiesEditorsConfigs)
  .filter(prop => graphRelationEditorType.includes(prop.datatype))
  .map(property('property'))
