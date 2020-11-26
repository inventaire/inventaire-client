import preq from 'lib/preq'

const cache = {}

export default async function (entity) {
  const type = entity.pluralizedType
  if (cache[type]) {
    return Promise.resolve(cache[type])
  } else {
    const res = await preq.get(app.API.data.entityTypeAliases(type))
    const aliases = res['entity-type-aliases']
    cache[type] = aliases
    return aliases
  }
}
