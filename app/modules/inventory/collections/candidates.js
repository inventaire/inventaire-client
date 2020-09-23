/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { looksLikeAnIsbn, normalizeIsbn } from 'lib/isbn'

export default Backbone.Collection.extend({
  model: require('../models/candidate'),

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

var isSelected = model => model.get('selected')

var setSelected = bool => function (model) {
  if (model.canBeSelected()) { return model.set('selected', bool) }
}

var isNewCandidate = alreadyAddedIsbns => function (candidateData) {
  if ((candidateData.title == null) && (candidateData.normalizedIsbn == null)) { return false }
  return !alreadyAddedIsbns.includes(candidateData.normalizedIsbn)
}

var addExistingEntityItemsCounts = function (candidates) {
  const uris = _.compact(candidates.map(getUri))
  return app.request('items:getEntitiesItemsCount', app.user.id, uris)
  .then(addCounts(candidates))
}

var getUri = function (candidate) {
  let { isbn, normalizedIsbn } = candidate
  if (normalizedIsbn == null) { normalizedIsbn = normalizeIsbn(isbn) }
  candidate.normalizedIsbn = normalizedIsbn
  if (looksLikeAnIsbn(normalizedIsbn)) {
    candidate.uri = `isbn:${normalizedIsbn}`
    return candidate.uri
  }
}

var addCounts = candidates => function (counts) {
  candidates.forEach(candidate => {
    const { uri } = candidate
    if (uri == null) { return }
    const count = counts[uri]
    if (count != null) { return candidate.existingEntityItemsCount = count }
  })

  return candidates
}
