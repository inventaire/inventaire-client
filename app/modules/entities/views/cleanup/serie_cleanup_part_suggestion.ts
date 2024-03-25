import serieCleanupPartSuggestionTemplate from './templates/serie_cleanup_part_suggestion.hbs'
import WorkPicker from './work_picker.ts'

const PartSuggestion = WorkPicker.extend({
  tagName: 'li',
  className () {
    let className = 'serie-cleanup-part-suggestion'
    if (this.model.get('labelMatch')) className += ' label-match'
    if (this.model.get('authorMatch')) className += ' author-match'
    return className
  },

  template: serieCleanupPartSuggestionTemplate,
  initialize () {
    this.isWikidataEntity = this.workPickerDisabled = this.model.get('isWikidataEntity')
    WorkPicker.prototype.initialize.call(this)
    this.listenTo(this.model, 'change:image', this.render.bind(this))
  },

  onRender () {
    this.updateClassName()
    WorkPicker.prototype.onRender.call(this)
  },

  serializeData () {
    const attrs = this.model.toJSON()
    if (this.isWikidataEntity) {
      attrs.workPickerDisabled = true
      if (!this.options.serie.get('isWikidataEntity')) attrs.serieNeedsToBeMovedToWikidata = true
    } else {
      if (this._showWorkPicker) attrs.worksList = this.getWorksList()
      attrs.workPicker = {
        buttonIcon: 'compress',
        buttonLabel: 'merge',
        validateLabel: 'merge',
      }
    }
    return attrs
  },

  afterMerge (work) {
    this.model.collection.remove(this.model)
    work.editions.add(this.model.editions.models)
  },

  events: _.extend({}, WorkPicker.prototype.events, {
    'click a.add': 'add',
  }),

  add () {
    this.model.setPropertyValue('wdt:P179', null, this.options.serie.get('uri'))
    this.options.addToSerie(this.model)
    this.options.collection.remove(this.model)
  },
})

export default Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: PartSuggestion,
  childViewOptions () { return this.options },
})
