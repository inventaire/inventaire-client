import preq from '#lib/preq'
import usersHomeLayoutTemplate from '#users/views/templates/users_home_layout.hbs'
import '#users/scss/users_home_layout.scss'
import UsersHomeNav from '#users/views/users_home_nav.js'
import InventoryBrowser from '#inventory/components/inventory_browser.svelte'
import UserProfile from '#users/views/user_profile.js'
import InventoryOrListingNav from '#users/components/inventory_or_listing_nav.svelte'
import GroupProfile from '#users/views/group_profile.js'
import ShelfBox from '#shelves/components/shelf_box.svelte'
import ShelvesSection from '#shelves/components/shelves_section.svelte'
import NetworkUsersNav from '#users/views/network_users_nav.js'
import PublicUsersNav from '#users/views/public_users_nav.js'
import showPaginatedItems from '#welcome/lib/show_paginated_items'
import screen_ from '#lib/screen'
import InventoryWelcome from '#inventory/views/inventory_welcome.js'
import error_ from '#lib/error'

const navs = {
  network: NetworkUsersNav,
  public: PublicUsersNav
}

export default Marionette.View.extend({
  id: 'usersHomeLayout',
  template: usersHomeLayoutTemplate,
  regions: {
    usersHomeNav: '#usersHomeNav',
    sectionNav: '#sectionNav',
    groupProfile: '#groupProfile',
    userProfile: '#userProfile',
    inventoryOrListingNav: '#inventoryOrListingNav',
    listings: '#listings',
    shelvesList: '#shelvesList',
    shelfInfo: '#shelfInfo',
    itemsList: '#itemsList'
  },

  initialize () {
    ;({
      user: this.user,
      group: this.group,
      shelf: this.shelf,
      standalone: this.standalone
    } = this.options)
    this.listenTo(app.vent, 'inventory:select', this.showSelectedInventory.bind(this))
    this.listenTo(app.vent, 'close:shelf', this.closeShelf.bind(this))
    this.listenTo(app.vent, 'show:inventory:or:listing:section', this.showInventoryOrListingSection.bind(this))
    this.listenTo(app.vent, 'show:main:user:listings', this.showMainUserListingsLayout.bind(this))
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
      this.showUsersHomeNav(section)
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
      if (this.options.listings) return this.showUserListingsLayout(userModel)
      this._lastShownType = 'user'
      this._lastShownUser = userModel
      this.showUserProfile(userModel)
      this.showInventoryOrListingNav({ userModel, section: 'inventory' })
      if (shelf) {
        this.showShelf(shelf)
      } else if (this.options.withoutShelf) {
        this.showItemsWithoutShelf()
      } else {
        this.showUserInventory(userModel)
        app.navigateFromModel(userModel, 'inventoryPathname')
      }
      let section = userModel.get('itemsCategory')
      if (section === 'personal') section = 'user'
      this.showUsersHomeNav(section)
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
      this.showUsersHomeNav()
      this.showGroupProfile(groupModel)
      app.navigateFromModel(groupModel)
      this.scrollToSection('groupProfile')
    })
    .catch(app.Execute('show:error'))
  },

  showShelf (shelf) {
    const itemsDataPromise = getItemsData('shelf', shelf)
    const isMainUser = app.user.id === shelf.get('owner')
    this.showChildComponent('shelfInfo', ShelfBox, {
      props: {
        shelf: shelf.toJSON()
      }
    })
    this.showChildComponent('itemsList', InventoryBrowser, {
      props: {
        itemsDataPromise,
        isMainUser,
        shelfId: shelf.get('_id'),
      }
    })
    this.waitForShelvesList.then(() => this.scrollToSection('shelfInfo'))
  },

  showItemsWithoutShelf () {
    const itemsDataPromise = getItemsData('without-shelf')
    this.showChildComponent('shelfInfo', ShelfBox, {
      props: {
        withoutShelf: true,
      }
    })
    this.showChildComponent('itemsList', InventoryBrowser, {
      props: {
        itemsDataPromise,
        isMainUser: true,
      }
    })
    this.waitForShelvesList.then(() => this.scrollToSection('shelfInfo'))
  },

  showUserShelves (userIdOrModel) {
    this.waitForShelvesList = app.request('resolve:to:userModel', userIdOrModel)
      .then(userModel => {
        if (!this.isIntact()) return
        if ((this.getRegion('shelvesList').currentComponent != null) && (userModel === this._lastShownUser)) return
        const shelvesCount = userModel.get('shelvesCount')
        if (shelvesCount === 0) return
        const username = userModel.get('username')
        const { isMainUser } = userModel
        this.showChildComponent('shelvesList', ShelvesSection, {
          props: {
            username,
            delayBeforeScrollToSection,
            isMainUser,
          }
        })
      })
      .catch(app.Execute('show:error'))
  },

  showUserInventory (userModel) {
    app.navigateFromModel(userModel, 'inventoryPathname')
    this.getRegion('listings').empty()
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

  showInventoryOrListingNav (options) {
    const { userModel, groupModel, section: currentSection } = options
    const { _id: userId, listingsCount } = userModel.toJSON()
    const isMainUser = userId === app.user.get('_id')
    // always display if main user,  in order to create new listing
    if (groupModel || listingsCount > 0 || isMainUser) {
      this.showChildComponent('inventoryOrListingNav', InventoryOrListingNav, {
        props: {
          groupModel,
          userModel,
          currentSection
        }
      })
    }
  },

  showInventoryOrListingSection ({ userModel, section }) {
    if (section === 'inventory') this.showInventorySection(userModel)
    else if (section === 'listings') this.showListingsSection(userModel)
    else throw error_.new('unknown section', 400, { section })
  },

  async showInventorySection (userModel) {
    this.showUserInventory(userModel)
    this.showUserProfile(userModel)
    this.getRegion('shelvesList').empty()
    this.showChildComponent('shelvesList', ShelvesSection, {
      props: {
        username: userModel.get('username')
      }
    })
    app.navigateFromModel(userModel, 'inventoryPathname')
  },

  async showUserListingsLayout (userModel) {
    this.showUsersHomeNav('user')
    this.showListingsSection(userModel)
    this.showUserProfile(userModel)
    this.showInventoryOrListingNav({ userModel, section: 'listings' })
  },

  async showMainUserListingsLayout () {
    const userModel = app.user
    return this.showUserListingsLayout(userModel)
  },

  async showListingsSection (userModel) {
    try {
      const { default: UserListings } = await import('#listings/components/user_listings.svelte')
      this.showChildComponent('listings', UserListings, {
        props: {
          user: userModel.toJSON()
        }
      })
      this.getRegion('shelvesList').empty()
      this.getRegion('shelfInfo').empty()
      this.getRegion('itemsList').empty()
      app.navigateFromModel(userModel, 'listingsPathname')
    } catch (err) {
      app.execute('show:error', err)
    }
  },

  showUsersHomeNav (section) {
    if (!app.user.loggedIn) return
    section = !this.standalone || (section === 'user') ? section : undefined
    this.showChildView('usersHomeNav', new UsersHomeNav({ section }))
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
    let groupId, ownerId
    if (model.get('type') === 'group') {
      groupId = model.id
    } else {
      ownerId = model.id
    }
    this.showChildComponent('itemsList', InventoryBrowser, {
      props: {
        itemsDataPromise,
        isMainUser,
        ownerId,
        groupId,
      }
    })
  },

  async showSectionLastItems (section) {
    if (section === 'public' && app.user.get('position') == null) return
    showPaginatedItems({
      requestName: sectionRequest[section],
      layout: this,
      regionName: 'itemsList',
      limit: 20,
      allowMore: true,
      showDistance: section === 'public'
    })
  },

  closeShelf () {
    this.showInventoryBrowser(this._lastShownType, this._lastShownUser)
    this.scrollToSection('userProfile')
    this.getRegion('shelfInfo').empty()
    app.navigateFromModel(this._lastShownUser, { pathAttribute: 'inventoryPathname', preventScrollTop: true })
  },

  showSelectedInventory (type, model) {
    if (type === 'user') {
      this._lastShownType = type
      this._lastShownUser = model
      this.showUserInventory(model)
      this.showInventoryOrListingNav({ userModel: model, section: 'inventory' })
      this.showUserProfile(model)
      this.getRegion('groupProfile').empty()
      this.getRegion('shelfInfo').empty()
      this.getRegion('shelvesList').empty()
      this.showUserShelves(model)
      this.scrollToSection('userProfile')
    } else if (type === 'group') {
      this.showGroupProfile(model)
      this.getRegion('userProfile').empty()
      this.getRegion('shelfInfo').empty()
      this.getRegion('shelvesList').empty()
      this.showInventoryOrListingNav({ groupModel: model, section: 'inventory' })
      this.showGroupInventory(model)
      this.scrollToSection('groupProfile')
    } else if (type === 'member') {
      this._lastShownType = type
      this._lastShownUser = model
      this.showMemberInventory(model)
      this.showInventoryOrListingNav({ userModel: model, section: 'inventory' })
      this.showUserShelves(model)
    } else if (type === 'shelf') {
      const userId = model.get('owner')
      this.showUserShelves(userId)
      this.showShelf(model)
    } else if (type === 'without-shelf') {
      this.showItemsWithoutShelf()
    }

    this.getRegion('listings').empty()
    if (type === 'without-shelf') {
      app.navigate('/shelves/without', { preventScrollTop: true })
    } else {
      app.navigateFromModel(model, { pathAttribute: 'inventoryPathname', preventScrollTop: true })
    }
  },

  scrollToSection (regionName) {
    if (!this.isIntact()) return
    const region = this.getRegion(regionName)
    const $el = (region.$el?.[0] != null) ? region.$el : $(region.el)
    screen_.scrollTop({ $el, marginTop: 10, delay: delayBeforeScrollToSection })
  }
})

const delayBeforeScrollToSection = 500

const getItemsData = function (type, model) {
  let params
  if (type === 'without-shelf') {
    params = { user: app.user.id, 'without-shelf': true }
  } else {
    const modelId = model.get('_id')
    params = { [type]: modelId }
  }
  return preq.get(app.API.items.inventoryView(params))
}

const sectionRequest = {
  network: 'items:getNetworkItems',
  public: 'items:getNearbyItems'
}

