import { newError } from '#app/lib/error'
import { getIsbnData } from '#app/lib/isbn'
import log_ from '#app/lib/loggers'
import { objectEntries } from '#app/lib/utils'
import { isNonEmptyClaimValue } from '#entities/components/editor/lib/editors_helpers'
import { allowedValuesPerTypePerProperty } from '#entities/components/editor/lib/suggestions/property_values_shortlist'
import getOriginalLang from '#entities/lib/get_original_lang'
import type { PropertyUri, SimplifiedClaims } from '#server/types/entity'
import { mainUser } from '#user/lib/main_user'
import { createEntity, type EntityDraftWithCreationParams } from './create_entity.ts'
import { getPluralType } from './entities.ts'
import { propertiesEditorsConfigs } from './properties.ts'

function getTitleFromWork ({ workLabels, workClaims, editionLang }) {
  const inEditionLang = workLabels[editionLang]
  if (inEditionLang != null) return inEditionLang

  const inUserLang = workLabels[mainUser.lang]
  if (inUserLang != null) return inUserLang

  const originalLang = getOriginalLang(workClaims)
  const inWorkOriginalLang = workLabels[originalLang]
  if (inWorkOriginalLang != null) return inWorkOriginalLang

  const inEnglish = workLabels.en
  if (inEnglish != null) return inEnglish

  return Object.values(workLabels)[0]
}

export async function createWorkEditionDraft ({ workEntity, isbn }) {
  const { labels: workLabels, claims: workClaims, uri: workUri, label } = workEntity

  const claims: SimplifiedClaims = {
    // instance of (P31) -> edition (Q3331189)
    'wdt:P31': [ 'wd:Q3331189' ],
    // edition or translation of (P629) -> created book
    'wdt:P629': [ workUri ],
  }

  let title, editionLang
  if (isbn) {
    const { isbn13h, title: isbnDataTitle, image, groupLang } = await getIsbnData(isbn)

    editionLang = groupLang

    if (isbnDataTitle) {
      title = isbnDataTitle
      log_.info(title, 'title from isbn data')
    }

    // isbn 13 (isbn 10 - if it exist - will be added by the server)
    claims['wdt:P212'] = [ isbn13h ]

    if (image != null) {
      claims['invp:P2'] = [ image ]
    }
  }
  // if workEntity has been formatted already, use the label as title
  // known case: autocomplete editor suggestion (which do not have `labels` key)
  if (label) title = label
  if (!title) title = getTitleFromWork({ workLabels, workClaims, editionLang })
  if (title == null) throw newError('no title could be found', workEntity)
  claims['wdt:P1476'] = [ title ]
  return { labels: {}, claims }
}

export async function createByProperty (options) {
  let { property, name, relationSubjectEntity, createOnWikidata, lang } = options
  if (!lang) lang = mainUser.lang

  const wdtP31 = getPropertyDefaultSubjectEntityP31(property)
  if (wdtP31 == null) {
    throw newError('no entity creation function associated to this property', options)
  }

  const claims = { 'wdt:P31': [ wdtP31 ] }

  let labels
  if (property === 'wdt:P195') {
    labels = {}
    claims['wdt:P1476'] = [ name ]
  } else {
    labels = { [lang]: name }
  }

  if (property === 'wdt:P179') {
    claims['wdt:P50'] = relationSubjectEntity.claims['wdt:P50']
  }

  if (property === 'wdt:P195') {
    claims['wdt:P123'] = relationSubjectEntity.claims['wdt:P123']
    if (claims['wdt:P123'] == null) {
      throw newError('a publisher should be set before creating a collection', options)
    }
  }

  return createAndGetEntity({ labels, claims, createOnWikidata } as EntityDraftWithCreationParams)
}

function getPropertyDefaultSubjectEntityP31 (property: PropertyUri) {
  const { entityValueTypes } = propertiesEditorsConfigs[property]
  const entityValueType = getPluralType(entityValueTypes[0])
  return allowedValuesPerTypePerProperty['wdt:P31'][entityValueType][0]
}

export async function createAndGetEntity (params: EntityDraftWithCreationParams) {
  const { claims } = params
  cleanupClaims(claims)
  return createEntity(params)
}

function cleanupClaims (claims: SimplifiedClaims) {
  for (const [ property, propertyClaims ] of objectEntries(claims)) {
    // @ts-expect-error
    claims[property] = propertyClaims.filter(isNonEmptyClaimValue)
  }
}
