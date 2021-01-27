import leven from 'leven'

export default Backbone.NestedModel.extend({
  // 'matchable' method should be defined on sub classes. ex:
  // matchable () { return [ this.get('title') ] }

  matches (filterRegex, rawInput) {
    if (filterRegex == null) return true
    return _.some(this.matchable(), this.fieldMatch(filterRegex, rawInput))
  },

  getClosestMatchingFieldDistance (filterRegex, rawInput) {
    const matchingFieldsByDistance = this.matchable()
      .filter(this.fieldMatch(filterRegex, rawInput))
      .map(field => ({ field, distance: leven(field, rawInput) }))
      .sort((a, b) => a.distance - b.distance)

    const matchData = matchingFieldsByDistance[0] || { distance: Infinity, field: '' }
    matchData.model = this
    return matchData
  },

  // Can be overriden to match fields in a custom way
  fieldMatch (filterRegex, rawInput) {
    return field => field?.match(filterRegex) != null
  }
})
