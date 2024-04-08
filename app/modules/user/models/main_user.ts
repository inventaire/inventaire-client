import cookie_ from 'js-cookie'
import app from '#app/app'
import notificationsList from '#settings/lib/notifications_settings_list'
import UserCommons from '#users/models/user_commons'
import { initI18n } from '../lib/i18n.ts'
import { solveLang } from '../lib/solve_lang.ts'

const { location } = window

export default UserCommons.extend({
  isMainUser: true,
  url () { return app.API.user },

  parse (data) {
    if (data.type === 'deletedUser') return app.execute('logout')
    data.settings = this.setDefaultSettings(data.settings)
    data.summaryPeriodicity = data.summaryPeriodicity || 20
    data.customProperties = data.customProperties || []
    return data
  },

  initialize () {
    this.on('change:language', this.changeLanguage.bind(this))
    this.on('change:username', this.setPathname.bind(this))
    this.on('change:picture', this.setDefaultPicture.bind(this))

    // Only listening for first change (when the main user data arrive)
    // as next changes happening in deep objects won't trigger this event anyway
    this.once('change:snapshot', this.setAllInventoryStats.bind(this))
    // this.on('items:change', this.updateItemsCounters.bind(this))
    this.on('shelves:change', this.updateShelvesCounter.bind(this))
    this.on('listings:change', this.updateListingsCounter.bind(this))

    // user._id should only change once from undefined to defined
    this.once('change:_id', (model, id) => app.execute('track:user:id', id))

    this.set('itemsCategory', 'personal')

    // If the user is logged in, this will wait for their document to arrive
    // Else, it will fire at next tick.
    app.request('wait:for', 'user')
    .then(this.lateInitialize.bind(this))
  },

  lateInitialize () {
    this.lang = solveLang(this.get('language'))
    initI18n(this.lang)
    this.setDefaultPicture()
    const accessLevels = this.get('accessLevels')
    if (accessLevels == null) return
    this.hasAdminAccess = accessLevels.includes('admin')
    this.hasDataadminAccess = accessLevels.includes('dataadmin')
  },

  // Two valid language change cases:
  // - The user isn't logged in and change the language from the top bar selector
  // - The user is logged in and change the language from their profile settings
  changeLanguage () {
    if (app.polyglot == null) return

    const lang = this.get('language')
    if (lang === app.polyglot.currentLocale) return

    let reloadHref = window.location.href
    if (app.request('querystring:get', 'lang') != null) {
      // Prevent the querystring to override the language change
      // Can't just pass null to 'querystring:set' due to its limitations
      reloadHref = reloadHref
        .replace(/&?lang=\w+/, '')
        // If all there is left from the querystring is a '?', remove it
        .replace(/\?$/, '')
    }

    const reload = () => { location.href = reloadHref }

    if (this.loggedIn) {
      // Wait for the server confirmation as we keep the language setting
      // in the user's document
      // This event is triggered by app/lib/model_update.js
      this.once('confirmed:language', reload)
    } else {
      // the language setting is persisted as a cookie instead
      cookie_.set('lang', lang)
      reload()
    }
  },

  setDefaultSettings (settings) {
    const { notifications = {} } = settings
    settings.notifications = this.setDefaultNotificationsSettings(notifications)
    return settings
  },

  setDefaultNotificationsSettings (notifications) {
    for (const notif of notificationsList) {
      notifications[notif] = notifications[notif] !== false
    }
    return notifications
  },

  serializeData (nonPrivate) {
    const attrs = this.toJSON()
    attrs.mainUser = true
    attrs.inventoryLength = this.inventoryLength(nonPrivate)
    return attrs
  },

  inventoryLength (nonPrivate) {
    if (nonPrivate) {
      return this.get('itemsCount') - this.get('privateItemsCount')
    } else {
      return this.get('itemsCount')
    }
  },

  updateItemsCounters (previousListing, newListing) {
    const snapshot = this.get('snapshot')
    if (previousListing != null) snapshot[previousListing]['items:count'] -= 1
    if (newListing != null) snapshot[newListing]['items:count'] += 1
    this.set('snapshot', snapshot)
    this.setAllInventoryStats()
  },

  updateListingsCounter (action) {
    let listingsCount = this.get('listingsCount')
    if (action === 'createListing') listingsCount += 1
    else if (action === 'removeListing') listingsCount -= 1
    this.set('listingsCount', listingsCount)
    this.setAllInventoryStats()
  },

  updateShelvesCounter (action) {
    let shelvesCount = this.get('shelvesCount')
    if (action === 'createShelf') shelvesCount += 1
    else if (action === 'removeShelf') shelvesCount -= 1
    this.set('shelvesCount', shelvesCount)
    this.setAllInventoryStats()
  },

  setAllInventoryStats () {
    this.setInventoryStats()
    this.set('privateItemsCount', this.get('snapshot').private['items:count'])
    this.set('inventoryLength', this.inventoryLength(false))
  },

  deleteAccount () {
    console.log('starting to play "Somebody that I use to know" and cry a little bit')

    return this.destroy()
    .then(() => app.execute('logout'))
  },

  hasWikidataOauthTokens () {
    const oauthList = this.get('oauth')
    return (oauthList != null) && oauthList.includes('wikidata')
  },
})
