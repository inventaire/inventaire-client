import { i18n } from 'modules/user/lib/i18n'
import { createWorkEdition } from 'modules/entities/lib/create_entities'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import { normalizeIsbn } from 'lib/isbn'
import isLoggedIn from './is_logged_in'
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'

export default function (params) {
  if (!isLoggedIn()) return
  const { view, work: workModel, e } = params

  const $isbnField = $(e.currentTarget).parent('#isbnGroup').find('#isbnField')
  const isbn = normalizeIsbn($isbnField.val())

  const workUri = workModel.get('uri')

  startLoading.call(view, '#isbnButton')

  return createWorkEdition(workModel, isbn)
  .catch(renameIsbnDuplicateErr(workUri, isbn))
  .then(editionModel => {
    // Special case of property_values collection
    if (view.collection.addByValue != null) {
      view.collection.addByValue(editionModel.get('uri'))
    }
    // In other cases, the model being added to the work edition collection
    // by createWorkEdition is enough
    return $isbnField.val(null)
  })
  .catch(error_.Complete('#isbnField'))
  .catch(forms_.catchAlert.bind(null, view))
  .finally(stopLoading.bind(view))
}

const renameIsbnDuplicateErr = (workUri, isbn) => function (err) {
  if (err.responseJSON?.status_verbose !== 'this property value is already used') { throw err }

  const existingEditionUri = err.responseJSON.context.entity
  return app.request('get:entity:model', existingEditionUri)
  .then(model => {
    const existingEditionWorksUris = model.get('claims.wdt:P629')
    if (existingEditionWorksUris.includes(workUri)) {
      formatEditionAlreadyExistOnCurrentWork(err)
    } else {
      reportIsbnIssue(workUri, isbn)
      formatDuplicateWorkErr(err, isbn)
    }
    throw err
  })
}

const reportIsbnIssue = (workUri, isbn) => app.request('post:feedback', {
  subject: `[Possible work duplicate] ${workUri} / ${isbn}'s work`,
  uris: [ workUri, `isbn:${isbn}` ]
})

const formatEditionAlreadyExistOnCurrentWork = err => {
  err.responseJSON.status_verbose = 'this edition is already in the list'
}

const formatDuplicateWorkErr = function (err, isbn) {
  const normalizedIsbn = normalizeIsbn(isbn)
  const alreadyExist = i18n('this ISBN already exist:')
  const link = `<a href='/entity/isbn:${normalizedIsbn}' class='showEntity'>${normalizedIsbn}</a>`
  const reported = i18n('the issue was reported')
  err.responseJSON.status_verbose = `${alreadyExist} ${link} (${reported})`
  err.i18n = false
}
