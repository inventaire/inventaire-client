import preq from '#lib/preq'
import Entities from '../collections/entities.js'
import loader from '#general/views/templates/loader.hbs'
import getBestLangValue from './get_best_lang_value'

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
  const [ uri, labels, aliases ] = model.gets('uri', 'labels', 'aliases')
  const terms = getSearchTermsSelection(labels, aliases)
  const { pluralizedType } = model
  const responses = await Promise.all(terms.map(searchTerm(pluralizedType)))
  const results = _.pluck(responses, 'results').flat()
  return parseSearchResults(uri, results)
}

const searchTerm = types => term => {
  return preq.get(app.API.search({
    types,
    search: term,
    limit: 100,
    exact: true
  }))
}

const parseSearchResults = async (uri, searchResults) => {
  const uris = _.uniq(_.pluck(searchResults, 'uri'))
    .filter(result => result.uri !== uri)
  // Search results entities miss their claims, so we need to fetch the full entities
  const entities = await app.request('get:entities:models', { uris })
  // Re-filter out uris to omit as a redirection might have brought it back
  return entities.filter(entity => entity.get('uri') !== uri)
}

const getSearchTermsSelection = (labels, aliases) => {
  let terms = getTerms(labels, aliases)
  if (terms.length > 10) {
    const { lang: bestAvailableLang } = getBestLangValue(app.user.lang, null, labels)
    const langsShortlist = _.uniq([ bestAvailableLang, 'en' ])
    labels = _.pick(labels, langsShortlist)
    aliases = _.pick(aliases, langsShortlist)
    return getTerms(labels, aliases).slice(0, 10)
  } else {
    return terms
  }
}

const getTerms = (labels, aliases) => {
  let terms = Object.values(labels)
    .concat(Object.values(aliases).flat())
    // Order term words to not search both "foo bar" and "bar foo"
    // as words order doesn't matter
    .map(orderTermWordsAlphabetically)
  return _.uniq(terms)
}

const orderTermWordsAlphabetically = term => {
  return term
  .toLowerCase()
  // Remove characters known to create duplicates
  .replace(/[.]/g, '')
  .split(' ')
  .sort((a, b) => a > b ? 1 : -1)
  .join(' ')
}
