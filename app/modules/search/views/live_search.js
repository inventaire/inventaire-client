import findUri from '../lib/find_uri'
import error_ from 'lib/error'
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
    this._lazySearch = _.debounce(this.search.bind(this), 500);
    ({ section: this.selectedSectionName } = this.options)
    this._searchOffset = 0
  },

  ui: {
    all: '#section-all',
    entitiesSections: '.entitiesSections',
    socialSections: '.socialSections',
    resultsWrapper: '.resultsWrapper',
    results: 'ul.results',
    alternatives: '.alternatives',
    shortcuts: '.shortcuts',
    loader: '.loaderWrapper'
  },

  serializeData () {
    const {
      entitiesSections
    } = sectionsData()
    const {
      socialSections
    } = sectionsData()
    if ((entitiesSections[this.selectedSectionName] == null) && (socialSections[this.selectedSectionName] == null)) {
      log_.warn({ selectedSectionName: this.selectedSectionName }, 'unknown search section')
      this.selectedSectionName = 'book'
    }
    entitiesSections[this.selectedSectionName].selected = true
    return { socialSections, entitiesSections }
  },

  events: {
    'click .searchSection': 'updateSections',
    'click .createEntity': 'showEntityCreate'
  },

  onShow () {
    // Doesn't work if set in events for some reason
    this.ui.resultsWrapper.on('scroll', this.onResultsScroll.bind(this))
  },

  onSpecialKey (key) {
    if (key === 'up') this.highlightPrevious()
    else if (key === 'down') this.highlightNext()
    else if (key === 'enter') this.showCurrentlyHighlightedResult()
    else if (key === 'pageup') this.selectPrevSection()
    else if (key === 'pagedown') this.selectNextSection()
  },

  updateSections (e) { this.selectTypeFromTarget($(e.currentTarget)) },

  selectPrevSection () { this.selectByPosition('prev', 'last') },
  selectNextSection () { this.selectByPosition('next', 'first') },
  selectByPosition (relation, fallback) {
    let $target = this.$el.find('.selected')[relation]()
    if ($target.length === 0) { $target = this.$el.find('.sections a')[fallback]() }
    this.selectTypeFromTarget($target)
  },

  selectTypeFromTarget ($target) {
    const { id } = $target[0]
    const name = getSectionName(id)
    this.selectSectionAndSearch(name)
  },

  selectSectionAndSearch (name) {
    if (this.isSectionSelected(name)) {
      this.unselectSection(name)
    } else {
      if (isSocialSection(name)) { this.updateSocialSections(name) }
      if (isEntitiesSection(name)) { this.updateEntitiesSections(name) }
    }

    this._searchOffset = 0
    this._lastType = name
    // Refresh the search with the new sections
    if ((this._lastSearch != null) && (this._lastSearch !== '')) { this.lazySearch(this._lastSearch) }

    return this.updateAlternatives(name)
  },

  unselectSection (name) {
    if (isSocialSection(name)) {
      this.ui.socialSections.find(`#section-${name}`).removeClass('selected')
    }
    if (isEntitiesSection(name)) {
      return this.ui.entitiesSections.find(`#section-${name}`).removeClass('selected')
    }
  },

  updateEntitiesSections (name) {
    if (isSocialSection(this._lastType)) {
      this.ui.socialSections.find('.socialSection').removeClass('selected')
    }
    // unselect all selected section to have a search dedicated to subjects only
    if (name === 'subject') {
      this.ui.entitiesSections.find('.entitiesSection').removeClass('selected')
    } else {
      this.ui.entitiesSections.find('#section-subject').removeClass('selected')
    }
    return this.ui.entitiesSections.find(`#section-${name}`).addClass('selected')
  },
  // @entitiesSection = (child)-> child.get('typeAlias') is name

  updateSocialSections (name) {
    // needs to unselect the default 'book' section
    if (!this._lastType || isEntitiesSection(this._lastType)) {
      this.ui.entitiesSections.find('.entitiesSection').removeClass('selected')
    }
    return this.ui.socialSections.find(`#section-${name}`).addClass('selected')
  },
  // @socialSection = (child)-> child.get('typeAlias') is name

  updateAlternatives (search) {
    if (Array.from(sectionsWithAlternatives).includes(this._lastType)) {
      return this.showAlternatives(search)
    } else { return this.hideAlternatives() }
  },

  search (search) {
    search = search?.trim()
    this._lastSearch = search
    this._lastSearchId = ++searchCount
    this._searchOffset = 0

    if (!isNonEmptyString(search)) return this.hideAlternatives()

    const uri = findUri(search)
    if (uri != null) { return this.getResultFromUri(uri, this._lastSearchId, this._lastSearch) }

    this._search(search)
    .then(this.resetResults.bind(this, this._lastSearchId))

    this._waitingForAlternatives = true
    this.setTimeout(this.updateAlternatives.bind(this, search), 2000)
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

  getTypes () {
    const names = this.getSelectedSectionsNames()
    return _.map(names, getSectionType)
  },

  resetResults (searchId, results) {
    // Ignore results from any search that isn't the latest search
    if ((searchId != null) && (searchId !== this._lastSearchId)) return

    this.resetHighlightIndex()

    if (results != null) {
      this.stopLoadingSpinner()
      this._lastResultsLength = results.length

      // Track TypeErrors where Result model 'initialize' crashes
      try {
        this.collection.reset(results)
      } catch (err) {
        if (err.context == null) { err.context = {} }
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

  highlightNext () { this.highlightIndexChange(1) },
  highlightPrevious () { this.highlightIndexChange(-1) },
  highlightIndexChange (incrementor) {
    if (this._currentHighlightIndex == null) { this._currentHighlightIndex = -1 }
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
      const section = this._lastType || this.selectedSectionName
      const type = sectionToTypes[section]
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
    if (this._lastResultsLength < searchBatchLength) { return this.stopLoadingSpinner() }

    this.showLoadingSpinner()
    this._searchOffset += searchBatchLength
    return this._search(this._lastSearch)
    .then(this.addNewResults.bind(this))
  },

  addNewResults (results) {
    const currentResultsUri = this.collection.map(model => model.get('uri'))
    const newResults = results.filter(result => !currentResultsUri.includes(result.uri))
    this._lastResultsLength = newResults.length
    return this.collection.add(newResults)
  },

  isSectionSelected (name) {
    const names = this.getSelectedSectionsNames()
    return names.includes(name)
  },

  getSelectedSectionsNames () {
    const selectedElements = this.$el.find('.selected')
    return getNamesFromIds(_.map(selectedElements, _.identity('id')))
  }
})

const sectionToTypes = {
  all: [ 'works', 'humans', 'series', 'publishers', 'collections', 'users', 'groups' ],
  book: 'works',
  author: 'humans',
  serie: 'series',
  collection: 'collections',
  publisher: 'publishers',
  subject: 'subjects',
  user: 'users',
  group: 'groups'
}

var sectionsWithAlternatives = [ 'book', 'author', 'serie', 'collection', 'publisher' ]

var isEntitiesSection = name => sectionsData().entitiesSections[name] != null

var isSocialSection = name => sectionsData().socialSections[name] != null

var getNamesFromIds = ids => _.map(ids, getSectionName)

var getSectionName = id => id.replace('section-', '')

var getSectionType = name => sectionToTypes[name]

// Pre-formatting is required to set the type
// Taking the opportunity to omit all non-required data
const formatSubject = result => ({
  id: result.id,
  label: result.label,
  description: result.description,
  uri: `wd:${result.id}`,
  type: 'subjects'
})

const formatEntity = function (entity) {
  if (entity?.toJSON == null) {
    error_.report('cant format invalid entity', { entity })
    return
  }

  const data = entity.toJSON()
  data.image = data.image?.url
  // Return a model to prevent having it re-formatted
  // as a Result model, which works from a result object, not an entity
  return new Backbone.Model(data)
}

var sectionsData = () => ({
  entitiesSections: {
    book: { label: 'book' },
    author: { label: 'author' },
    serie: { label: 'series_singular' },
    publisher: { label: 'publisher' },
    collection: { label: 'collection' },
    subject: { label: 'subject' }
  },

  socialSections: {
    user: { label: 'user' },
    group: { label: 'group' }
  }
})
