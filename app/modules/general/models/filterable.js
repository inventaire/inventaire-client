/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.NestedModel.extend({
  matches (filterRegex, rawInput) {
    if (filterRegex == null) { return true }
    return _.some(this.matchable(), this.fieldMatch(filterRegex, rawInput))
  },

  // Can be overriden to match fields in a custom way
  fieldMatch (filterRegex, rawInput) { return field => field?.match(filterRegex) != null }
})

// matchable should be defined on sub classes. ex:
// matchable: -> [ @get('title') ]
