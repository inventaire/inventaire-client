// TODO:
// - hint to input ISBNs directly, maybe in the alternatives sections
// - add 'help': indexed wiki.inventaire.io entries to give results
//   to searches such as 'FAQ' or 'help creating group'
// - add 'place': search Wikidata for entities with coordinates (wdt:P625)
//   and display a layout with users & groups nearby, as well as books with
//   narrative location (wdt:P840), or authors born (wdt:P19)
//   or dead (wdt:P20) nearby

import findUri from '../lib/find_uri'
import { looksLikeAnIsbn } from 'lib/isbn'
import screen_ from 'lib/screen'
import preq from 'lib/preq'
import ResultModel from '../models/result'
import { isNonEmptyString } from 'lib/boolean_tests'
import log_ from 'lib/loggers'
import WikidataSearch from 'modules/entities/lib/search/wikidata_search'
import Result from './result'
import NoResult from './no_result'
import liveSearchTemplate from './templates/live_search.hbs'
import { formatEntity, formatSubject } from '../lib/formatters'
import { sectionToTypes, sectionsData, neverIncluded } from '../lib/search_sections'
const wikidataSearch = WikidataSearch(false)

const Results = Backbone.Collection.extend({ model: ResultModel })

const searchBatchLength = 10
let searchCount = 0

