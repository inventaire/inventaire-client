createEntities = require 'modules/entities/lib/create_entities'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
isbn_ = require 'lib/isbn'
isLoggedIn = require './is_logged_in'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

module.exports = (params)->
  unless isLoggedIn() then return
  { view, work:workModel, e } = params

  $isbnField = $(e.currentTarget).parent('#isbnGroup').find('#isbnField')
  isbn = isbn_.normalizeIsbn $isbnField.val()

  workUri = workModel.get 'uri'

  startLoading.call view, '#isbnButton'

  createEntities.workEdition workModel, isbn
  .catch renameIsbnDuplicateErr(workUri, isbn)
  .then (editionModel)->
    # Special case of property_values collection
    if view.collection.addByValue?
      view.collection.addByValue editionModel.get('uri')
    # In other cases, the model being added to the work edition collection
    # by createEntities.workEdition is engouh
    $isbnField.val null
  .catch error_.Complete('#isbnField')
  .catch forms_.catchAlert.bind(null, view)
  .finally stopLoading.bind(view)

renameIsbnDuplicateErr = (workUri, isbn)-> (err)->
  if err.responseJSON?.status_verbose isnt 'this property value is already used' then throw err

  existingEditionUri = err.responseJSON.context.entity
  app.request 'get:entity:model', existingEditionUri
  .then (model)->
    existingEditionWorksUris = model.get 'claims.wdt:P629'
    if workUri in existingEditionWorksUris
      formatEditionAlreadyExistOnCurrentWork err
    else
      reportIsbnIssue workUri, isbn
      formatDuplicateWorkErr err, isbn
    throw err

reportIsbnIssue = (workUri, isbn)->
  app.request 'post:feedback',
    subject: "[Possible work duplicate] #{workUri} / #{isbn}'s work"
    uris: [ workUri, "isbn:#{isbn}" ]

formatEditionAlreadyExistOnCurrentWork = (err)->
  err.responseJSON.status_verbose = 'this edition is already in the list'

formatDuplicateWorkErr = (err, isbn)->
  normalizedIsbn = isbn_.normalizeIsbn isbn
  alreadyExist = _.i18n 'this ISBN already exist:'
  link = "<a href='/entity/isbn:#{normalizedIsbn}' class='showEntity'>#{normalizedIsbn}</a>"
  reported = _.i18n 'the issue was reported'
  err.responseJSON.status_verbose = "#{alreadyExist} #{link} (#{reported})"
  err.i18n = false
