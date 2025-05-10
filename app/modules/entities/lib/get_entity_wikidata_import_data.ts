import { isWikidataItemUri, isWikidataPropertyUri } from '#app/lib/boolean_tests'
import { objectEntries } from '#app/lib/utils'
import { getPropertyDatatype } from '#entities/lib/editor/properties_per_type'
import { getEntitiesByUris, type SerializedEntity } from '#entities/lib/entities'
import type { ClaimValueTypeByDatatype, EntityUri, WdPropertyUri, WdEntityUri } from '#server/types/entity'
import type { PropertyDatatype } from '#server/types/property'
import type { WikimediaLanguageCode } from 'wikibase-sdk'

interface ImportedClaim <T extends PropertyDatatype = PropertyDatatype> {
  property: WdPropertyUri
  value: ClaimValueTypeByDatatype[T]
  datatype: T
  checked: boolean
}

export interface InvEntityImportableData {
  labels: { lang: WikimediaLanguageCode, label: string, checked: boolean }[]
  claims: ImportedClaim[]
  invEntity: SerializedEntity
  wdEntity: SerializedEntity
  total: number
}

export async function getInvEntityImportableData (invEntityUri: EntityUri, wdEntityUri: WdEntityUri) {
  const entities = await getEntitiesByUris({ uris: [ invEntityUri, wdEntityUri ], refresh: true })
  const invEntity = entities[invEntityUri]
  const wdEntity = entities[wdEntityUri]

  const importData: InvEntityImportableData = {
    labels: [],
    claims: [],
    invEntity,
    wdEntity,
    total: 0,
  }

  for (const [ lang, label ] of objectEntries(invEntity.labels)) {
    if (wdEntity.labels[lang] == null && wdEntity.labels.mul !== label) {
      importData.labels.push({ lang: lang as WikimediaLanguageCode, label, checked: true })
    }
  }

  for (const [ property, propertyClaims ] of objectEntries(invEntity.claims)) {
    if (isWikidataPropertyUri(property) && !ignoredProperties.includes(property)) {
      const datatype = getPropertyDatatype(property)
      for (const value of propertyClaims) {
        if (datatype === 'entity') {
          // Links to Inventaire entities can't be imported to Wikidata
          if (isWikidataItemUri(value)) importData.claims.push({ property, value, datatype, checked: true })
        } else {
          importData.claims.push({ property, value, datatype, checked: true })
        }
      }
    }
  }

  importData.total = importData.labels.length + importData.claims.length

  return importData
}

const ignoredProperties = [
  'wdt:P31',
]
