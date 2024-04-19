import { negate } from 'underscore'

export default Backbone.Collection.extend({
  comparator: 'ordinal',

  serializeNonPlaceholderWorks () {
    return this.filter(isntPlaceholder)
    .map(model => {
      const [ oridinal, label, uri ] = model.gets('ordinal', 'label', 'uri')
      let richLabel = (oridinal != null) ? `${oridinal}. - ${label}` : `${label} (${uri})`
      if (richLabel.length > 50) richLabel = richLabel.substring(0, 50) + '...'
      return { richLabel, uri }
    })
  },

  getNonPlaceholdersOrdinals () {
    return this.filter(isntPlaceholder)
    .map(model => model.get('ordinal'))
  },
})

const isPlaceholder = model => model.get('isPlaceholder') === true
const isntPlaceholder = negate(isPlaceholder)
