/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import EditionCreation from './editor/lib/edition_creation'

import availableLangList from 'lib/available_lang_list'

const {
  partialData,
  clickEvents
} = EditionCreation

export default Marionette.CompositeView.extend({
  className: 'editions-list',
  template: require('./templates/editions_list'),
  childViewContainer: 'ul',
  childView: require('./edition_li'),
  emptyView: require('./no_edition'),
  childViewOptions () {
    return {
      itemToUpdate: this.options.itemToUpdate,
      onWorkLayout: this.options.onWorkLayout,
      compactMode: this.options.compactMode
    }
  },

  behaviors: {
    Loading: {},
    // Required by editionCreationParial
    AlertBox: {},
    PreventDefault: {}
  },

  initialize () {
    let needle;
    ({ work: this.work, sortByLang: this.sortByLang } = this.options)
    if (this.sortByLang == null) { this.sortByLang = true }

    // Start with user lang as default if there are editions in that language
    if (this.sortByLang && (needle = app.user.lang, this.getAvailableLangs().includes(needle))) {
      this.filter = LangFilter(app.user.lang)
    }
    this.selectedLang = app.user.lang

    if (this.collection.length > 0) {
      // If the collection was populated before showing the view,
      // the collection is ready
      return this.onceCollectionReady()
    } else {
      // Else, wait for the collection models to arrive
      const lateOnceCollectionReady = _.debounce(this.lateOnceCollectionReady.bind(this), 200)
      return this.listenTo(this.collection, 'add', lateOnceCollectionReady)
    }
  },

  ui: {
    languageSelect: 'select.languageFilter'
  },

  onceCollectionReady () {
    const userLangEditions = this.collection.filter(LangFilter(app.user.lang))
    // If no editions can be found in the user language, display all
    if (userLangEditions.length === 0) { return this.filterLanguage('all') }
  },

  lateOnceCollectionReady () {
    this.onceCollectionReady()
    // re-rendering required so that the language selector
    // gets all the now available options
    return this.lazyRender()
  },

  getAvailableLangs () {
    const langs = this.collection.map(model => model.get('lang'))
    return _.uniq(langs)
  },

  getAvailableLanguages (selectedLang) {
    return availableLangList(this.getAvailableLangs(), selectedLang)
  },

  serializeData () {
    return {
      hasEditions: this.collection.length > 0,
      hasWork: (this.work != null),
      sortByLang: this.sortByLang,
      availableLanguages: this.getAvailableLanguages(this.selectedLang),
      editionCreationData: partialData(this.work),
      // @options.header can be 'false', thus the existance test
      header: (this.options.header != null) ? this.options.header : 'editions'
    }
  },

  events: {
    'change .languageFilter': 'filterLanguageFromEvent',
    'click .edition-creation a': 'dispatchCreationEditionClickEvents'
  },

  filter (child) { return child.get('lang') === app.user.lang },

  filterLanguageFromEvent (e) { return this.filterLanguage(e.currentTarget.value) },

  filterLanguage (lang) {
    let needle
    if ((lang === 'all') || ((needle = lang, !this.getAvailableLangs().includes(needle)))) {
      this.filter = null
      this.selectedLang = 'all'
    } else {
      this.filter = LangFilter(lang)
      this.selectedLang = lang
    }

    return this.lazyRender()
  },

  onRender () {
    const lang = this.selectedLang || 'all'
    return this.ui.languageSelect.val(lang)
  },

  dispatchCreationEditionClickEvents (e) {
    const { id } = e.currentTarget
    const { itemToUpdate } = this.options
    return clickEvents[id]?.({ view: this, work: this.work, e, itemToUpdate })
  }
})

var LangFilter = lang => child => child.get('lang') === lang
