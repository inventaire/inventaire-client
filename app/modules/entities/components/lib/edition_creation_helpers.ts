import wdLang from 'wikidata-lang'
import app from '#app/app'
import { newError } from '#app/lib/error'
import { looksLikeAnIsbn, normalizeIsbn } from '#app/lib/isbn'
import { buildPath } from '#app/lib/location'
import preq from '#app/lib/preq'
import { getEntityPropValue } from '#entities/components/lib/claims_helpers'
import { createWorkEditionDraft } from '#entities/lib/create_entities'
import createEntity from '#entities/lib/create_entity'
import isLoggedIn from '#entities/views/editor/lib/is_logged_in.ts'
import { i18n } from '#user/lib/i18n'

export function createEditionFromWork (params) {
  if (!isLoggedIn()) return
  const { workEntity, userInput } = params

  const isbn = normalizeIsbn(userInput)

  return createWorkEditionDraft({ workEntity, isbn })
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
  err.html = `${alreadyExist} ${link} (${reported})`
  err.message = alreadyExist
}

export const validateEditionPossibility = ({ userInput, editions }) => {
  if (!looksLikeAnIsbn(userInput)) {
    throw newError(`invalid isbn: ${userInput}`, 400, { userInput, editions })
  }
  const isbn = normalizeIsbn(userInput)
  if (editions.map(getNormalizedIsbn).includes(isbn)) {
    throw newError('this edition is already in the list', 400, { isbn, editions })
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
      'wdt:P629': [ work.uri ],
    },
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
