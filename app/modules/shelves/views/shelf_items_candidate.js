import { isOpenedOutside } from 'lib/utils'
import forms_ from 'modules/general/lib/forms'
import * as shelves_ from '../lib/shelves'
import shelfItemsCandidateTemplate from './templates/shelf_items_candidate.hbs'

export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'shelf-items-candidate',
  template: shelfItemsCandidateTemplate,

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
    if (isOpenedOutside(e)) return
    app.execute('show:item', this.model)
  },

  addToShelf () {
    return shelves_.addItems(this.shelf, this.model)
    .catch(forms_.catchAlert.bind(null, this))
  },

  // Do no rename function to 'remove' as that would overwrite
  // Marionette.View.prototype.remove
  removeFromShelf () {
    return shelves_.removeItems(this.shelf, this.model)
    .catch(forms_.catchAlert.bind(null, this))
  },

  isAlreadyAdded () {
    const shelvesIds = this.model.get('shelves') || []
    return shelvesIds.includes(this.shelfId)
  }
})
