import { uniq, compact, values } from 'underscore'
import { getWdUriFromWikimediaLanguageCode } from '#app/lib/languages/languages'
import { getCachedWdUriFromWikimediaLanguageCode, getWikimediaLanguageCodesFromWdUris } from '#app/lib/languages/languages_indexes'
import { getEntityLang, getEntityLangUris } from '#entities/components/lib/claims_helpers'
import { getEntitiesAttributesByUris, getPublicationYear } from '#entities/lib/entities'
import { getCurrentLang } from '#modules/user/lib/i18n'

async function fetchEntitiesLabels (uris) {
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'labels' ],
    lang: getCurrentLang(),
  })
  return entities
}

const prioritizeMainUserLang = langs => {
  const userLang = getCurrentLang()
  if (langs.includes(userLang)) {
    const userLangIndex = langs.indexOf(userLang)
    langs.splice(userLangIndex, 1)
    langs.unshift(userLang)
  }
  return langs
}

export async function getLangEntities (editions) {
  const editionsLanguagesUris = compact(uniq(editions.flatMap(getEntityLangUris)))
  const editionsLangsByUris = await getWikimediaLanguageCodesFromWdUris(editionsLanguagesUris)
  const rawEditionsLangs = values(editionsLangsByUris)
  const editionsLangs = prioritizeMainUserLang(rawEditionsLangs)
  // Not using getLanguagesLabels as it might include languages without a Wikimedia language code
  const entities = await fetchEntitiesLabels(editionsLanguagesUris)
  const langEntitiesLabel = {}
  editionsLangs.forEach(lang => {
    const languageUri = getCachedWdUriFromWikimediaLanguageCode(lang)
    if (languageUri && entities[languageUri]) {
      langEntitiesLabel[lang] = Object.values(entities[languageUri].labels)[0]
    }
  })
  return { editionsLangs, langEntitiesLabel }
}

export async function getPublishersEntities (editions) {
  const rawPublishersUris = uniq(editions.flatMap(getPublisherUri))
  const publishersUris = compact(rawPublishersUris)
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

const antiChronologically = (a, b) => parseInt(b) - parseInt(a)

export const hasPublicationYear = year => edition => {
  if (year === 'unknown') {
    return getPublicationYear(edition) == null
  } else {
    return getPublicationYear(edition) === year
  }
}
