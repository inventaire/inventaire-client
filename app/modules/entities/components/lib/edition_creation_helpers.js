import { looksLikeAnIsbn, normalizeIsbn } from '#lib/isbn'
import { getEntityPropValue } from '#entities/components/lib/claims_helpers'
import wdLang from 'wikidata-lang'
import { buildPath } from '#lib/location'
import { i18n } from '#user/lib/i18n'
import { createWorkEditionDraft } from '#entities/lib/create_entities'
import createEntity from '#entities/lib/create_entity'
import isLoggedIn from '#entities/views/editor/lib/is_logged_in.js'
import preq from '#lib/preq'

export function createEditionFromWork (params) {
  if (!isLoggedIn()) return
  const { workEntity, userInput } = params

  const isbn = normalizeIsbn(userInput)

  return createWorkEditionDraft({ workEntity, isbn, editionClaims: {} })
  .then(createEntity)
  .catch(renameIsbnDuplicateErr(workEntity.uri, userInput))
}

export const renameIsbnDuplicateErr = (workUri, isbn) => err => {
  if (err.responseJSON?.status_verbose !== 'this property value is already used') throw err
  reportIsbnIssue(workUri, isbn)
  formatDuplicateWorkErr(err, isbn)
  throw err
}

const reportIsbnIssue = async (workUri, isbn) => {
  const params = { uri: workUri, isbn }
  return preq.post(app.API.tasks.deduplicateWorks, params)
}

const formatDuplicateWorkErr = function (err, isbn) {
  const normalizedIsbn = normalizeIsbn(isbn)
  const alreadyExist = i18n('this ISBN already exist:')
  const link = `<a href='/entity/isbn:${normalizedIsbn}' class='showEntity'>${normalizedIsbn}</a>`
  const reported = i18n('the issue was reported')
  err.message = `${alreadyExist} ${link} (${reported})`
}

export const validateEditionPossibility = ({ userInput, editions }) => {
  if (!looksLikeAnIsbn(userInput)) return 'invalid isbn'
  const isbn = normalizeIsbn(userInput)
  if (editions.map(getNormalizedIsbn).includes(isbn)) {
    return 'this edition is already in the list'
  }
}

const getNormalizedIsbn = edition => {
  const isbn = getEntityPropValue(edition, 'wdt:P212')
  if (isbn) return normalizeIsbn(isbn)
}

export const addWithoutIsbnPath = function (work) {
  if (!work) return {}
  return buildPath('/entity/new', workEditionCreationData(work))
}

const workEditionCreationData = function (work) {
  const data = {
    type: 'edition',
    claims: {
      'wdt:P629': [ work.uri ]
    }
  }
  const { lang } = app.user
  const langWdId = wdLang.byCode[lang]?.wd
  const langWdUri = (langWdId != null) ? `wd:${langWdId}` : undefined
  // Suggest user's language as edition language
  if (langWdUri) data.claims['wdt:P407'] = [ langWdUri ]

  // Suggest work label in user's language as edition title
  const { label } = work
  if (label) data.claims['wdt:P1476'] = [ label ]

  return data
}
