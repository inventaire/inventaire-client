import { buildPath } from '#app/lib/location'
import type { InvPropertyUri, WdEntityId, WdEntityUri, WdPropertyUri } from '#server/types/entity'
import { mainUser } from '#user/lib/main_user'

const wdHost = 'https://www.wikidata.org'

export function searchWikidataEntities (params) {
  const { search, limit, offset } = params

  if (search?.length <= 0) throw new Error("search can't be empty")

  const { lang } = mainUser

  return buildPath(`${wdHost}/w/api.php`, {
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
export const unprefixify = (value: WdPropertyUri) => value?.replace(/^wdt?:/, '')

export const getUriNumericId = (uri: WdEntityUri | WdPropertyUri | InvPropertyUri) => parseInt(uri.split(':')[1].substring(1))

export function getWdWikiUrl (wdId: WdEntityId) {
  if (!wdId) return
  return `${wdHost}/wiki/${wdId}`
}

export function getWdHistoryUrl (wdId: WdEntityId) {
  if (!wdId) return
  return `${wdHost}/w/index.php?title=${wdId}&action=history`
}

export function getWikidataItemMergeUrl (fromUri, toUri?) {
  let fromid = unprefixify(fromUri)
  let toid
  if (toUri) {
    toid = unprefixify(toUri)
    // Recommend to merge the newest item into the oldest
    if (getWikidataItemNumeridIdNumber(toid) > getWikidataItemNumeridIdNumber(fromid)) {
      [ fromid, toid ] = [ toid, fromid ]
    }
  }
  return buildPath(`${wdHost}/wiki/Special:MergeItems`, { fromid, toid })
}

const getWikidataItemNumeridIdNumber = id => parseInt(id.split('Q')[1])
