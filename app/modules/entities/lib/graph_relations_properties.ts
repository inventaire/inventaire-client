import { property, values } from 'underscore'
import { propertiesEditorsConfigs } from './properties.js'
const graphRelationEditorType = [ 'entity', 'fixed-entity' ]

export default values(propertiesEditorsConfigs)
  .filter(prop => graphRelationEditorType.includes(prop.datatype))
  .map(property('property'))
