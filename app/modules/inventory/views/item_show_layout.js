import ItemShowData from './item_show_data'
import EditionsList from 'modules/entities/views/editions_list'
import showAllAuthorsPreviewLists from 'modules/entities/lib/show_all_authors_preview_lists'
import itemShowTemplate from './templates/item_show_layout.hbs'
import 'modules/inventory/scss/item_show_layout.scss'
import log_ from 'lib/loggers'
import ItemShelves from './item_shelves'
import Shelves from 'modules/shelves/collections/shelves'
import { getShelvesByOwner, getByIds as getShelvesByIds } from 'modules/shelves/lib/shelves'
import itemViewsCommons from '../lib/items_views_commons'
const { itemDestroy } = itemViewsCommons

export default Marionette.LayoutView.extend({
  id: 'itemShowLayout',
  className: 'standalone',
  template: itemShowTemplate,

  regions: {
    itemData: '#itemData',
    shelvesSelector: '#shelvesSelector',
    authors: '.authors',
    scenarists: '.scenarists',
    illustrators: '.illustrators',
    colorists: '.colorists'
  },

  ui: {
    shelvesPanel: '.shelvesPanel',
    toggleShelvesExpand: '.toggleShelvesExpand'
  },

  behaviors: {
    General: {},
    PreventDefault: {}
  },

  initialize () {
    this.waitForEntity = this.model.grabEntity()
    this.waitForAuthors = this.model.waitForWorks.then(getAuthorsModels)
  },

  modelEvents: {
    grab: 'lazyRender',
    'change:shelves': 'updateShelves',
    'add:shelves': 'updateShelves',
  },

  events: {
    'click .preciseEdition': 'preciseEdition',
    'click .selectShelf': 'selectShelf',
    'click .toggleShelvesExpand': 'toggleShelvesExpand',
    'click a.remove': itemDestroy,
  },

  serializeData () {
    const attrs = this.model.serializeData()
    attrs.works = this.model.works?.map(work => work.toJSON())
    attrs.seriePathname = getSeriePathname(this.model.works)
    return attrs
  },

  onShow () {
    app.execute('modal:open', 'large')
  },

  onRender () {
    this.showItemData()
    this.showShelves()
    this.waitForAuthors.then(showAllAuthorsPreviewLists.bind(this))
  },

  showItemData () {
    this.itemData.show(new ItemShowData({ model: this.model }))
  },

  preciseEdition () {
    const { entity } = this.model
    if (entity.type !== 'work') { throw new Error('wrong entity type') }

    return entity.fetchSubEntities()
    .then(() => {
      app.layout.modal.show(new EditionsList({
        collection: entity.editions,
        work: entity,
        header: 'specify the edition',
        itemToUpdate: this.model
      })
      )
      app.execute('modal:open', 'large')
    })
  },

  showShelves () {
    return this.getShelves()
    .then(shelves => {
      this.shelves = new Shelves(shelves, { selected: this.model.get('shelves') })
    })
    .then(this.ifViewIsIntact('_showShelves'))
    .catch(log_.Error('showShelves err'))
  },

  getShelves () {
    if (this.model.mainUserIsOwner) {
      return getShelvesByOwner(app.user.id)
    } else {
      const itemShelves = this.model.get('shelves')
      if (itemShelves?.length <= 0) { return Promise.resolve([]) }
      return getShelvesByIds(itemShelves)
      .then(_.values)
    }
  },

  _showShelves () {
    if (this.shelves.length === 0) {
      this.ui.shelvesPanel.hide()
      return
    }

    return this.shelvesSelector.show(new ItemShelves({
      collection: this.shelves,
      item: this.model,
      mainUserIsOwner: this.model.mainUserIsOwner
    }))
  },

  selectShelf (e) {
    const shelfId = e.currentTarget.href.split('/').slice(-1)[0]
    app.execute('show:shelf', shelfId)
  },

  updateShelves () {
    if (this.model.mainUserIsOwner) {
      if (this.shelves.length > this.model.get('shelves').length) {
        this.ui.toggleShelvesExpand.show()
      } else {
        this.ui.toggleShelvesExpand.hide()
      }
    }
  },

  toggleShelvesExpand () {
    this.$el.find('.shelvesPanel').toggleClass('expanded')
  },

  itemDestroyBack () {
    if (this.model.isDestroyed) {
      app.execute('modal:close')
    } else {
      app.execute('show:item', this.model)
    }
  },

  afterDestroy () {
    // Force a refresh of the inventory, so that the deleted item doesn't appear
    app.execute('show:inventory:main:user')
  },
})

const getAuthorsModels = async works => {
  works = await Promise.all(works.map(work => work.getExtendedAuthorsModels()))
  return works.reduce(aggregateAuthorsPerProperty, {})
}

const getSeriePathname = function (works) {
  if (works?.length !== 1) return
  const work = works[0]
  const seriesUris = work.get('claims.wdt:P179')
  if (seriesUris?.length === 1) {
    const [ uri, pathname ] = work.gets('uri', 'pathname')
    // Hacky way to get the serie entity pathname without having to request its model
    return pathname.replace(uri, seriesUris[0])
  }
}

const aggregateAuthorsPerProperty = function (authorsPerProperty, workAuthors) {
  for (const property in workAuthors) {
    const authors = workAuthors[property] || []
    if (authorsPerProperty[property] == null) { authorsPerProperty[property] = [] }
    authorsPerProperty[property].push(...authors)
  }
  return authorsPerProperty
}
