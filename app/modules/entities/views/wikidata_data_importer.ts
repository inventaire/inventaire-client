import app from '#app/app'
import Loading from '#behaviors/loading'
import { startLoading } from '#general/plugins/behaviors'
import wikidataDataImporterTemplate from './templates/wikidata_data_importer.hbs'
import '../scss/wikidata_data_importer.scss'

export default Marionette.View.extend({
  className: 'wikidata-data-importer',
  template: wikidataDataImporterTemplate,

  behaviors: {
    Loading,
  },

  initialize () {
    ({ labels: this.labels, claims: this.claims, wdEntity: this.wdEntity } = this.options.importData)
  },

  onRender () { app.execute('modal:open', 'medium') },

  serializeData () {
    return {
      labels: this.labels,
      claims: this.claims,
      wdEntity: this.wdEntity.toJSON(),
    }
  },

  events: {
    'click #importData': 'importSelectedData',
    'click #mergeWithoutImport': 'mergeWithoutImport',
  },

  importSelectedData () {
    if (this._startedImporting) return
    this._startedImporting = true
    startLoading.call(this, '#importData')
    this.dataToImport = this.getDataToImport()
    this.importNext()
  },

  getDataToImport () {
    return Array.from(this.$el.find('input[type="checkbox"]'))
    .filter(isChecked)
    .map(formatData)
  },

  importNext () {
    // Keep claim order. Important when attempting to import both a serie and a serie oridnal:
    // The ordinal has to come after the serie
    const nextData = this.dataToImport.shift()
    if (nextData == null) return this.done()

    return makeImportRequest(this.wdEntity, nextData)
    .then(this.importNext.bind(this))
  },

  mergeWithoutImport () { this.done() },

  done () {
    this.options.resolve()
    app.execute('modal:close')
  },
})

// Using jQuery as el.attributes.checked.value doesn't reflect the actual state of the checkbox
const isChecked = el => $(el).prop('checked') === true

const formatData = function (el) {
  const { attributes: attrs } = el
  const type = attrs['data-type'].value

  if (type === 'label') {
    const lang = attrs['data-lang'].value
    const label = attrs['data-label'].value
    return { type, lang, label }
  } else if (type === 'claim') {
    const property = attrs['data-property'].value
    const { value } = attrs['data-value']
    return { type, property, value }
  }
}

const makeImportRequest = function (wdEntity, data) {
  const { type, lang, label, property, value } = data
  if (type === 'label') {
    return wdEntity.setLabel(lang, label)
  } else {
    return wdEntity.setPropertyValue(property, null, value)
  }
}
