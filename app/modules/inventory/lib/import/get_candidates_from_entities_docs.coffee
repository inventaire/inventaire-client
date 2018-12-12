isbn_ = require 'lib/isbn'
getBestLangValue = require 'modules/entities/lib/get_best_lang_value'
getOriginalLang = require 'modules/entities/lib/get_original_lang'

module.exports = (entities, isbnsIndex)->
  newCandidates = []
  for uri, entity of entities
    if entity.type is 'edition'
      { claims } = entity
      # Match the attributes expected by
      # modules/inventory/views/add/templates/candidate_row.hbs
      entity.title = claims['wdt:P1476'][0]
      entity.authors = getEditionAuthors entity, entities
      normalizedIsbn13 = isbn_.normalizeIsbn claims['wdt:P212'][0]
      normalizedIsbn10 = isbn_.normalizeIsbn claims['wdt:P957'][0]
      isbnData = isbnsIndex[normalizedIsbn13] or isbnsIndex[normalizedIsbn10]
      # Use the input ISBN to allow the user to find it back in her list
      entity.rawIsbn = isbnData.rawIsbn
      # 'isbn' will be needed by the existsOrCreateFromSeed endpoint
      entity.isbn = entity.normalizedIsbn = normalizedIsbn13
      newCandidates.push entity

  return newCandidates

getEditionAuthors = (edition, entities)->
  editionLang = getOriginalLang edition.claims

  worksUris = edition.claims['wdt:P629']
  works = _.values _.pick(entities, worksUris)

  authorsUris = _.flatten works.map(getWorkAuthors)
  authors = _.values _.pick(entities, authorsUris)

  return authors
  .map (author)-> getBestLangValue(editionLang, null, author.labels).value

getWorkAuthors = (work)-> work.claims['wdt:P50']
