import { range, difference, debounce } from 'underscore'
import app from '#app/app'
import { formatAndThrowError } from '#app/lib/error'
import { getActionKey } from '#app/lib/key_events'
import { focusInput } from '#app/lib/utils'
import AlertBox from '#behaviors/alert_box'
import getLangsData from '#entities/lib/editor/get_langs_data'
import { catchAlert } from '#general/lib/forms'
import SerieCleanupAuthors from './serie_cleanup_authors.ts'
import SerieCleanupEditions from './serie_cleanup_editions.ts'
import serieCleanupWorkTemplate from './templates/serie_cleanup_work.hbs'
import WorkPicker from './work_picker.ts'

export default Marionette.View.extend({
  tagName: 'li',
  template: serieCleanupWorkTemplate,
  className () {
    let classes = 'serie-cleanup-work'
    if (this.model.get('isPlaceholder')) classes += ' placeholder'
    return classes
  },

  regions: {
    mergeWorkPicker: '.mergeWorkPicker',
    authorsContainer: '.authorsContainer',
    editionsContainer: '.editionsContainer',
  },

  ui: {
    head: '.head',
    placeholderEditor: '.placeholderEditor',
    placeholderLabelEditor: '.placeholderEditor input',
    langSelector: '.langSelector',
  },

  behaviors: {
    AlertBox,
  },

  initialize () {
    ({ worksWithOrdinal: this.worksWithOrdinal, worksWithoutOrdinal: this.worksWithoutOrdinal } = this.options)
    const lazyLangSelectorUpdate = debounce(this.onOtherLangSelectorChange.bind(this), 500)
    this.listenTo(app.vent, 'lang:local:change', lazyLangSelectorUpdate)
    // This is required to update works ordinal selectors
    this.listenTo(app.vent, 'serie:cleanup:parts:change', this.lazyRender.bind(this))
    this.allAuthorsUris = this.options.allAuthorsUris
  },

  serializeData () {
    const data = this.model.toJSON()
    const localLang = app.request('lang:local:get')
    data.langs = getLangsData(localLang, this.model.get('labels'))
    if (this.options.showPossibleOrdinals) {
      const nonPlaceholdersOrdinals = this.worksWithOrdinal.getNonPlaceholdersOrdinals()
      data.possibleOrdinals = getPossibleOrdinals(nonPlaceholdersOrdinals)
    }
    return data
  },

  onRender () {
    if (this.model.get('isPlaceholder')) {
      this.$el.attr('tabindex', 0)
      return
    }

    this.showWorkAuthors()

    this.model.fetchSubEntities()
    .then(this.ifViewIsIntact('showWorkEditions'))
  },

  toggleMergeWorkPicker () {
    if (this.getRegion('mergeWorkPicker').currentView != null) {
      this.getRegion('mergeWorkPicker').currentView.$el.toggle()
    } else {
      this.showChildView('mergeWorkPicker', new WorkPicker({
        model: this.model,
        worksWithOrdinal: this.worksWithOrdinal,
        worksWithoutOrdinal: this.worksWithoutOrdinal,
        _showWorkPicker: true,
        workUri: this.model.get('uri'),
        afterMerge: this.afterMerge,
      }))
    }
  },

  afterMerge (work) {
    this.worksWithOrdinal.remove(this.model)
    this.worksWithoutOrdinal.remove(this.model)
    work.editions.add(this.model.editions.models)
  },

  showWorkAuthors () {
    const { currentAuthorsUris, authorsSuggestionsUris } = this.spreadAuthors()
    this.showChildView('authorsContainer', new SerieCleanupAuthors({
      work: this.model,
      currentAuthorsUris,
      authorsSuggestionsUris,
    }))
  },

  showWorkEditions () {
    this.showChildView('editionsContainer', new SerieCleanupEditions({
      collection: this.model.editions,
      worksWithOrdinal: this.worksWithOrdinal,
      worksWithoutOrdinal: this.worksWithoutOrdinal,
    }))
  },

  events: {
    'change .ordinalSelector': 'updateOrdinal',
    'click .create': 'create',
    click: 'showPlaceholderEditor',
    keydown: 'onKeyDown',
    'change .langSelector': 'propagateLangChange',
    'click .toggleMergeWorkPicker': 'toggleMergeWorkPicker',
  },

  updateOrdinal (e) {
    const { value } = e.currentTarget
    return this.model.setPropertyValue('wdt:P1545', null, value)
    .catch(formatAndThrowError('.head', false))
    .catch(catchAlert.bind(null, this))
  },

  showPlaceholderEditor () {
    if (!this.model.get('isPlaceholder')) return
    if (!this.ui.placeholderEditor.hasClass('hidden')) return
    this.ui.head.addClass('force-hidden')
    this.ui.placeholderEditor.removeClass('hidden')
    this.$el.attr('tabindex', null)
    // Wait to avoid the enter event to be propagated as an enterClick to 'create'
    this.setTimeout(focusInput.bind(null, this.ui.placeholderLabelEditor), 100)
  },

  hidePlaceholderEditor () {
    this.ui.head.removeClass('force-hidden')
    this.ui.placeholderEditor.addClass('hidden')
    this.$el.attr('tabindex', 0)
    this.$el.focus()
  },

  async create () {
    if (!this.model.get('isPlaceholder')) return
    const lang = this.ui.langSelector.val()
    const label = this.ui.placeholderLabelEditor.val()
    this.model.resetLabels(lang, label)
    return this.model.create()
    .then(this.replaceModel.bind(this))
  },

  replaceModel (newModel) {
    newModel.set('ordinal', this.model.get('ordinal'))
    this.model.collection.add(newModel)
    return this.model.collection.remove(this.model)
  },

  onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'enter') return this.showPlaceholderEditor()
    if (key === 'esc') return this.hidePlaceholderEditor()
  },

  propagateLangChange (e) {
    const { value } = e.currentTarget
    return app.vent.trigger('lang:local:change', value)
  },

  onOtherLangSelectorChange (value) {
    if (this.ui.placeholderEditor.hasClass('hidden')) this.ui.langSelector.val(value)
  },

  spreadAuthors () {
    const currentAuthorsUris = this.model.get('claims.wdt:P50') || []
    const authorsSuggestionsUris = difference(this.allAuthorsUris, currentAuthorsUris)
    return { currentAuthorsUris, authorsSuggestionsUris }
  },
})

const getPossibleOrdinals = function (nonPlaceholdersOrdinals) {
  const maxOrdinal = nonPlaceholdersOrdinals.slice(-1)[0] || -1
  return range(0, (maxOrdinal + 10))
    .filter(num => !nonPlaceholdersOrdinals.includes(num))
}
