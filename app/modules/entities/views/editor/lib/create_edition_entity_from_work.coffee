createEntities = require 'modules/entities/lib/create_entities'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
isbn_ = require 'lib/isbn'
isLoggedIn = require './is_logged_in'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

module.exports = (view, workModel, e)->
  unless isLoggedIn() then return

  $isbnField = $(e.currentTarget).parent('#isbnGroup').find('#isbnField')
  isbn = $isbnField.val()

  workUri = workModel.get 'uri'

  startLoading.call view, '#isbnButton'

  createEntities.workEdition workModel, isbn
  .catch RenameIsbnDuplicateErr(workUri, isbn)
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

RenameIsbnDuplicateErr = (workUri, isbn)-> (err)->
  if err.responseJSON?.status_verbose is 'this property value is already used'
    reportIsbnIssue workUri, isbn
    normalizedIsbn = isbn_.normalizeIsbn isbn
    alreadyExist = _.i18n 'this ISBN already exist:'
    link = "<a href='/entity/isbn:#{normalizedIsbn}' class='showEntity'>#{normalizedIsbn}</a>"
    reported = _.i18n 'the issue was reported'
    err.responseJSON.status_verbose = "#{alreadyExist} #{link} (#{reported})"
    err.i18n = false

  throw err

reportIsbnIssue = (workUri, isbn)->
  app.request 'post:feedback',
    subject: "[Possible work duplicate] #{workUri} / #{isbn}'s work"
