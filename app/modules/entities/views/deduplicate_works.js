import getWorksMergeCandidates from '../lib/get_works_merge_candidates'

const DeduplicateWorksList = Marionette.CollectionView.extend({
  className: 'deduplicateWorksList',
  childView: require('./work_li'),
  tagName: 'ul',
  // Lazy empty view: not really fitting the context
  // but just showing that nothing was found
  emptyView: require('modules/inventory/views/no_item'),
  childViewOptions: {
    showAllLabels: true,
    showActions: false,
    // Re-rendering loses candidates selections
    preventRerender: true
  }
})

export default Marionette.LayoutView.extend({
  className: 'deduplicateWorks',
  template: require('./templates/deduplicate_works'),
  regions: {
    wd: '.wdWorks',
    inv: '.invWorks'
  },

  initialize () {
    return ({ mergedUris: this.mergedUris } = this.options)
  },

  onShow () {
    const { works } = this.options;
    ({ wd: this.wdModels, inv: this.invModels } = spreadByDomain(works))
    this.candidates = getWorksMergeCandidates(this.invModels, this.wdModels)
    return this.showNextProbableDuplicates()
  },

  showNextProbableDuplicates () {
    let needle, needle1
    this.$el.addClass('probableDuplicatesMode')
    const nextCandidate = this.candidates.shift()
    if (nextCandidate == null) { return this.next() }
    let { invModel, possibleDuplicateOf } = nextCandidate
    if ((needle = invModel.get('uri'), this.mergedUris.includes(needle))) { return this.next() }

    // Filter-out entities that where already merged
    // @_currentFilter will be undefined on the first candidate round
    // as no merged happened yet, thus no filter was set
    if (this._currentFilter != null) {
      possibleDuplicateOf = possibleDuplicateOf.filter(this._currentFilter)
    }

    const mostProbableDuplicate = possibleDuplicateOf[0]
    if (mostProbableDuplicate == null) { return this.next() }
    // If the candidate duplicate was filtered-out, go to the next step
    if ((needle1 = mostProbableDuplicate.get('uri'), this.mergedUris.includes(needle1))) { return this.next() }

    const { wd: wdModels, inv: invModels } = spreadByDomain(possibleDuplicateOf)
    this.showList('wd', wdModels)
    this.showList('inv', [ invModel ].concat(invModels))
    // Give the views some time to initalize before expecting them
    // to be accessible in the DOM from their selectors
    return this.setTimeout(this._showNextProbableDuplicatesUpdateUi.bind(this, invModel, mostProbableDuplicate), 200)
  },

  _showNextProbableDuplicatesUpdateUi (invModel, mostProbableDuplicate) {
    this.selectCandidates(invModel, mostProbableDuplicate)
    return this.$el.trigger('next:button:show')
  },

  selectCandidates (from, to) {
    this.$el.trigger('entity:select', {
      uri: from.get('uri'),
      direction: 'from'
    })

    return this.$el.trigger('entity:select', {
      uri: to.get('uri'),
      direction: 'to'
    }
    )
  },

  onMerge () { return this.next() },

  next () {
    // Once we got to the full lists, do not re-generate lists views
    // as you might loose the filter state
    if (this._listsShown) { return }

    if (this.candidates.length > 0) {
      return this.showNextProbableDuplicates()
    } else { return this.showLists() }
  },

  showLists () {
    this.$el.removeClass('probableDuplicatesMode')
    this.showList('wd', this.wdModels)
    this.showList('inv', this.invModels)
    this.$el.trigger('next:button:hide')
    return this._listsShown = true
  },

  showList (regionName, models, sort = true) {
    if (models.length === 0) { return this[regionName].empty() }
    if (sort) { models.sort(sortAlphabetically) }
    const collection = new Backbone.Collection(models)
    return this[regionName].show(new DeduplicateWorksList({ collection }))
  },

  setFilter (filter) {
    this._currentFilter = filter
    this.filterSubView('wd', filter)
    this.filterSubView('inv', filter)

    // @showList might have emptied the view
    const wdChildren = this.wd.currentView?.children
    const invChildren = this.inv.currentView?.children
    if ((wdChildren?.length === 1) && (invChildren?.length === 1)) {
      const wdModel = _.values(wdChildren._views)[0].model
      const invModel = _.values(invChildren._views)[0].model
      return this.selectCandidates(invModel, wdModel)
    }
  },

  filterSubView (regionName, filter) {
    const view = this[regionName].currentView
    // Known case: when we are still at the 'probable duplicates' phase
    if (view == null) { return }
    view.filter = filter
    return view.render()
  }
})

const spreadByDomain = models => models.reduce(spreadWorks, { wd: [], inv: [] })

const spreadWorks = function (data, work) {
  const prefix = work.get('prefix')
  data[prefix].push(work)
  return data
}

const sortAlphabetically = function (a, b) {
  if (a.get('label').toLowerCase() > b.get('label').toLowerCase()) {
    return 1
  } else { return -1 }
}
