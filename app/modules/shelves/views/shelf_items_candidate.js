import forms_ from 'modules/general/lib/forms'
import shelves_ from '../lib/shelves'

export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'shelf-items-candidate',
  template: require('./templates/shelf_items_candidate.hbs'),

  initialize () {
    ({ shelf: this.shelf } = this.options)
    this.shelfId = this.shelf.id
  },

  behaviors: {
    AlertBox: {}
  },

  serializeData () {
    return _.extend(this.model.serializeData(), {
      alreadyAdded: this.isAlreadyAdded()
    })
  },

  events: {
    'click .add': 'addToShelf',
    'click .remove': 'removeFromShelf',
    'click .showItem': 'showItem'
  },

  modelEvents: {
    'add:shelves': 'lazyRender',
    'remove:shelves': 'lazyRender'
  },

  showItem (e) {
    if (_.isOpenedOutside(e)) return
    app.execute('show:item', this.model)
  },

  addToShelf () {
    return shelves_.addItems(this.shelf, this.model)
    .catch(forms_.catchAlert.bind(null, this))
  },

  // Do no rename function to 'remove' as that would overwrite
  // Backbone.Marionette.View.prototype.remove
  removeFromShelf () {
    return shelves_.removeItems(this.shelf, this.model)
    .catch(forms_.catchAlert.bind(null, this))
  },

  isAlreadyAdded () {
    const shelvesIds = this.model.get('shelves') || []
    return shelvesIds.includes(this.shelfId)
  }
})
