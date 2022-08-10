import wdLang from 'wikidata-lang'
import { getEntitiesAttributesByUris } from '#entities/lib/entities'
import { getEntityLang } from '#entities/components/lib/claims_helpers'
import { compact, uniq } from 'underscore'

async function fetchEntitiesLabels (uris) {
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'labels' ],
    lang: app.user.lang
  })
  return entities
}

const getLangWdUri = lang => {
  const langWdId = wdLang.byCode[lang]?.wd
  if (langWdId) return `wd:${langWdId}`
}

const prioritizeMainUserLang = langs => {
  let userLang = app.user.lang
  if (langs.includes(userLang)) {
    const userLangIndex = langs.indexOf(userLang)
    langs.splice(userLangIndex, 1)
    langs.unshift(userLang)
  }
  return langs
}

export async function getLangEntities (editions) {
  const rawEditionsLangs = _.compact(_.uniq(editions.map(getEntityLang)))
  const editionsLangs = prioritizeMainUserLang(rawEditionsLangs)
  const langsUris = _.compact(editionsLangs.map(getLangWdUri))
  const entities = await fetchEntitiesLabels(langsUris)
  const langEntitiesLabel = {}
  editionsLangs.forEach(lang => {
    const langWdId = getLangWdUri(lang)
    if (langWdId) langEntitiesLabel[lang] = entities[langWdId]
  })
  return { editionsLangs, langEntitiesLabel }
}

export async function getPublishersEntities (editions) {
  const rawPublishersUris = _.uniq(editions.flatMap(getPublisherUri))
  const publishersUris = _.compact(rawPublishersUris)
  const someEditionsHaveNoPublisher = rawPublishersUris.length !== publishersUris.length
  const publishers = await fetchEntitiesLabels(publishersUris)
  const publishersLabels = {}
  Object.values(publishers).forEach(publisher => {
    publishersLabels[publisher.uri] = Object.values(publisher.labels)[0]
  })
  return { publishersUris, publishersLabels, someEditionsHaveNoPublisher }
}

const getPublisherUri = edition => edition.claims['wdt:P123']

export const hasPublisher = publisherUri => edition => {
  if (publisherUri === 'unknown') {
    return edition.claims['wdt:P123'] == null
  } else {
    return edition.claims['wdt:P123']?.includes(publisherUri)
  }
}

export function getPublicationYears (editions) {
  const years = editions.map(getPublicationYear).flat()
  const someEditionsHaveNoPublicationDate = compact(years).length !== years.length
  return {
    publicationYears: uniq(compact(years)).sort(antiChronologically),
    someEditionsHaveNoPublicationDate,
  }
}

const getPublicationYear = edition => {
  const date = edition.claims['wdt:P577']?.[0]
  if (date) return date.split('-')[0]
}

const antiChronologically = (a, b) => parseInt(b) - parseInt(a)

export const hasPublicationYear = year => edition => {
  if (year === 'unknown') {
    return getPublicationYear(edition) == null
  } else {
    return getPublicationYear(edition) === year
  }
}
