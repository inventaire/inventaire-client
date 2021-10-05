import { someMatch, isOpenedOutside, capitalize } from 'lib/utils'
import mergeSuggestionTemplate from './templates/merge_homonym.hbs'
import mergeSuggestionSubentityTemplate from './templates/merge_homonym_subentity.hbs'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import mergeEntities from './lib/merge_entities'
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'
import 'modules/entities/scss/merge_homonyms.scss'

export default Marionette.LayoutView.extend({
  template: mergeSuggestionTemplate,
  className: 'merge-homonym',
  behaviors: {
    AlertBox: {},
    Loading: {},
    PreventDefault: {}
  },

  regions: {
    series: '.seriesList',
    works: '.worksList'
  },

  initialize () {
    const toEntityUri = this.options.toEntity.get('uri')
    this.taskModel = this.model.tasks?.[toEntityUri]
    this.isTypeAttribute = `is${capitalize(this.model.type)}`

    this.isExactMatch = haveLabelMatch(this.model, this.options.toEntity)
    this.showCheckbox = this.options.showCheckbox
  },

  serializeData () {
    const attrs = this.model.toJSON()
    attrs.task = this.taskModel?.serializeData()
    attrs[this.isTypeAttribute] = true
    attrs.isExactMatch = this.isExactMatch
    attrs.showCheckbox = this.showCheckbox
    return attrs
  },

  events: {
    'click .showTask': 'showTask',
    'click .merge': 'merge'
  },

  async onShow () {
    if (this.model.get('type') !== 'human') return
    await this.model.initAuthorWorks()
    if (this.isIntact()) this.showWorks()
  },

  showWorks () {
    this.showSubentities('series', this.model.works.series)
    this.showSubentities('works', this.model.works.works)
  },

  async showSubentities (name, collection) {
    if (collection.totalLength === 0) return
    await collection.fetchAll()
    if (this.isIntact()) this._showSubentities(name, collection)
  },

  _showSubentities (name, collection) {
    this.$el.find(`.${name}Label`).show()
    this[name].show(new SubentitiesList({ collection, entity: this.model }))
  },

  showTask (e) {
    if (!isOpenedOutside(e)) {
      app.execute('show:task', this.taskModel.id)
    }
  },

  async merge () {
    if (this._mergedAlreadyTriggered) return
    this._mergedAlreadyTriggered = true

    startLoading.call(this)
    const { toEntity } = this.options
    const fromUri = this.model.get('uri')
    const toUri = toEntity.get('uri')

    return mergeEntities(fromUri, toUri)
    // Simply hidding it instead of removing it from the collection so that other
    // suggestions don't jump places, potentially leading to undesired merges
    .then(() => this.$el.css('visibility', 'hidden'))
    .finally(stopLoading.bind(this))
    .catch(error_.Complete('.merge', false))
    .catch(forms_.catchAlert.bind(null, this))
  },

  isSelected () { return this.$el.find('input[type="checkbox"]').prop('checked') }
})

const haveLabelMatch = (suggestion, toEntity) => someMatch(getNormalizedLabels(suggestion), getNormalizedLabels(toEntity))

const getNormalizedLabels = entity => Object.values(entity.get('labels')).map(normalizeLabel)
const normalizeLabel = label => label.toLowerCase().replace(/\W+/g, '')

const Subentity = Marionette.ItemView.extend({
  className: 'subentity',
  template: mergeSuggestionSubentityTemplate,
  attributes () {
    return { title: this.model.get('uri') }
  },

  serializeData () {
    const attrs = this.model.toJSON()
    const authorUri = this.options.entity.get('uri')
    attrs.claims['wdt:P50'] = _.without(attrs.claims['wdt:P50'], authorUri)
    return attrs
  }
})

const SubentitiesList = Marionette.CollectionView.extend({
  className: 'subentities-list',
  childView: Subentity,
  childViewOptions () {
    return { entity: this.options.entity }
  }
})
