/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import itemViewsCommons from '../lib/items_views_commons'
const detailsLimit = 150
const ItemItemView = Marionette.ItemView.extend(itemViewsCommons)

export default ItemItemView.extend({
  tagName: 'figure',
  className () {
    const busy = this.model.get('busy') ? 'busy' : ''
    return `itemCard ${busy}`
  },
  template: require('./templates/item_card'),
  behaviors: {
    PreventDefault: {},
    AlertBox: {}
  },

  initialize () {
    return this.alertBoxTarget = '.details'
  },

  modelEvents: {
    change: 'lazyRender',
    'user:ready': 'lazyRender'
  },

  onRender () {
    return app.execute('uriLabel:update')
  },

  events: {
    'click a.transaction': 'updateTransaction',
    'click a.listing': 'updateListing',
    'click a.remove': 'itemDestroy',
    'click a.itemShow': 'itemShow',
    'click a.user': 'showUser',
    'click a.showUser': 'showUser',
    'click a.requestItem' () { return app.execute('show:item:request', this.model) }
  },

  serializeData () {
    const attrs = this.model.serializeData()
    attrs.date = { date: attrs.created }
    attrs.detailsMore = this.detailsMoreData(attrs.details)
    attrs.details = this.detailsData(attrs.details)
    attrs.showDistance = this.options.showDistance && (attrs.user?.distance != null)
    return attrs
  },

  itemEdit () { return app.execute('show:item:form:edition', this.model) },

  detailsMoreData (details) {
    if (details?.length > detailsLimit) {
      return true
    } else { return false }
  },

  detailsData (details) {
    if (details?.length > detailsLimit) {
      // Avoid to cut at the middle of a word as it might be a link
      // and thus the rendered link would be clickable but incomplete
      // Let a space before the ... so that it wont be taken as the end
      // of a link
      return _.cutBeforeWord(details, detailsLimit) + ' ...'
    } else {
      return details
    }
  },

  afterDestroy () { return this.model.collection.remove(this.model) }
})
