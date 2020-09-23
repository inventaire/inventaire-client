searchWorks = require('modules/entities/lib/search/search_type')('works')
addPertinanceScore = require './add_pertinance_score'
descendingPertinanceScore = (work)-> - work.get('pertinanceScore')
Suggestions = Backbone.Collection.extend { comparator: descendingPertinanceScore }

module.exports = (serie)->
  authorsUris = serie.getAllAuthorsUris()
  Promise.all [
    getAuthorsWorks authorsUris
    searchMatchWorks serie
  ]
  .then _.flatten
  .then _.uniq
  .then (uris)-> app.request 'get:entities:models', { uris, refresh: true }
  # Confirm the type, as the search might have failed to unindex a serie that use
  # to be considered a work
  .filter isWorkWithoutSerie
  .map addPertinanceScore(serie)
  .filter (work)-> work.get('authorMatch') or work.get('labelMatch')
  .then (works)-> new Suggestions works

getAuthorsWorks = (authorsUris)->
  Promise.all authorsUris.map(fetchAuthorWorks)
  .map (results)-> _.pluck results.works.filter(hasNoSerie), 'uri'
  .then _.flatten

fetchAuthorWorks = (authorUri)-> _.preq.get app.API.entities.authorWorks(authorUri)

hasNoSerie = (work)-> not work.serie?

isWorkWithoutSerie = (work)-> work.get('type') is 'work' and not work.get('claims.wdt:P179')?

searchMatchWorks = (serie)->
  serieLabel = serie.get 'label'
  { allUris: partsUris } = serie.parts
  searchWorks serieLabel, 20
  .filter (result)-> result._score > 0.5 and result.uri not in partsUris
  .map _.property('uri')
