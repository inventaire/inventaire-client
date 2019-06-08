{ getReverseClaims } = require 'modules/entities/lib/entities'

module.exports = (entity, index, propertyValuesCount)->
  isbn13h = entity.get 'claims.wdt:P212.0'
  isbnPublisherPrefix = isbn13h.split('-').slice(0, 3).join('-')

  return getReverseClaims 'wdt:P3035', isbnPublisherPrefix
