AuthorsPreviewList = require 'modules/entities/views/authors_preview_list'

module.exports = (authorsPerProperty)->
  for property, models of authorsPerProperty
    showAuthorsPreviewList.call @, property, models

showAuthorsPreviewList = (property, models)->
  if models.length is 0 then return
  collection = new Backbone.Collection models
  name = extendedAuthorsKeys[property]
  @[name].show new AuthorsPreviewList { collection, name }

extendedAuthorsKeys =
  'wdt:P50': 'authors'
  'wdt:P58': 'scenarists'
  'wdt:P110': 'illustrators'
  'wdt:P6338': 'colorists'
