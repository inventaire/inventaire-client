import preq from '#lib/preq'
import InventoryNav from './inventory_nav.js'
import InventoryBrowser from './inventory_browser.js'
import UserProfile from './user_profile.js'
import GroupProfile from './group_profile.js'
import ShelfBox from '../../shelves/views/shelf_box'
import ShelvesSection from '#shelves/components/shelves_section.svelte'
import InventoryNetworkNav from './inventory_network_nav.js'
import InventoryPublicNav from './inventory_public_nav.js'
import showPaginatedItems from '#welcome/lib/show_paginated_items'
import screen_ from '#lib/screen'
import InventoryWelcome from './inventory_welcome.js'
import inventoryLayoutTemplate from './templates/inventory_layout.hbs'
import '../scss/inventory_layout.scss'
import error_ from '#lib/error'

const navs = {
  network: InventoryNetworkNav,
  public: InventoryPublicNav
}

export default Marionette.View.extend({
  id: 'inventoryLayout',
  template: inventoryLayoutTemplate,
  regions: {
    inventoryNav: '#inventoryNav',
    sectionNav: '#sectionNav',
    groupProfile: '#groupProfile',
    userProfile: '#userProfile',
    shelvesList: '#shelvesList',
    shelfInfo: '#shelfInfo',
    itemsList: '#itemsList'
  },

  initialize () {
    ({ user: this.user, group: this.group, shelf: this.shelf, standalone: this.standalone } = this.options)
    this.listenTo(app.vent, 'inventory:select', this.showSelectedInventory.bind(this))
  },

  childViewEvents: {
    'close:shelf': 'closeShelf'
  },

  onRender () {
    if (this.user != null) {
      this.startFromUser(this.user, this.shelf)
      this.showUserShelves(this.user)
    } else if (this.group != null) {
      this.startFromGroup(this.group)
    } else {
      const { section, filter } = this.options
      this.showInventoryNav(section)
      this.showSectionNav(section)
      if (filter == null) this.showSectionLastItems(section)
    }
  },

  startFromUser (user, shelf) {
    return app.request('resolve:to:userModel', user)
    .then(userModel => {
      if (userModel.deleted) {
        const { _id: id, username } = userModel.attributes
        throw error_.new('This user has been deleted', 400, { id, username })
      }
      this._lastShownType = 'user'
      this._lastShownUser = userModel
      if (shelf) {
        this.showShelf(shelf)
      } else {
        this.showUserInventory(userModel)
        app.navigateFromModel(userModel)
      }
      this.showUserProfile(userModel)
      let section = userModel.get('itemsCategory')
      if (section === 'personal') section = 'user'
      this.showInventoryNav(section)
      this.showSectionNav(section, 'user', userModel)
      // Do not scroll when showing the main user's inventory
      // to keep the other nav elements visible
      if (section !== 'user') this.scrollToSection('userProfile')
    })
    .catch(app.Execute('show:error'))
  },

  startFromGroup (group) {
    app.request('resolve:to:groupModel', group)
    .then(async groupModel => {
      if (!this.isIntact()) return
      await this.showGroupInventory(groupModel)
      if (!this.isIntact()) return
      this.showInventoryNav()
      this.showGroupProfile(groupModel)
      app.navigateFromModel(groupModel)
      this.scrollToSection('groupProfile')
    })
    .catch(app.Execute('show:error'))
  },

  showShelf (shelf) {
    const itemsDataPromise = getItemsData('shelf', shelf)
    const isMainUser = app.user.id === shelf.get('owner')
    this.showChildView('shelfInfo', new ShelfBox({ model: shelf }))
    this.showChildView('itemsList', new InventoryBrowser({ itemsDataPromise, isMainUser }))
    this.waitForShelvesList.then(() => this.scrollToSection('shelfInfo'))
  },

  showUserShelves (userIdOrModel) {
    this.waitForShelvesList = app.request('resolve:to:userModel', userIdOrModel)
      .then(userModel => {
        if ((this.getRegion('shelvesList').currentComponent != null) && (userModel === this._lastShownUser)) return
        const shelvesCount = userModel.get('shelvesCount')
        if (shelvesCount === 0) return
        const username = userModel.get('username')
        // this.showChildView('shelvesList', new ShelvesSection({ username }))
        this.showChildComponent('shelvesList', ShelvesSection, { props: { username } })
        // return this.getRegion('shelvesList').currentComponent.waitForList
      })
      .catch(app.Execute('show:error'))
  },

  showUserInventory (userModel) {
    if ((userModel === app.user) && (userModel.get('itemsCount') === 0)) {
      this.showInventoryWelcome()
    } else {
      this.showInventoryBrowser('user', userModel)
    }
  },

  showInventoryWelcome () {
    this.showChildView('itemsList', new InventoryWelcome())
  },

  async showGroupInventory (groupModel) {
    await groupModel.beforeShow()
    if (this.isIntact()) this.showInventoryBrowser('group', groupModel)
  },

  async showMemberInventory (member) {
    const memberModel = await app.request('resolve:to:userModel', member)
    if (!this.isIntact()) return
    this.showUserProfile(memberModel)
    this.showInventoryBrowser('user', memberModel)
    this.scrollToSection('userProfile')
  },

  showGroupProfile (groupModel) {
    this.showChildView('groupProfile', new GroupProfile({ model: groupModel }))
  },

  showUserProfile (userModel) {
    this.showChildView('userProfile', new UserProfile({ model: userModel }))
  },

  showInventoryNav (section) {
    if (!app.user.loggedIn) return
    section = !this.standalone || (section === 'user') ? section : undefined
    this.showChildView('inventoryNav', new InventoryNav({ section }))
  },

  showSectionNav (section, type, model) {
    if (this.standalone || !app.user.loggedIn) return
    const SectionNav = navs[section]
    if (SectionNav == null) return
    const options = (type != null) && (model != null) ? { [type]: model } : {}
    options.filter = this.options.filter
    this.showChildView('sectionNav', new SectionNav(options))
  },

  showInventoryBrowser (type, model) {
    const itemsDataPromise = getItemsData(type, model)
    const isMainUser = model?.isMainUser
    this.showChildView('itemsList', new InventoryBrowser({ itemsDataPromise, isMainUser }))
  },

  showSectionLastItems (section) {
    if (section === 'public' && app.user.get('position') == null) {
      // Hide loading spinner
      this.getRegion('itemsList').empty()
    } else {
      showPaginatedItems({
        request: sectionRequest[section],
        layout: this,
        regionName: 'itemsList',
        limit: 20,
        allowMore: true,
        showDistance: section === 'public'
      })
    }
  },

  closeShelf () {
    this.showInventoryBrowser(this._lastShownType, this._lastShownUser)
    this.scrollToSection('userProfile')
    this.getRegion('shelfInfo').empty()
    app.navigateFromModel(this._lastShownUser, { preventScrollTop: true })
  },

  showSelectedInventory (type, model) {
    if (type === 'user') {
      this._lastShownType = type
      this._lastShownUser = model
      this.showUserInventory(model)
      this.showUserProfile(model)
      this.getRegion('groupProfile').empty()
      this.getRegion('shelvesList').empty()
      this.showUserShelves(model)
      this.scrollToSection('userProfile')
    } else if (type === 'group') {
      this.showGroupProfile(model)
      this.getRegion('userProfile').empty()
      this.getRegion('shelfInfo').empty()
      this.getRegion('shelvesList').empty()
      this.showGroupInventory(model)
      this.scrollToSection('groupProfile')
    } else if (type === 'member') {
      this._lastShownType = type
      this._lastShownUser = model
      this.showMemberInventory(model)
      this.showUserShelves(model)
    } else if (type === 'shelf') {
      const userId = model.get('owner')
      this.showUserShelves(userId)
      this.showShelf(model)
    }

    app.navigateFromModel(model, { preventScrollTop: true })
  },

  scrollToSection (regionName) {
    if (!this.isIntact()) return
    screen_.scrollTop({ $el: this.getRegion(regionName).$el, marginTop: 10, delay: 100 })
  }
})

const getItemsData = function (type, model) {
  const modelId = model.get('_id')
  const params = { [type]: modelId }
  return preq.get(app.API.items.inventoryView(params))
}

const sectionRequest = {
  network: 'items:getNetworkItems',
  public: 'items:getNearbyItems'
}

