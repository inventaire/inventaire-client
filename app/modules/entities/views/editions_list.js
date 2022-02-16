import EditionCreation from './editor/lib/edition_creation'
import availableLangList from '#lib/available_lang_list'
import EditionLi from './edition_li'
import NoEdition from './no_edition'
import editionsListTemplate from './templates/editions_list.hbs'
import '../scss/editions_list.scss'
import Loading from '#behaviors/loading'
import AlertBox from '#behaviors/alert_box'
import PreventDefault from '#behaviors/prevent_default'

const {
  partialData,
  clickEvents
} = EditionCreation

export default Marionette.CollectionView.extend({
  className: 'editions-list',
  template: editionsListTemplate,
  childViewContainer: 'ul',
  childView: EditionLi,
  emptyView: NoEdition,
  childViewOptions () {
    return {
      itemToUpdate: this.options.itemToUpdate,
      onWorkLayout: this.options.onWorkLayout,
      compactMode: this.options.compactMode
    }
  },

  behaviors: {
    Loading,
    // Required by editionCreationParial
    AlertBox,
    PreventDefault,
  },

  initialize () {
    ({ work: this.work, sortByLang: this.sortByLang } = this.options)
    if (this.sortByLang == null) this.sortByLang = true

    // Start with user lang as default if there are editions in that language
    if (this.sortByLang && (this.getAvailableLangs().includes(app.user.lang))) {
      this.viewFilter = LangFilter(app.user.lang)
    }
    this.selectedLang = app.user.lang

    if (this.collection.length > 0) {
      // If the collection was populated before showing the view,
      // the collection is ready
      this.onceCollectionReady()
    } else {
      // Else, wait for the collection models to arrive
      const lateOnceCollectionReady = _.debounce(this.lateOnceCollectionReady.bind(this), 200)
      this.listenTo(this.collection, 'add', lateOnceCollectionReady)
    }
  },

  ui: {
    languageSelect: 'select.languageFilter'
  },

  onceCollectionReady () {
    const userLangEditions = this.collection.filter(LangFilter(app.user.lang))
    // If no editions can be found in the user language, display all
    if (userLangEditions.length === 0) return this.filterLanguage('all')
  },

  lateOnceCollectionReady () {
    this.onceCollectionReady()
    // re-rendering required so that the language selector
    // gets all the now available options
    this.lazyRender()
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
    // ex: button#isbnButton
    'click .edition-creation button': 'dispatchCreationEditionClickEvents',
    // ex: a#withoutIsbn
    'click .edition-creation a': 'dispatchCreationEditionClickEvents',
  },

  viewFilter (view) {
    return view.model.get('lang') === app.user.lang
  },

  filterLanguageFromEvent (e) {
    return this.filterLanguage(e.currentTarget.value)
  },

  filterLanguage (lang) {
    let needle
    if ((lang === 'all') || ((needle = lang, !this.getAvailableLangs().includes(needle)))) {
      this.viewFilter = null
      this.selectedLang = 'all'
    } else {
      this.viewFilter = LangFilter(lang)
      this.selectedLang = lang
    }

    this.lazyRender()
  },

  onRender () {
    const lang = this.selectedLang || 'all'
    this.ui.languageSelect.val(lang)
  },

  dispatchCreationEditionClickEvents (e) {
    const { id } = e.currentTarget
    const { itemToUpdate } = this.options
    return clickEvents[id]?.({ view: this, work: this.work, e, itemToUpdate })
  }
})

// Generate a filter function that can be used by both collection and view filters
const LangFilter = lang => model => {
  model = model.model || model
  return model.get('lang') === lang
}
