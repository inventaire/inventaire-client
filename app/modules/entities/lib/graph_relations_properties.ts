import { property, values } from 'underscore'
import { arrayIncludes } from '#app/lib/utils.ts'
import { propertiesEditorsConfigs } from './properties.ts'

const graphRelationEditorType = [ 'entity', 'fixed-entity' ] as const

export default values(propertiesEditorsConfigs)
  .filter(prop => arrayIncludes(graphRelationEditorType, prop.datatype))
  .map(property('property'))
