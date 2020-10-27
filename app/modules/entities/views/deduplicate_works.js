import getWorksMergeCandidates from '../lib/get_works_merge_candidates'
import WorkLi from './work_li'
import NoItem from 'modules/inventory/views/no_item'
import deduplicateWorksTemplate from './templates/deduplicate_works.hbs'

const DeduplicateWorksList = Marionette.CollectionView.extend({
  className: 'deduplicateWorksList',
  childView: WorkLi,
  tagName: 'ul',
  // Lazy empty view: not really fitting the context
  // but just showing that nothing was found
  emptyView: NoItem,
  childViewOptions: {
    showAllLabels: true,
    showActions: false,
    // Re-rendering loses candidates selections
    preventRerender: true
  }
})

export default Marionette.LayoutView.extend({
  className: 'deduplicateWorks',
  template: deduplicateWorksTemplate,
  regions: {
    wd: '.wdWorks',
    inv: '.invWorks'
  },

  initialize () {
    ({ mergedUris: this.mergedUris } = this.options)
  },

  onShow () {
    const { works } = this.options;
    ({ wd: this.wdModels, inv: this.invModels } = spreadByDomain(works))
    this.candidates = getWorksMergeCandidates(this.invModels, this.wdModels)
    this.showNextProbableDuplicates()
  },

  showNextProbableDuplicates () {
    this.$el.addClass('probableDuplicatesMode')
    const nextCandidate = this.candidates.shift()
    if (nextCandidate == null) { return this.next() }
    let { invModel, possibleDuplicateOf } = nextCandidate
    const invModelUri = invModel.get('uri')
    if (this.mergedUris.includes(invModelUri)) { return this.next() }

    // Filter-out entities that where already merged
    // @_currentFilter will be undefined on the first candidate round
    // as no merged happened yet, thus no filter was set
    if (this._currentFilter != null) {
      possibleDuplicateOf = possibleDuplicateOf.filter(this._currentFilter)
    }

    const mostProbableDuplicate = possibleDuplicateOf[0]
    if (mostProbableDuplicate == null) { return this.next() }
    // If the candidate duplicate was filtered-out, go to the next step
    const mostProbableDuplicateUri = mostProbableDuplicate.get('uri')
    if (this.mergedUris.includes(mostProbableDuplicateUri)) return this.next()

    const { wd: wdModels, inv: invModels } = spreadByDomain(possibleDuplicateOf)
    this.showList('wd', wdModels)
    this.showList('inv', [ invModel ].concat(invModels))
    // Give the views some time to initalize before expecting them
    // to be accessible in the DOM from their selectors
    this.setTimeout(this._showNextProbableDuplicatesUpdateUi.bind(this, invModel, mostProbableDuplicate), 200)
  },

  _showNextProbableDuplicatesUpdateUi (invModel, mostProbableDuplicate) {
    this.selectCandidates(invModel, mostProbableDuplicate)
    this.$el.trigger('next:button:show')
  },

  selectCandidates (from, to) {
    this.$el.trigger('entity:select', {
      uri: from.get('uri'),
      direction: 'from'
    })

    this.$el.trigger('entity:select', {
      uri: to.get('uri'),
      direction: 'to'
    }
    )
  },

  onMerge () { return this.next() },

  next () {
    // Once we got to the full lists, do not re-generate lists views
    // as you might loose the filter state
    if (this._listsShown) return

    if (this.candidates.length > 0) {
      this.showNextProbableDuplicates()
    } else {
      this.showLists()
    }
  },

  showLists () {
    this.$el.removeClass('probableDuplicatesMode')
    this.showList('wd', this.wdModels)
    this.showList('inv', this.invModels)
    this.$el.trigger('next:button:hide')
    this._listsShown = true
  },

  showList (regionName, models, sort = true) {
    if (models.length === 0) { return this[regionName].empty() }
    if (sort) { models.sort(sortAlphabetically) }
    const collection = new Backbone.Collection(models)
    this[regionName].show(new DeduplicateWorksList({ collection }))
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
      this.selectCandidates(invModel, wdModel)
    }
  },

  filterSubView (regionName, filter) {
    const view = this[regionName].currentView
    // Known case: when we are still at the 'probable duplicates' phase
    if (view == null) return
    view.filter = filter
    view.render()
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
  } else {
    return -1
  }
}
