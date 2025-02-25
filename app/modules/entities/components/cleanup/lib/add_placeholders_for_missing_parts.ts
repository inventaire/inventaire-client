import { pluck } from 'underscore'
import { arrayIncludes } from '#app/lib/utils'
import type { SerializedEntity } from '#app/modules/entities/lib/entities'
import type { EntityUri, EntityValue, SimplifiedClaims } from '#server/types/entity'

export interface SeriePartPlaceholder {
  type: 'work'
  label: string
  claims: SimplifiedClaims
  serieOrdinalNum: number
  isPlaceholder: true
}

export function addPlaceholdersForMissingParts (worksWithOrdinal: (SerializedEntity | SeriePartPlaceholder)[], serieUri: EntityUri, serieLabel: string, titlePattern: string, titleKey: string, numberKey: string, partsNumber: number) {
  const existingOrdinals = pluck(worksWithOrdinal, 'serieOrdinalNum')
  const end = Math.max(...existingOrdinals, partsNumber)
  if (end < 1) return worksWithOrdinal
  const getPlaceholderTitle = (index: number) => getSeriePlaceholderTitle(serieLabel, titlePattern, titleKey, numberKey, index)
  const newPlaceholders = []
  for (let i = 1; i <= end; i++) {
    if (!arrayIncludes(existingOrdinals, i)) newPlaceholders.push(getPlaceholder(i, serieUri, getPlaceholderTitle))
  }
  return worksWithOrdinal.concat(newPlaceholders).sort((a, b) => a.serieOrdinalNum - b.serieOrdinalNum)
}

function getPlaceholder (index: number, serieUri: EntityUri, getPlaceholderTitle) {
  const label = getPlaceholderTitle(index)
  const claims = {
    'wdt:P179': [ serieUri as EntityValue ],
    'wdt:P1545': [ `${index}` as `${number}` ],
  }
  const placeholder: SeriePartPlaceholder = {
    type: 'work',
    label,
    claims,
    serieOrdinalNum: index,
    isPlaceholder: true,
  }
  return placeholder
}

export function getSeriePlaceholderTitle (serieLabel: string, titlePattern: string, titleKey: string, numberKey: string, ordinal: number) {
  return titlePattern
  .replace(titleKey, serieLabel)
  .replace(numberKey, ordinal.toString())
}
