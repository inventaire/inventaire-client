import { cutBeforeWord } from '#lib/utils'
import itemViewsCommons from '../lib/items_views_commons'
import itemCardTemplate from './templates/item_card.hbs'
import '../scss/item_card.scss'
import AlertBox from '#behaviors/alert_box'
import PreventDefault from '#behaviors/prevent_default'

const detailsLimit = 150

// ItemItemView = (inv)Item(Marionette)ItemView
const ItemItemView = Marionette.View.extend(itemViewsCommons)

export default ItemItemView.extend({
  tagName: 'figure',
  className () {
    const busy = this.model.get('busy') ? 'busy' : ''
    return `itemCard ${busy}`
  },
  template: itemCardTemplate,
  behaviors: {
    AlertBox,
    PreventDefault,
  },

  initialize () {
    this.alertBoxTarget = '.details'
  },

  modelEvents: {
    change: 'lazyRender',
    'user:ready': 'lazyRender'
  },

  onRender () {
    app.execute('uriLabel:update')
  },

  events: {
    'click button.transaction': 'updateTransaction',
    'click button.listing': 'updateListing',
    'click a.itemShow': 'itemShow',
    'click a.user': 'showUser',
    'click a.showUser': 'showUser',
    'click .requestItem' () { app.execute('show:item:request', this.model) }
  },

  serializeData () {
    const attrs = this.model.serializeData()
    attrs.date = { date: attrs.created }
    attrs.detailsMore = this.detailsMoreData(attrs.details)
    attrs.details = this.detailsData(attrs.details)
    attrs.showDistance = this.options.showDistance && (attrs.user?.distance != null)
    return attrs
  },

  itemEdit () {
    app.execute('show:item:form:edition', this.model)
  },

  detailsMoreData (details) {
    return details?.length > detailsLimit
  },

  detailsData (details) {
    if (details?.length > detailsLimit) {
      // Avoid to cut at the middle of a word as it might be a link
      // and thus the rendered link would be clickable but incomplete
      // Let a space before the ... so that it wont be taken as the end
      // of a link
      return cutBeforeWord(details, detailsLimit) + ' ...'
    } else {
      return details
    }
  },

  afterDestroy () {
    this.model.collection.remove(this.model)
  }
})
