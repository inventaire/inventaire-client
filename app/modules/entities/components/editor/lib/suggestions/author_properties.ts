import { difference, uniq } from 'underscore'
import { getEntities } from '#app/modules/entities/lib/entities'
import type { AuthorProperty } from '#app/modules/entities/lib/properties'
import { getSerieOrWorkExtendedAuthorsUris } from '#app/modules/entities/lib/types/serie_alt'
import type { SerializedEntity } from '#server/types/entity'

export async function authorProperty ({ entity, property }: { entity: SerializedEntity, property: AuthorProperty }) {
  const seriesUri = entity.claims['wdt:P179']
  if (seriesUri == null) return
  let series = await getEntities(seriesUri)
  series = series.filter(serie => serie.type === 'serie')
  if (series.length === 0) return
  const samePropertyAuthorsUris = entity.claims[property] || []
  const otherPropertiesAuthorsUris = getSerieOrWorkExtendedAuthorsUris(entity, property)
  const otherAuthorsUris = difference(otherPropertiesAuthorsUris, samePropertyAuthorsUris)
  const authorsUris = [ ...samePropertyAuthorsUris, ...otherPropertiesAuthorsUris ]
  const seriesSamePropertyAuthorsUris = uniq(series.flatMap(serie => serie.claims[property] || []))
  const seriesOtherPropertiesAuthorsUris = uniq(series.flatMap(serie => getSerieOrWorkExtendedAuthorsUris(serie, property)))
  const missingSeriesAuthorsOnSameProperty = difference(seriesSamePropertyAuthorsUris, authorsUris)
  const missingSeriesAuthorsOnOtherProperties = difference(seriesOtherPropertiesAuthorsUris, authorsUris)
  return uniq(missingSeriesAuthorsOnSameProperty.concat(otherAuthorsUris, missingSeriesAuthorsOnOtherProperties))
}
