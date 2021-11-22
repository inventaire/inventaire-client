import { lazyMethod, icon } from 'lib/utils'
import getActionKey from 'lib/get_action_key'
import BrowserSelectorOptions from './browser_selector_options'
import screen_ from 'lib/screen'
import browserSelectorTemplate from './templates/browser_selector.hbs'

export default Marionette.View.extend({
  className: 'browser-selector',
  attributes () {
    // Value used as a CSS selector: [data-options="0"]
    return { 'data-options': this.count() }
  },

  template: browserSelectorTemplate,
  regions: {
    list: '.list'
  },

  initialize () {
    this.selectorName = this.options.name
    // Prevent the filter to re-filter (thus re-rendering the collection)
    // if the first value is ''
    this._lastValue = ''

    this.listenTo(app.vent, 'body:click', this.hideOptions.bind(this))
    this.listenTo(app.vent, 'browser:selector:click', this.hideOptions.bind(this))
  },

  ui: {
    filterField: 'input[name="filter"]',
    optionsList: '.options ul',
    selectorButton: '.selector-button',
    defaultMode: '.defaultMode',
    selectedMode: '.selectedMode',
    count: '.count'
  },

  serializeData () {
    return {
      name: this.selectorName,
      showFilter: this.count() > 5,
      count: this.count()
    }
  },

  // Overriden in subclasses
  count () { return this.collection.length },

  onRender () {
    this.showChildView('list', new BrowserSelectorOptions({ collection: this.collection }))
  },

  events: {
    'keydown input[name="filter"]': 'lazyUpdateFilter',
    'click .selector-button': 'toggleOptions',
    keydown: 'keyAction',
    // Prevent that a click to focus the input triggers a 'body:click' event
    'click input' (e) { e.stopPropagation() }
  },

  childViewEvents: {
    selectOption: 'selectOption'
  },

  lazyUpdateFilter: lazyMethod('updateFilter', 150),
  updateFilter (e) {
    const { value } = e.target
    if (value === this._lastValue) return
    this._lastValue = value
    return this.collectionsAction('filterByText', value)
  },

  showOptions () {
    this.$el.addClass('showOptions')
    this.ui.filterField.focus()
    return app.vent.trigger('browser:selector:click', this.cid)
  },

  // Pass a view cid if that specific view shouldn't hide its options
  // Used to close all selectors but one
  hideOptions (cid) {
    if (cid !== this.cid) this.$el.removeClass('showOptions')
  },

  toggleOptions (e) {
    const { classList } = e.target

    // Handle clicks on the 'x' close button
    if ((classList != null) && Array.from(classList).includes('fa-times')) {
      return this.resetOptions()
    }

    // When an option is already selected, the only option is to unselect it
    if (this._selectedOption != null) return

    if (this.$el.hasClass('showOptions')) {
      this.hideOptions()
    } else { this.showOptions() }

    e.stopPropagation()
  },

  keyAction (e) {
    const key = getActionKey(e)

    if (this._selectedOption != null) {
      switch (key) {
      case 'esc': case 'enter': return this.resetOptions()
      }
    } else {
      switch (key) {
      case 'esc': return this.hideOptions()
      case 'enter': return this.clickCurrentlySelected(e)
      case 'down': return this.selectSibling(e, 'next')
      case 'up': return this.selectSibling(e, 'prev')
      }
    }
  },

  // In the simplest case, navigable elements are all childrens of the same parent
  // but ./browser_owners_selector has a more complex case
  arrowNavigationSelector: '.browser-selector-li',

  selectSibling (e, relation) {
    this.showOptions()
    const $arrowNavigationElements = this.$el.find(this.arrowNavigationSelector)
    const $selected = this.$el.find('.selected')
    if ($selected.length === 1) {
      const currentIndex = $arrowNavigationElements.index($selected)
      $selected.removeClass('selected')
      const newIndex = relation === 'next' ? currentIndex + 1 : currentIndex - 1
      const $newlySelected = $arrowNavigationElements.eq(newIndex)
      $newlySelected.addClass('selected')
    } else {
      // If none is selected, depending of the arrow direction,
      // select the first or the last
      const position = relation === 'next' ? 'first' : 'last'
      this.$el.find(this.arrowNavigationSelector)[position]().addClass('selected')
    }

    // Adjust scroll to the selected element
    screen_.innerScrollTop(this.ui.optionsList, this.$el.find('.selected'))

    // Prevent arrow keys to make the screen move
    e.preventDefault()
  },

  clickCurrentlySelected () { this.$el.find('.selected').trigger('click') },

  selectOption (model) {
    this._selectedOption = model
    this.triggerMethod('filter:select', { selectorView: this, selectedOption: model })
    const labelSpan = `<span class='label'>${model.get('label')}</span>`
    this.ui.selectedMode.html(labelSpan + icon('times'))
    this.hideOptions()
    this.ui.selectorButton.addClass('active')
  },

  resetOptions () {
    this._selectedOption = null
    this.triggerMethod('filter:select', { selectorView: this, selectedOption: null })
    this.ui.selectorButton.removeClass('active')
    this.hideOptions()
    this.collectionsAction('removeFilter', 'text')
    this.updateCounter()
  },

  treeKeyAttribute: 'uri',

  filterOptions (intersectionWorkUris) {
    if ((intersectionWorkUris == null)) {
      this.collectionsAction('removeFilter', 'intersection')
    // Do not re-filter if this selector already has a selected option
    } else if (this._selectedOption != null) {
      return
    } else {
      const { treeSection } = this.options
      const filter = this._intersectionFilter.bind(this, treeSection, intersectionWorkUris)
      this.collectionsAction('filterBy', 'intersection', filter)
    }

    this.updateCounter()
  },

  _intersectionFilter (treeSection, intersectionWorkUris, model) {
    if (intersectionWorkUris.length === 0) return false
    const key = model.get(this.treeKeyAttribute)
    const worksUris = treeSection[key]
    // Known cases without worksUris: groups, nearby users
    if (worksUris == null) return false

    const count = this.getIntersectionCount(key, worksUris, intersectionWorkUris)
    if (count === 0) return false

    // /!\ Side effect
    // Set intersectionCount so that ./browser_selector_li can re-render
    // with an updated count. Do no set as an attribute, as this would
    // trigger a change event, which could (in some cases?) re-trigger a re-filter,
    // and thus an infinite loop.
    model._intersectionCount = count
    return true
  },

  getIntersectionCount (key, worksUris, intersectionWorkUris) {
    return _.intersection(worksUris, intersectionWorkUris).length
  },

  // To be overriden in subclasses that need to handle several collections
  collectionsAction (fnName, ...args) {
    return this.collection[fnName](...args)
  },

  updateCounter () {
    const remainingCount = this.count()
    this.ui.count.text(`(${remainingCount})`)
    this.$el.attr('data-options', remainingCount)
  }
})
