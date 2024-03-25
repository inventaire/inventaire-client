import { buildPath } from '#lib/location'

export function searchWikidataEntities (params) {
  const { search, limit, offset } = params

  if (search?.length <= 0) throw new Error("search can't be empty")

  const { lang } = app.user

  return buildPath('https://www.wikidata.org/w/api.php', {
    action: 'wbsearchentities',
    search,
    language: lang,
    uselang: lang,
    limit,
    continue: offset,
    format: 'json',
    origin: '*',
  })
}

// Unprefixify both entities ('item' in Wikidata lexic) and properties
export const unprefixify = value => value?.replace(/^wdt?:/, '')

export const getUriNumericId = uri => parseInt(uri.split(':')[1].substring(1))
