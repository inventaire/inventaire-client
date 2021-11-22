import { isOpenedOutside } from 'lib/utils'
import { buildPath } from 'lib/location'
import EntitiesListElementCandidate from './entities_list_element_candidate'
import typeSearch from 'modules/entities/lib/search/type_search'
import PaginatedEntities from 'modules/entities/collections/paginated_entities'
import AutocompleteNoSuggestion from 'modules/entities/views/editor/autocomplete_no_suggestion'
import entitiesListAdderTemplate from './templates/entities_list_adder.hbs'
import '../scss/entities_list_adder.scss'

const cantTypeSearch = [
  'edition'
]

export default Marionette.CollectionView.extend({
  id: 'entitiesListAdder',
  template: entitiesListAdderTemplate,
  childViewContainer: '.entitiesListElementCandidates',
  childView: EntitiesListElementCandidate,
  childViewOptions () {
    return {
      parentModel: this.options.parentModel,
      listCollection: this.options.listCollection,
      childrenClaimProperty: this.options.childrenClaimProperty
    }
  },

  emptyView: AutocompleteNoSuggestion,

  ui: {
    candidates: '.entitiesListElementCandidates'
  },

  initialize () {
    ({ type: this.type, parentModel: this.parentModel, childrenClaimProperty: this.childrenClaimProperty } = this.options)
    this.childrenClaimProperty = this.childrenClaimProperty || this.parentModel.childrenClaimProperty
    this.cantTypeSearch = cantTypeSearch.includes(this.type)
    this.setEntityCreationData()
    this.collection = new PaginatedEntities(null, { uris: [] })
    this.addCandidates()
  },

  serializeData () {
    return {
      parent: this.parentModel.toJSON(),
      header: this.options.header,
      createPath: this.createPath,
      cantTypeSearch: this.cantTypeSearch
    }
  },

  onRender () {
    app.execute('modal:open', 'medium')
    // Doesn't work if set in events for some reason
    this.ui.candidates.on('scroll', this.onScroll.bind(this))
  },

  events: {
    'click .create': 'create',
    'click .done' () { app.execute('modal:close') },
    'keydown #searchCandidates': 'lazySearch'
  },

  setEntityCreationData () {
    const { parentModel } = this
    const { type: parentType } = parentModel

    const claims = {}
    const prop = this.childrenClaimProperty
    claims[prop] = [ parentModel.get('uri') ]

    if (parentType === 'serie') {
      claims['wdt:P50'] = parentModel.get('claims.wdt:P50')
    } else if (parentType === 'collection') {
      claims['wdt:P123'] = parentModel.get('claims.wdt:P123')
    }

    const href = buildPath('/entity/new', { type: this.type, claims })

    this.createPath = href
    this._entityCreationData = { type: this.type, claims }
  },

  lazySearch (e) {
    if (this._lazySearch == null) {
      this._lazySearch = _.debounce(this.search.bind(this), 200)
    }
    this._lazySearch(e)
  },

  search (e) {
    let { value: input } = e.currentTarget
    input = input.trim()

    if (input === '') {
      if (this._lastInput != null) {
        this._lastInput = null
        this.addCandidates()
      }
    } else {
      this._lastInput = input
      this.searchByType(input)
    }
  },

  searchByType (input, initialCandidatesSearch) {
    return typeSearch(this.type, input, 50)
    .then(results => {
      // Ignore the results if the input changed
      if ((input !== this._lastInput) && !initialCandidatesSearch) return
      const uris = _.pluck(results, 'uri')
      return this.resetFromUris(uris)
    })
  },

  addCandidates () {
    if (this.parentModel.getChildrenCandidatesUris != null) {
      this.$el.addClass('fetching')
      if (this._waitForParentModelChildrenCandidatesUris == null) this._waitForParentModelChildrenCandidatesUris = this.parentModel.getChildrenCandidatesUris()
      return this._waitForParentModelChildrenCandidatesUris.then(this.resetFromUris.bind(this))
    } else if (this.options.canSearchListCandidatesFromLabel && !this.cantTypeSearch) {
      const label = this.parentModel.get('label')
      this.$el.addClass('fetching')
      this._findCandidatesFromLabelSearch = true
      // TODO: filter-out results that are likely bad suggestions
      // such as an author's books, when we are looking for books *about* (wdt:P921) that author
      this.searchByType(label, true)
    }
  },

  resetFromUris (uris = []) {
    this.$el.removeClass('fetching')
    return this.collection.resetFromUris(uris)
  },

  onScroll (e) {
    const visibleHeight = this.ui.candidates.height()
    const { scrollHeight, scrollTop } = e.currentTarget
    const scrollBottom = scrollTop + visibleHeight
    if (scrollBottom === scrollHeight) return this.collection.fetchMore()
  },

  create (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:entity:create', this._entityCreationData)
    app.execute('modal:close')
  }
})
