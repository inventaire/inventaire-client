import { API } from '#app/api/api'
import { newError, type ContextualizedError } from '#app/lib/error'
import { looksLikeAnIsbn, normalizeIsbn } from '#app/lib/isbn'
import { getWdUriFromWikimediaLanguageCode } from '#app/lib/languages/languages'
import { buildPath } from '#app/lib/location'
import preq from '#app/lib/preq'
import { getEntityPropValue } from '#entities/components/lib/claims_helpers'
import { createWorkEditionDraft } from '#entities/lib/create_entities'
import { createEntity } from '#entities/lib/create_entity'
import type { SerializedEntity } from '#entities/lib/entities'
import type { EntityUri } from '#server/types/entity'
import { getCurrentLang, i18n } from '#user/lib/i18n'

export async function createEditionFromWork (params) {
  const { workEntity, userInput } = params

  const isbn = normalizeIsbn(userInput)

  const { labels, claims } = await createWorkEditionDraft({ workEntity, isbn })
  try {
    const entity = await createEntity({ labels, claims })
    return entity
  } catch (err) {
    renameIsbnDuplicateErr(workEntity.uri, userInput, err)
  }
}

export function renameIsbnDuplicateErr (workUri: EntityUri, isbn: string, err: ContextualizedError) {
  if (err.responseJSON == null) throw err
  const statusMessage = err.responseJSON.status_verbose as string
  if (statusMessage.includes('this property value is already used')) {
    reportIsbnIssue(workUri, isbn)
    formatDuplicateWorkErr(err, isbn)
  }
  throw err
}

async function reportIsbnIssue (workUri: EntityUri, isbn: string) {
  const params = { uri: workUri, isbn }
  return preq.post(API.tasks.deduplicateWorks, params)
}

function formatDuplicateWorkErr (err: ContextualizedError, isbn: string) {
  const normalizedIsbn = normalizeIsbn(isbn)
  const alreadyExist = i18n('this ISBN already exist:')
  const link = `<a href='/entity/isbn:${normalizedIsbn}' class='showEntity'>${normalizedIsbn}</a>`
  const reported = i18n('the issue was reported')
  err.html = `${alreadyExist} ${link} (${reported})`
  err.message = alreadyExist
}

export function validateEditionPossibility (userInput: string, editions: SerializedEntity[]) {
  if (!looksLikeAnIsbn(userInput)) {
    throw newError(`invalid isbn: ${userInput}`, 400, { userInput, editions })
  }
  const isbn = normalizeIsbn(userInput)
  if (editions.map(getNormalizedIsbn).includes(isbn)) {
    throw newError('this edition is already in the list', 400, { isbn, editions })
  }
}

function getNormalizedIsbn (edition: SerializedEntity) {
  const isbn = getEntityPropValue(edition, 'wdt:P212')
  if (isbn) return normalizeIsbn(isbn)
}

export function addWithoutIsbnPath (work: SerializedEntity) {
  return buildPath('/entity/new', workEditionCreationData(work))
}

function workEditionCreationData (work: SerializedEntity) {
  const data = {
    type: 'edition',
    claims: {
      'wdt:P629': [ work.uri ],
    },
  }
  const lang = getCurrentLang()
  const langWdUri = getWdUriFromWikimediaLanguageCode(lang)
  // Suggest user's language as edition language
  if (langWdUri) data.claims['wdt:P407'] = [ langWdUri ]

  // Suggest work label in user's language as edition title
  const { label } = work
  if (label) data.claims['wdt:P1476'] = [ label ]

  return data
}
