import { compact, difference, uniq } from 'underscore'
import { getEntities } from '#app/modules/entities/lib/entities'
import { defaultWorkP31PerSerieP31 } from '#entities/components/lib/claims_helpers'
import type { EntityUri, SerializedEntity } from '#server/types/entity'
import { getPropertyValuesShortlist } from './property_values_shortlist'

export default async function ({ entity }: { entity: SerializedEntity }) {
  const values = getPropertyValuesShortlist({ property: 'wdt:P31', type: entity.type })
  if (entity.type === 'work' && entity.claims['wdt:P179']) {
    const seriesUris = entity.claims['wdt:P179']
    const series = await getEntities(seriesUris)
    const seriesP31 = uniq(series.flatMap(serie => serie.claims['wdt:P31']))
    const inheritedP31 = compact(seriesP31.map(uri => defaultWorkP31PerSerieP31[uri]))
    return [
      ...inheritedP31,
      ...difference(values, inheritedP31),
    ] as EntityUri[]
  } else {
    return values
  }
}
