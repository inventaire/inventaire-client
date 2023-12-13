import { typesString } from '#entities/models/entity'
import { I18n } from '#user/lib/i18n'

export function getEntityMetadata (entity, options = {}) {
  const { uriPrefix } = options
  let url = 'entity/'
  url += uriPrefix ? `${uriPrefix}${entity.uri}` : entity.uri
  return {
    title: buildTitle(entity),
    description: findBestDescription(entity)?.slice(0, 501),
    image: entity.image?.url || entity.images?.[0],
    url,
    smallCardType: true
  }
}

const buildTitle = entity => {
  const { type, label, claims } = entity
  const P31 = claims['wdt:P31']?.[0]
  const typeLabel = I18n(typesString[P31] || type)
  return `${label} - ${typeLabel}`
}

const findBestDescription = entity => {
  // So far, only Wikidata entities get extracts
  const { extract, description } = entity
  // Dont use an extract too short as it will be
  // more of it's wikipedia source url than a description
  if (extract?.length > 300) {
    return extract
  } else {
    return description || extract
  }
}
