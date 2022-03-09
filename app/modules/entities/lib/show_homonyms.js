import preq from '#lib/preq'
import Entities from '../collections/entities.js'
import loader from '#general/views/templates/loader.hbs'

export default async params => {
  if (!app.user.hasDataadminAccess) return
  const { layout, regionName, model, standalone } = params
  layout.getRegion(regionName).$el.html(loader())

  const [ entities, { default: MergeHomonyms } ] = await Promise.all([
    getHomonyms(model),
    import('../views/editor/merge_homonyms')
  ])
  const collection = new Entities(entities)
  layout.showChildView(regionName, new MergeHomonyms({ collection, model, standalone }))
}

const getHomonyms = async model => {
  const [ uri, label ] = model.gets('uri', 'label')
  const { pluralizedType } = model
  const { results } = await preq.get(app.API.search({
    types: pluralizedType,
    search: label,
    limit: 100,
    exact: true
  }))
  return parseSearchResults(uri, results)
}

const parseSearchResults = async (uri, searchResults) => {
  const uris = _.pluck(searchResults, 'uri')
  // Search results entities miss their claims, so we need to fetch the full entities
  const entities = await app.request('get:entities:models', { uris })
  // Re-filter out uris to omit as a redirection might have brought it back
  return entities.filter(entity => entity.get('uri') !== uri)
}
