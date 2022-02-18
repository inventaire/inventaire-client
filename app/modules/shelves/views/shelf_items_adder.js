import { isOpenedOutside } from '#lib/utils'
import preq from '#lib/preq'
import ShelfItemsCandidates from './shelf_items_candidate.js'
import Item from '#inventory/models/item'
import AutocompleteNoSuggestion from '#entities/views/editor/autocomplete_no_suggestion'
import shelfItemsAdderTemplate from './templates/shelf_items_adder.hbs'
import '../scss/shelf_items_adder.scss'

// Like modules/inventory/collections/items.js but without comparator
const Items = Backbone.Collection.extend({ model: Item })

export default Marionette.CollectionView.extend({
  id: 'shelfItemsAdder',
  template: shelfItemsAdderTemplate,
  childViewContainer: '.shelfItemsCandidates',
  childView: ShelfItemsCandidates,
  childViewOptions () {
    return { shelf: this.options.model }
  },

  emptyView: AutocompleteNoSuggestion,

  ui: {
    candidates: '.shelfItemsCandidates'
  },

  initialize () {
    this.collection = new Items()
    this.offset = 0
    this.limit = 20
    this.suggestLastItems()
  },

  onRender () {
    app.execute('modal:open')
    // Doesn't work if set in events for some reason
    this.ui.candidates.on('scroll', this.onScroll.bind(this))
  },

  events: {
    'click .create': 'create',
    'click .addNewItems': 'addNewItems',
    'click .done': 'onDone',
    'keydown #searchCandidates': 'lazySearch'
  },

  lazySearch (e) {
    if (this._lazySearch == null) this._lazySearch = _.debounce(this.search.bind(this), 200)
    return this._lazySearch(e)
  },

  search (e) {
    let { value: input } = e.currentTarget
    input = input.trim()

    if (input === '') {
      if (this._lastInput != null) {
        this._lastInput = null
        this.offset = 0
        this.suggestLastItems()
        return
      } else {
        this.$el.removeClass('fetching')
        return
      }
    }

    this._lastMode = 'search'
    this._lastInput = input
    this.$el.addClass('fetching')

    return preq.get(app.API.items.search(app.user.id, input))
    .then(({ items }) => {
      this.offset += this.limit
      if (this._lastInput === input) {
        this.$el.removeClass('fetching')
        return this.collection.reset(items)
      }
    })
  },

  onScroll (e) {
    const visibleHeight = this.ui.candidates.height()
    const { scrollHeight, scrollTop } = e.currentTarget
    const scrollBottom = scrollTop + visibleHeight
    if (scrollBottom === scrollHeight) return this.fetchMore()
  },

  suggestLastItems () {
    this.$el.addClass('fetching')
    this._lastMode = 'last'
    return app.request('items:getUserItems', { model: app.user, offset: this.offset, limit: this.limit })
    .then(({ items }) => {
      if (this._lastMode === 'last') {
        this.$el.removeClass('fetching')
        if (this.offset === 0) {
          return this.collection.reset(items)
        } else {
          return this.collection.add(items)
        }
      }
    })
  },

  fetchMore () {
    if (this._lastMode === 'last') {
      this.offset += this.limit
      return this.suggestLastItems()
    }
  },

  addNewItems (e) {
    const shelfId = this.model.id
    app.execute('last:shelves:set', [ shelfId ])
    if (isOpenedOutside(e)) return
    app.execute('modal:close')
    app.execute('show:add:layout')
  },

  // Known limitation: this function will only be called when the user clicks
  // the 'done' button, not when closing the modal by clicking the 'close' or
  // clicking outside the modal; meaning that in those case, the shelf inventory
  // won't be refreshed
  onDone () {
    // Refresh the shelf data
    app.vent.trigger('inventory:select', 'shelf', this.model)
    app.execute('modal:close')
  }
})
