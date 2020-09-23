/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import createEntities from 'modules/entities/lib/create_entities'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import isbn_ from 'lib/isbn'
import isLoggedIn from './is_logged_in'
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'

export default function (params) {
  if (!isLoggedIn()) { return }
  const { view, work: workModel, e } = params

  const $isbnField = $(e.currentTarget).parent('#isbnGroup').find('#isbnField')
  const isbn = isbn_.normalizeIsbn($isbnField.val())

  const workUri = workModel.get('uri')

  startLoading.call(view, '#isbnButton')

  return createEntities.workEdition(workModel, isbn)
  .catch(renameIsbnDuplicateErr(workUri, isbn))
  .then(editionModel => {
    // Special case of property_values collection
    if (view.collection.addByValue != null) {
      view.collection.addByValue(editionModel.get('uri'))
    }
    // In other cases, the model being added to the work edition collection
    // by createEntities.workEdition is enough
    return $isbnField.val(null)
  }).catch(error_.Complete('#isbnField'))
  .catch(forms_.catchAlert.bind(null, view))
  .finally(stopLoading.bind(view))
};

var renameIsbnDuplicateErr = (workUri, isbn) => function (err) {
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

var reportIsbnIssue = (workUri, isbn) => app.request('post:feedback', {
  subject: `[Possible work duplicate] ${workUri} / ${isbn}'s work`,
  uris: [ workUri, `isbn:${isbn}` ]
})

var formatEditionAlreadyExistOnCurrentWork = err => err.responseJSON.status_verbose = 'this edition is already in the list'

var formatDuplicateWorkErr = function (err, isbn) {
  const normalizedIsbn = isbn_.normalizeIsbn(isbn)
  const alreadyExist = _.i18n('this ISBN already exist:')
  const link = `<a href='/entity/isbn:${normalizedIsbn}' class='showEntity'>${normalizedIsbn}</a>`
  const reported = _.i18n('the issue was reported')
  err.responseJSON.status_verbose = `${alreadyExist} ${link} (${reported})`
  return err.i18n = false
}
