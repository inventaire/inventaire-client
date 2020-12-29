import ItemsPreviewList from './items_preview_list'
import itemsPreviewListsTemplate from './templates/items_preview_lists.hbs'
import '../scss/items_preview_lists.scss'

export default Marionette.LayoutView.extend({
  className () {
    let className = 'itemsPreviewLists'
    if (this.options.compact) className += ' compact'
    if (this.options.itemsModels?.length <= 0) className += ' emptyLists'
    return className
  },

  template: itemsPreviewListsTemplate,

  regions: {
    givingRegion: '.giving',
    lendingRegion: '.lending',
    sellingRegion: '.selling',
    inventoryingRegion: '.inventorying'
  },

  initialize () {
    ({ category: this.category, itemsModels: this.itemsModels, compact: this.compact, displayItemsCovers: this.displayItemsCovers } = this.options)
    this.itemsWithPositionCount = this.itemsModels?.filter(item => item.hasPosition()).length || 0
    if (this.itemsModels?.length > 0) {
      this.collections = spreadByTransactions(this.itemsModels)
    } else {
      this.emptyList = true
    }
  },

  serializeData () {
    return {
      header: headers[this.category],
      emptyList: this.emptyList,
      canShowOnMap: !this.emptyList && (this.itemsWithPositionCount > 0)
    }
  },

  events: {
    'click .showOnMap': 'showOnMap'
  },

  onShow () {
    if (!this.emptyList) this.showItemsPreviewLists()
  },

  showItemsPreviewLists () {
    for (const transaction in this.collections) {
      const collection = this.collections[transaction]
      this[`${transaction}Region`].show(new ItemsPreviewList({
        transaction,
        collection,
        displayItemsCovers: this.displayItemsCovers,
        compact: this.compact
      }))
    }
  },

  showOnMap () {
    if (!this._itemsPositionsSet) {
      this.itemsModels.forEach(model => { model.position = model.user?.get('position') })
      this._itemsPositionsSet = true
    }
    // Add the main user to the list to make sure the map shows their position
    app.execute('show:models:on:map', this.itemsModels.concat([ app.user ]))
  }
})

const spreadByTransactions = function (itemsModels) {
  const collections = {}
  for (const itemModel of itemsModels) {
    const transaction = itemModel.get('transaction')
    if (!collections[transaction]) collections[transaction] = new Backbone.Collection()
    collections[transaction].add(itemModel)
  }

  return collections
}

const headers = {
  personal: {
    label: 'in your inventory',
    icon: 'user'
  },
  network: {
    label: "in your friends' and groups' inventories",
    icon: 'users'
  },
  public: {
    label: 'public',
    icon: 'globe'
  },
  nearbyPublic: {
    label: 'nearby',
    icon: 'map-marker'
  },
  otherPublic: {
    label: 'elsewhere',
    icon: 'globe'
  }
}
