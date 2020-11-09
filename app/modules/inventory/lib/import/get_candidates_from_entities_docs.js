import { normalizeIsbn } from 'lib/isbn'
import getBestLangValue from 'modules/entities/lib/get_best_lang_value'
import getOriginalLang from 'modules/entities/lib/get_original_lang'

export default function (entities, isbnsIndex) {
  const newCandidates = []
  for (const uri in entities) {
    const entity = entities[uri]
    if (entity.type === 'edition') {
      const { claims } = entity
      // Match the attributes expected by
      // modules/inventory/views/add/templates/candidate_row.hbs
      entity.title = claims['wdt:P1476'][0]
      entity.authors = getEditionAuthors(entity, entities)
      const rawIsbn13 = claims['wdt:P212']?.[0]
      const rawIsbn10 = claims['wdt:P957']?.[0]
      const normalizedIsbn13 = (rawIsbn13 != null) ? normalizeIsbn(rawIsbn13) : undefined
      const normalizedIsbn10 = (rawIsbn10 != null) ? normalizeIsbn(rawIsbn10) : undefined
      let isbnData
      if (normalizedIsbn13 != null) {
        isbnData = isbnsIndex[normalizedIsbn13]
      } else if (normalizedIsbn10 != null) {
        isbnData = isbnsIndex[normalizedIsbn10]
      } else {
        isbnData = {}
      }
      // Use the input ISBN to allow the user to find it back in their list
      entity.rawIsbn = isbnData.rawIsbn
      // 'isbn' will be needed by the existsOrCreateFromSeed endpoint
      entity.isbn = (entity.normalizedIsbn = normalizedIsbn13 || normalizedIsbn10)
      newCandidates.push(entity)
    }
  }

  return newCandidates
}

const getEditionAuthors = function (edition, entities) {
  const editionLang = getOriginalLang(edition.claims)

  const worksUris = edition.claims['wdt:P629']
  const works = _.values(_.pick(entities, worksUris))

  const authorsUris = _.flatten(works.map(getWorkAuthors))
  const authors = _.values(_.pick(entities, authorsUris))

  return authors
  .map(author => getBestLangValue(editionLang, null, author.labels).value)
}

const getWorkAuthors = work => work.claims['wdt:P50']
