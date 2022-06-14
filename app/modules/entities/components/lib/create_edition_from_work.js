import { i18n } from '#user/lib/i18n'
import { createWorkEditionDraft } from '#entities/lib/create_entities'
import createEntity from '#entities/lib/create_entity'
import { normalizeIsbn } from '#lib/isbn'
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
