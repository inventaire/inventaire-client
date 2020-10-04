export default Marionette.ItemView.extend({
  className: 'wikidata-data-importer',
  template: require('./templates/wikidata_data_importer.hbs'),
  initialize () {
    return ({ labels: this.labels, claims: this.claims, wdEntity: this.wdEntity } = this.options.importData)
  },

  onShow () { app.execute('modal:open', 'medium') },

  serializeData () {
    return {
      labels: this.labels,
      claims: this.claims,
      wdEntity: this.wdEntity.toJSON()
    }
  },

  events: {
    'click #importData': 'importSelectedData',
    'click #mergeWithoutImport': 'mergeWithoutImport'
  },

  importSelectedData () {
    this.dataToImport = this.getDataToImport()
    return this.importNext()
  },

  getDataToImport () {
    return Array.from(this.$el.find('input[type="checkbox"]'))
    .filter(isChecked)
    .map(formatData)
  },

  importNext () {
    const nextData = this.dataToImport.pop()
    if (nextData == null) { return this.done() }

    return makeImportRequest(this.wdEntity, nextData)
    .then(this.importNext.bind(this))
  },

  mergeWithoutImport () { return this.done() },

  done () {
    this.options.resolve()
    app.execute('modal:close')
  }
})

const isChecked = el => el.attributes.checked.value === 'true'

const formatData = function (el) {
  const { attributes: attrs } = el
  const type = attrs['data-type'].value

  if (type === 'label') {
    const lang = attrs['data-lang'].value
    const label = attrs['data-label'].value
    return { type, lang, label }
  } else if (type === 'claim') {
    const property = attrs['data-property'].value
    const {
      value
    } = attrs['data-value']
    return { type, property, value }
  }
}

const makeImportRequest = function (wdEntity, data) {
  const { type, lang, label, property, value } = data
  if (type === 'label') {
    return wdEntity.setLabel(lang, label)
  } else { return wdEntity.setPropertyValue(property, null, value) }
}
