import app from '#app/app'
import { getEntityImageUrl, type SerializedEntity } from '#entities/lib/entities'
import { I18n } from '#user/lib/i18n'
import { typesString } from './types/entities_types'

export async function runEntityNavigate (entity: SerializedEntity, options: { uriPrefix?: string } = {}) {
  entity._gettingMetadata ??= getEntityMetadata(entity, options.uriPrefix)
  const metadata = await entity._gettingMetadata
  app.navigate(`/${metadata.url}`, { metadata })
}

async function getEntityMetadata (entity: SerializedEntity, uriPrefix?: string) {
  const { uri, type } = entity
  let url = 'entity/'
  url += uriPrefix ? `${uriPrefix}${entity.uri}` : entity.uri
  let image = entity.image?.url || entity.images?.[0]
  if (!image && (type === 'work' || type === 'serie')) {
    image = await getEntityImageUrl(uri)
  }
  return {
    title: buildTitle(entity),
    description: entity.description?.slice(0, 501),
    image,
    url,
    smallCardType: true,
  }
}

function buildTitle (entity: SerializedEntity) {
  const { type, label, claims } = entity
  const P31 = claims['wdt:P31']?.[0]
  const typeLabel = I18n(typesString[P31] || type)
  return `${label} - ${typeLabel}`
}
