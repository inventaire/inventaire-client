/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-unused-vars,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import loader from 'modules/general/views/templates/loader'
import error_ from 'lib/error'
import EntitiesListAdder from './entities_list_adder'
import { currentRoute } from 'lib/location'

// TODO:
// - deduplicate series in sub series https://inventaire.io/entity/wd:Q740062
// - hide series parts when displayed as sub-series

export default Marionette.CompositeView.extend({
  template: require('./templates/entities_list'),
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
    switch (type) {
    case 'serie': return require('./serie_layout')
    case 'work': return require('./work_li')
    case 'article': return require('./article_li')
      // Types included despite not being works
      // to make this view reusable by ./claim_layout with those types.
      // This view should thus possibily be renamed entities_list
    case 'edition': return require('./edition_li')
    case 'human': return require('./author_layout')
    case 'publisher': return require('./publisher_layout')
    case 'collection': return require('./collection_layout')
    default:
      var err = error_.new(`unknown entity type: ${type}`, model)
      // Weird: errors thrown here don't appear anyware
      // where are those silently catched?!?
      console.error('entities_list getChildView err', err, model)
      throw err
    }
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
    let childrenType;
    ({ parentModel: this.parentModel, addButtonLabel: this.addButtonLabel } = this.options)
    this.childrenClaimProperty = this.options.childrenClaimProperty || this.parentModel.childrenClaimProperty
    const initialLength = this.options.initialLength || 5
    this.batchLength = this.options.batchLength || 15

    this.fetchMore = this.collection.fetchMore.bind(this.collection)
    this.more = this.collection.more.bind(this.collection)

    this.collection.firstFetch(initialLength)

    const parentType = this.parentModel.type
    return childrenType = this.options.type
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
        return this.ui.moreCounter.text(this.more())
      } else {
        this.ui.more.hide()
        return this.ui.addOne.removeClass('hidden')
      }
    })
  },

  startMoreLoading () {
    return this.ui.moreCounter.html(loader())
  },

  addOne (e) {
    if (!app.request('require:loggedIn', currentRoute())) { return }
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
