import { addItems, removeItems } from 'modules/shelves/lib/shelves'
import NoShelfView from './no_shelf'
import { startLoading } from 'modules/general/plugins/behaviors'
import forms_ from 'modules/general/lib/forms'
import itemShelfLiTemplate from './templates/item_shelf_li.hbs'
import 'modules/shelves/scss/item_shelves.scss'

const ItemShelfLi = Marionette.View.extend({
  tagName: 'li',
  className: 'shelfSelector',

  behaviors: {
    AlertBox: {},
    Loading: {}
  },

  template: itemShelfLiTemplate,

  initialize () {
    ({ item: this.item, itemsIds: this.itemsIds, selectedShelves: this.selectedShelves, mainUserIsOwner: this.mainUserIsOwner } = this.options)
    this.itemCreationMode = (this.selectedShelves != null)
    this.bulkMode = (this.itemsIds != null)
    // Init @_isSelected
    this.isSelected()
  },

  events: {
    'click .add': 'addShelf',
    'click .remove': 'removeShelf',
    click: 'toggleShelfSelector'
  },

  isSelected () {
    ({ item: this.item, selectedShelves: this.selectedShelves } = this.options)

    if (this.selectedShelves != null) {
      // Check @selectedShelves only on first run
      if (this._isSelected != null) {
        return this._isSelected
      } else {
        this._isSelected = this.selectedShelves.includes(this.model.id)
        return this._isSelected
      }
    } else if (this.item != null) {
      this._isSelected = this.item.isInShelf(this.model.id)
      return this._isSelected
    }
  },

  serializeData () {
    return _.extend(this.model.toJSON(), {
      isSelected: this._isSelected,
      mainUserIsOwner: this.mainUserIsOwner,
      bulkMode: this.bulkMode
    })
  },

  toggleShelfSelector () {
    if (this.bulkMode) return
    if (this.mainUserIsOwner) {
      this._isSelected = !this._isSelected
      if (!this.itemCreationMode) {
        if (this._isSelected) {
          addItems(this.model, [ this.item ])
        } else {
          removeItems(this.model, [ this.item ])
        }
      }
      this.render()
    } else {
      app.execute('show:shelf', this.model)
    }
  },

  onRender () {
    if (this.isSelected()) {
      this.$el.addClass('selected')
    } else {
      this.$el.removeClass('selected')
    }
  },

  addShelf () {
    startLoading.call(this, '.add .loading')
    return addItems(this.model, this.itemsIds)
    // TODO: update the inventory state without having to reload
    .then(() => app.execute('show:shelf', this.model.id))
    .catch(forms_.catchAlert.bind(null, this))
  },

  removeShelf () {
    startLoading.call(this, '.remove .loading')
    return removeItems(this.model, this.itemsIds)
    // TODO: update the inventory state without having to reload
    .then(() => app.execute('show:shelf', this.model.id))
    .catch(forms_.catchAlert.bind(null, this))
  }
})

export default Marionette.CollectionView.extend({
  id: 'itemShelves',
  tagName: 'ul',
  childView: ItemShelfLi,

  serializeData () { return { mainUserIsOwner: this.mainUserIsOwner } },

  childViewOptions () {
    return {
      item: this.options.item,
      selectedShelves: this.options.selectedShelves,
      itemsIds: this.options.itemsIds,
      mainUserIsOwner: this.options.mainUserIsOwner
    }
  },

  emptyView: NoShelfView
})