export default Marionette.CompositeView.extend({
  id: 'live-search',
  template: liveSearchTemplate,
  childViewContainer: 'ul.results',
  childView: Result,
  emptyView: NoResult,

  initialize () {
    this.collection = new Results()
    this._lazySearch = _.debounce(this.search.bind(this), 500)
    this.selectedSectionName = this.options.section
    this._searchOffset = 0
    // faking lastSelected to be able to show alternatives even though
    // user is newly arriving here by selecting their category search
    // known cases: all "search by" buttons at "/add/search" path
    this._lastSelected = { category: this.selectedSectionName }
  },

  ui: {
    all: '#section-all',
    sections: '.searchSection',
    resultsWrapper: '.resultsWrapper',
    results: 'ul.results',
    alternatives: '.alternatives',
    shortcuts: '.shortcuts',
    loader: '.loaderWrapper'
  },

  serializeData () {
    return {
      sections: sectionsData(this.selectedSectionName)
    }
  },

  events: {
    'click .searchSection': 'updateSections',
    'click .createEntity': 'showEntityCreate',
    'click .searchSettingsToggler': 'toggleSearchSettings',
  },

  onShow () {
    // Doesn't work if set in events for some reason
    this.ui.resultsWrapper.on('scroll', this.onResultsScroll.bind(this))
  },

  onSpecialKey (key) {
    if (key === 'up') this.highlightPreviousResult()
    else if (key === 'down') this.highlightNextResult()
    else if (key === 'enter') this.showCurrentlyHighlightedResult()
    else if (key === 'pageup') this.selectPrevSection()
    else if (key === 'pagedown') this.selectNextSection()
  },

  updateSections (e) { this.selectTypeFromTarget($(e.currentTarget)) },

  selectPrevSection () { this.selectByPosition('prev', 'last') },
  selectNextSection () { this.selectByPosition('next', 'first') },
  selectByPosition (relation, fallback) {
    let $target = this.$el.find('.selected')[relation]()
    if ($target.length === 0) {
      const currentCategory = this.$el.find('.selected')[0].dataset.category
      const otherCategory = currentCategory === 'entity' ? 'social' : 'entity'
      $target = this.$el.find(`.${otherCategory}Sections a`)[fallback]()
    }
    this.selectTypeFromTarget($target)
  },

  selectTypeFromTarget ($target) {
    const { category, name } = $target[0].dataset
    const type = sectionToTypes[category][name]
    this.selectType(category, name, type)
  },

  selectType (category, name, type) {
    if (this._lastSelected?.category === category && this._lastSelected?.name === name) return

    this.ui.sections
    .removeClass('selected')
    .removeClass('included')
    .filter((i, el) => el.dataset.category === category && el.dataset.name === name)
    .addClass('selected')

    if (name === 'all') {
      this.ui.sections
      .filter((i, el) => el.dataset.category === category && !neverIncluded.includes(el.dataset.name))
      .addClass('included')
    }

    this._searchOffset = 0
    this._lastSelected = { category, name }

    // Refresh the search with the new sections
    if (this._lastSearch != null && this._lastSearch !== '') {
      this.lazySearch(this._lastSearch)
    }

    this.updateAlternatives(type)
  },

  updateAlternatives (search) {
    const { category } = (this._lastSelected || {})
    if (category === 'social') return this.hideAlternatives()
    this.showAlternatives(search)
  },

  search (search) {
    search = search?.trim()
    this._lastSearch = search
    this._lastSearchId = ++searchCount
    this._searchOffset = 0

    if (!isNonEmptyString(search)) return this.hideAlternatives()

    const uri = findUri(search)
    if (uri != null) return this.getResultFromUri(uri, this._lastSearchId, this._lastSearch)

    this._search(search)
    .then(this.resetResults.bind(this, this._lastSearchId))

    this._waitingForAlternatives = true
    this.updateAlternatives(search)
  },

  async _search (search) {
    const types = this.getTypes()
    // Subjects aren't indexed in the server ElasticSearch
    // as it's not a subset of Wikidata anymore: pretty much anything
    // on Wikidata can be considered a subject
    if (types === 'subjects') {
      const results = await wikidataSearch(search, searchBatchLength, this._searchOffset)
      return results.map(formatSubject)
    } else {
      // Increasing search limit instead of offset, as search pages aren't stable:
      // results popularity might have change the results order between two requests,
      // thus the need to re-fetch from offset 0 but increasing the page length, and adding only
      // the results that weren't returned in the previous query, whatever there place
      // in the newly returned results
      const searchLimit = searchBatchLength + this._searchOffset
      const { results } = await preq.get(app.API.search(types, search, searchLimit))
      return results
    }
  },

  lazySearch (search) {
    if (search.length > 0) this.showLoadingSpinner()
    else this.stopLoadingSpinner()
    // Hide previous results to limit confusion and scroll up
    this.resetResults()
    this._lazySearch(search)
  },

  getTypes () {
    const { category, name } = this.$el.find('.selected')[0].dataset
    return sectionToTypes[category][name]
  },

  showAlternatives (search) {
    if (!isNonEmptyString(search)) return
    if (search !== this._lastSearch) return
    if (!this._waitingForAlternatives) return

    this.ui.alternatives.addClass('shown')
    this._waitingForAlternatives = false
  },

  hideAlternatives () {
    this._waitingForAlternatives = false
    this.ui.alternatives.removeClass('shown')
  },

  showShortcuts () { this.ui.shortcuts.addClass('shown') },

  getResultFromUri (uri, searchId, rawSearch) {
    log_.info(uri, 'uri found')
    this.showLoadingSpinner()
    return app.request('get:entity:model', uri)
    .then(entity => this.resetResults(searchId, [ formatEntity(entity) ]))
    .catch(err => {
      if (err.message === 'entity_not_found') {
        this._waitingForAlternatives = true
        this.showAlternatives(rawSearch)
      } else {
        throw err
      }
    })
    .finally(this.stopLoadingSpinner.bind(this))
  },

  showLoadingSpinner () {
    this.ui.loader.html('<div class="small-loader"></div>')
    this.$el.removeClass('no-results')
  },

  stopLoadingSpinner () { this.ui.loader.html('') },

  resetResults (searchId, results) {
    // Ignore results from any search that isn't the latest search
    if ((searchId != null) && (searchId !== this._lastSearchId)) return

    this.resetHighlightIndex()

    if (results != null) {
      this.stopLoadingSpinner()
      this.hideSearchSettings()
      this._lastResultsLength = results.length

      // Track TypeErrors where Result model 'initialize' crashes
      try {
        this.collection.reset(results)
      } catch (err) {
        if (err.context == null) err.context = {}
        err.context.results = results
        throw err
      }
    } else {
      this.collection.reset()
    }

    if ((results != null) && (results.length === 0)) {
      this.$el.addClass('no-results')
    } else {
      this.$el.removeClass('no-results')
      this.setTimeout(this.showShortcuts.bind(this), 1000)
    }
  },

  highlightNextResult () { this.highlightIndexChange(1) },
  highlightPreviousResult () { this.highlightIndexChange(-1) },
  highlightIndexChange (incrementor) {
    if (this._currentHighlightIndex == null) this._currentHighlightIndex = -1
    const newIndex = this._currentHighlightIndex + incrementor
    const previousView = this.children.findByIndex(this._currentHighlightIndex)
    const view = this.children.findByIndex(newIndex)
    if (view != null) {
      previousView?.unhighlight()
      view.highlight()
      this._currentHighlightIndex = newIndex

      return screen_.innerScrollTop(this.ui.results, view?.$el)
    }
  },

  showCurrentlyHighlightedResult () {
    const hilightedView = this.children.findByIndex(this._currentHighlightIndex)
    if (hilightedView) hilightedView.showResult()
  },

  resetHighlightIndex () {
    this.$el.find('.highlight').removeClass('highlight')
    this._currentHighlightIndex = -1
  },

  showEntityCreate () {
    this.triggerMethod('hide:live:search')
    if (looksLikeAnIsbn(this._lastSearch)) {
      // If the edition entity for this ISBN really doesn't exist
      // it will redirect to the ISBN edition creation form
      app.execute('show:entity', this._lastSearch)
    } else {
      let type
      if (this._lastSelected?.category === 'entity' && this._lastSelected?.name !== 'all') {
        type = sectionToTypes.entity[this._lastSelected.name]
      }
      app.execute('show:entity:create', { label: this._lastSearch, type, allowToChangeType: true })
    }
  },

  onResultsScroll (e) {
    const visibleHeight = this.ui.resultsWrapper.height()
    const { scrollHeight, scrollTop } = e.currentTarget
    const scrollBottom = scrollTop + visibleHeight
    if (scrollBottom === scrollHeight) this.loadMore()
  },

  loadMore () {
    // Do not try to fetch more results if the last batch was incomplete
    if (this._lastResultsLength < searchBatchLength) {
      this.stopLoadingSpinner()
    } else {
      this.showLoadingSpinner()
      this._searchOffset += searchBatchLength
      return this._search(this._lastSearch)
      .then(this.addNewResults.bind(this))
    }
  },

  addNewResults (results) {
    const currentResultsUri = this.collection.map(model => model.get('uri'))
    const newResults = results.filter(result => !currentResultsUri.includes(result.uri))
    this._lastResultsLength = newResults.length
    return this.collection.add(newResults)
  },

  toggleSearchSettings () { this.$el.toggleClass('settingsShown') },

  // Methods used by ./top_bar.js
  showSearchSettings () { this.$el.addClass('settingsShown') },
  hideSearchSettings () { this.$el.removeClass('settingsShown') }
})
