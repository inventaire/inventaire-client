import { uniq, property, pluck, flatten } from 'underscore'
import app from '#app/app'
import { searchWorks } from '#entities/lib/search/search_by_types'
import preq from '#lib/preq'
import addPertinanceScore from './add_pertinance_score.ts'

const descendingPertinanceScore = work => -work.get('pertinanceScore')
const Suggestions = Backbone.Collection.extend({ comparator: descendingPertinanceScore })

export default async function (serie) {
  const authorsUris = serie.getAllAuthorsUris()
  const uris = await Promise.all([
    getAuthorsWorks(authorsUris),
    searchMatchWorks(serie),
  ])
  .then(flatten)
  .then(uniq)

  let works = await app.request('get:entities:models', { uris, refresh: true })

  works = works
    // Confirm the type, as the search might have failed to unindex a serie that use
    // to be considered a work
    .filter(isWorkWithoutSerie)
    .map(addPertinanceScore(serie))
    .filter(work => work.get('authorMatch') || work.get('labelMatch'))

  return new Suggestions(works)
}

const getAuthorsWorks = async authorsUris => {
  let allResults = await Promise.all(authorsUris.map(fetchAuthorWorks))
  allResults = allResults.map(results => pluck(results.works.filter(hasNoSerie), 'uri'))
  return flatten(allResults)
}

const fetchAuthorWorks = authorUri => preq.get(app.API.entities.authorWorks(authorUri))

const hasNoSerie = work => work.serie == null

const isWorkWithoutSerie = work => (work.get('type') === 'work') && (work.get('claims.wdt:P179') == null)

const searchMatchWorks = async serie => {
  const serieLabel = serie.get('label')
  const { allUris: partsUris } = serie.parts
  const { results } = await searchWorks({ search: serieLabel, limit: 20 })
  return results
  .filter(result => (result._score > 0.5) && !partsUris.includes(result.uri))
  .map(property('uri'))
}
