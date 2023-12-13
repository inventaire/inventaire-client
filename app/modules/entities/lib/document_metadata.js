import { getEntityImageUrl } from '#entities/lib/entities'
import { typesString } from '#entities/models/entity'
import { I18n } from '#user/lib/i18n'

export async function runEntityNavigate (entity, options = {}) {
  const { uriPrefix } = options
  const { uri } = entity
  entity._gettingMetadata = entity._gettingMetadata || getEntityMetadata({ entity, uriPrefix })
  const metadata = await entity._gettingMetadata
  app.navigate(`/entity/${uri}`, { metadata })
}

async function getEntityMetadata ({ entity, uriPrefix }) {
  const { uri, type } = entity
  let url = 'entity/'
  url += uriPrefix ? `${uriPrefix}${entity.uri}` : entity.uri
  let image = entity.image?.url || entity.images?.[0]
  if (!image && (type === 'work' || type === 'serie')) {
    image = await getEntityImageUrl(uri)
  }
  return {
    title: buildTitle(entity),
    description: findBestDescription(entity)?.slice(0, 501),
    image,
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
