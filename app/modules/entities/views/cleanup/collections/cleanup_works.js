/* eslint-disable
    no-undef,
    no-var,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.Collection.extend({
  comparator: 'ordinal',
  initialize () { return this.triggerUpdateEvents() },

  serializeNonPlaceholderWorks () {
    return this.filter(isntPlaceholder)
    .map(model => {
      const [ oridinal, label, uri ] = Array.from(model.gets('ordinal', 'label', 'uri'))
      let richLabel = (oridinal != null) ? `${oridinal}. - ${label}` : `${label} (${uri})`
      if (richLabel.length > 50) { richLabel = richLabel.substring(0, 50) + '...' }
      return { richLabel, uri }
    })
  },

  getNonPlaceholdersOrdinals () {
    return this.filter(isntPlaceholder)
    .map(model => model.get('ordinal'))
  }
})

const isPlaceholder = model => model.get('isPlaceholder') === true
var isntPlaceholder = _.negate(isPlaceholder)
