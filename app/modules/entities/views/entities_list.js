import loader from 'modules/general/views/templates/loader.hbs'
import error_ from 'lib/error'
import EntitiesListAdder from './entities_list_adder'
import { currentRoute } from 'lib/location'
import SerieLayout from './serie_layout'
import WorkLi from './work_li'
import ArticleLi from './article_li'
import EditionLi from './edition_li'
import AuthorLayout from './author_layout'
import PublisherLayout from './publisher_layout'
import CollectionLayout from './collection_layout'
import entitiesListTemplate from './templates/entities_list.hbs'

// TODO:
// - deduplicate series in sub series https://inventaire.io/entity/wd:Q740062
// - hide series parts when displayed as sub-series

const viewByType = {
  serie: SerieLayout,
  work: WorkLi,
  article: ArticleLi,
  // Types included despite not being works
  // to make this view reusable by ./claim_layout with those types.
  // This view should thus possibily be renamed entities_list
  edition: EditionLi,
  human: AuthorLayout,
  publisher: PublisherLayout,
  collection: CollectionLayout,
}

export default Marionette.CompositeView.extend({
  template: entitiesListTemplate,
  className () {
    const standalone = this.options.standalone ? 'standalone' : ''
    return `entitiesList ${standalone}`
  },
  behaviors: {
    Loading: {},
    PreventDefault: {}
  },

  childViewContainer: '.container',
  tagName () { if (this.options.type === 'edition') { return 'ul' } else { return 'div' } },

  getChildView (model) {
    const { type } = model
    const View = viewByType[type]
    if (View != null) return View
    const err = error_.new(`unknown entity type: ${type}`, model)
    // Weird: errors thrown here don't appear anyware
    // where are those silently catched?!?
    console.error('entities_list getChildView err', err, model)
    throw err
  },

  childViewOptions (model, index) {
    return {
      refresh: this.options.refresh,
      showActions: this.options.showActions,
      wrap: this.options.wrapWorks,
      compactMode: this.options.compactMode
    }
  },

  ui: {
    counter: '.counter',
    more: '.displayMore',
    addOne: '.addOne',
    moreCounter: '.displayMore .counter'
  },

  initialize () {
    ({ parentModel: this.parentModel, addButtonLabel: this.addButtonLabel } = this.options)
    this.childrenClaimProperty = this.options.childrenClaimProperty || this.parentModel.childrenClaimProperty
    const initialLength = this.options.initialLength || 5
    this.batchLength = this.options.batchLength || 15

    this.fetchMore = this.collection.fetchMore.bind(this.collection)
    this.more = this.collection.more.bind(this.collection)

    this.collection.firstFetch(initialLength)
  },

  serializeData () {
    return {
      title: this.options.title,
      customTitle: this.options.customTitle,
      hideHeader: this.options.hideHeader,
      more: this.more(),
      totalLength: this.collection.totalLength,
      addButtonLabel: this.addButtonLabel
    }
  },

  events: {
    'click .displayMore': 'displayMore',
    'click .addOne': 'addOne'
  },

  displayMore () {
    this.startMoreLoading()

    return this.collection.fetchMore(this.batchLength)
    .then(() => {
      if (this.more()) {
        this.ui.moreCounter.text(this.more())
      } else {
        this.ui.more.hide()
        this.ui.addOne.removeClass('hidden')
      }
    })
  },

  startMoreLoading () {
    this.ui.moreCounter.html(loader())
  },

  addOne (e) {
    if (!app.request('require:loggedIn', currentRoute())) return
    const { type, parentModel } = this.options
    app.layout.modal.show(new EntitiesListAdder({
      header: this.addOneLabel,
      type,
      childrenClaimProperty: this.childrenClaimProperty,
      parentModel,
      listCollection: this.collection,
    }))
    // Prevent nested entities list to trigger that same event on the parent list
    return e.stopPropagation()
  }
})
