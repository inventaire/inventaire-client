import ItemsPreviewLists from '../views/items_preview_lists'

// Sharing logic between work_layout and edition_layout
export default {
  initialize () {
    this.waitForItems = this.model.getItemsByCategories()
    return this.lazyShowItems = _.debounce(showItemsPreviewLists.bind(this), 100)
  }
}

const showItemsPreviewLists = function () {
  return this.waitForItems
  .then(itemsByCategory => {
    // Happens when app/modules/entities/views/editions_list.coffee
    // are displayed within work_layout and thus re-redered on filter
    if (this.isDestroyed) { return }
    if (app.user.loggedIn) {
      showItemsPreviews.call(this, itemsByCategory, 'personal')
      // TODO: replace network by only friends and groups,
      // moving non-confirmed friends to public items
      showItemsPreviews.call(this, itemsByCategory, 'network')
    }
    if (app.user.has('position')) {
      showItemsPreviews.call(this, itemsByCategory, 'nearbyPublic')
      showItemsPreviews.call(this, itemsByCategory, 'otherPublic')
    } else {
      showItemsPreviews.call(this, itemsByCategory, 'public')
    }

    return this.$el.find('.items-lists-loader').hide()
  })
}

const showItemsPreviews = function (itemsByCategory, category) {
  const itemsModels = itemsByCategory[category]
  const compact = !this.options.standalone
  return this[`${category}ItemsRegion`].show(new ItemsPreviewLists({
    category,
    itemsModels,
    compact,
    displayItemsCovers: this.displayItemsCovers
  }))
}
