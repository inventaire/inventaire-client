import Candidate from '../models/candidate'
import { looksLikeAnIsbn, normalizeIsbn } from 'lib/isbn'

export default Backbone.Collection.extend({
  model: Candidate,

  setAllSelectedTo (bool) { return this.each(setSelected(bool)) },

  getSelected () { return this.filter(isSelected) },

  selectionIsntEmpty () { return this.any(isSelected) },

  addNewCandidates (newCandidates) {
    const alreadyAddedIsbns = this.pluck('normalizedIsbn')
    const remainingCandidates = newCandidates.filter(isNewCandidate(alreadyAddedIsbns))
    if (remainingCandidates.length === 0) { return Promise.resolve([]) }
    return addExistingEntityItemsCounts(remainingCandidates)
    .then(this.add.bind(this))
  }
})

const isSelected = model => model.get('selected')

const setSelected = bool => function (model) {
  if (model.canBeSelected()) { return model.set('selected', bool) }
}

const isNewCandidate = alreadyAddedIsbns => function (candidateData) {
  if ((candidateData.title == null) && (candidateData.normalizedIsbn == null)) { return false }
  return !alreadyAddedIsbns.includes(candidateData.normalizedIsbn)
}

const addExistingEntityItemsCounts = function (candidates) {
  const uris = _.compact(candidates.map(getUri))
  return app.request('items:getEntitiesItemsCount', app.user.id, uris)
  .then(addCounts(candidates))
}

const getUri = function (candidate) {
  let { isbn, normalizedIsbn } = candidate
  if (isbn == null && normalizedIsbn == null) return
  if (normalizedIsbn == null) normalizedIsbn = normalizeIsbn(isbn)
  candidate.normalizedIsbn = normalizedIsbn
  if (looksLikeAnIsbn(normalizedIsbn)) {
    candidate.uri = `isbn:${normalizedIsbn}`
    return candidate.uri
  }
}

const addCounts = candidates => function (counts) {
  candidates.forEach(candidate => {
    const { uri } = candidate
    if (uri == null) return
    const count = counts[uri]
    if (count != null) candidate.existingEntityItemsCount = count
  })

  return candidates
}
