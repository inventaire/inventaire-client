import { property, values } from 'underscore'
import { arrayIncludes } from '#app/lib/utils.ts'
import type { PropertyUri } from '#server/types/entity'
import { propertiesEditorsConfigs } from './properties.ts'

const graphRelationEditorType = [ 'entity', 'fixed-entity' ]

export const graphRelationsProperties: PropertyUri[] = values(propertiesEditorsConfigs)
  .filter(prop => arrayIncludes(graphRelationEditorType, prop.datatype))
  .map(property('property'))
