import { clickCommand } from 'lib/utils'
import { translate } from 'lib/urls'
import getActionKey from 'lib/get_action_key'
import LiveSearch from 'modules/search/views/live_search'
import TopBarButtons from './top_bar_buttons'
import screen_ from 'lib/screen'
import { currentRoute, currentSection } from 'lib/location'
import languages from 'lib/languages_data'
import topBarTemplate from './templates/top_bar.hbs'

const mostCompleteFirst = (a, b) => b.completion - a.completion
const languagesList = _.values(languages).sort(mostCompleteFirst)

export default Marionette.LayoutView.extend({
  id: 'top-bar',
  tagName: 'nav',
  className () {
    return app.user.loggedIn ? 'logged-in' : ''
  },
  template: topBarTemplate,

  regions: {
    liveSearch: '#liveSearch',
    topBarButtons: '#topBarButtons'
  },

  ui: {
    searchField: '#searchField',
    overlay: '#overlay',
    closeSearch: '.closeSearch'
  },

  initialize () {
    this.listenTo(app.vent, {
      'screen:mode:change': this.lazyRender.bind(this),
      'route:change': this.onRouteChange.bind(this),
      'live:search:show:result': this.hideLiveSearch.bind(this),
      'live:search:query': this.setQuery.bind(this)
    })

    this.listenTo(app.user, 'change:picture', this.lazyRender.bind(this))
  },

  serializeData () {
    return {
      smallScreen: screen_.isSmall(),
      isLoggedIn: app.user.loggedIn,
      currentLanguage: languages[app.user.lang].native,
      languages: languagesList,
      translate
    }
  },

  onRender () {
    if (app.user.loggedIn) this.showTopBarButtons()
    // Needed as 'route:change' might have been triggered before
    // this view was initialized
    this.onRouteChange(currentSection(), currentRoute())
  },

  showTopBarButtons () {
    // Use a child view for those buttons to be able to re-render them independenly
    // without disrupting the LiveSearch state
    this.topBarButtons.show(new TopBarButtons())
  },

  onRouteChange (section, route) {
    this.updateConnectionButtons(section)
  },

  events: {
    'click #home': clickCommand('show:home'),

    'focus #searchField': 'showLiveSearch',
    'blur #searchField': 'hideLiveSearch',
    'keyup #searchField': 'onKeyUp',
    'keydown #searchField': 'onKeyDown',
    'click .searchSection': 'recoverSearchFocus',
    click: 'updateLiveSearch',
    'click .closeSearch': 'closeSearch',
    'click #live-search': 'closeSearchOnOverlayClick',

    'click #language-picker .option a': 'selectLang'
  },

  childEvents: {
    'hide:live:search': 'hideLiveSearch'
  },

  updateConnectionButtons (section) {
    if (app.user.loggedIn) return

    if (screen_.isSmall() && ((section === 'signup') || (section === 'login'))) {
      return $('.connectionButton').hide()
    } else if (!app.user.loggedIn) {
      return $('.connectionButton').show()
    }
  },

  selectLang (e) {
    // Remove the querystring lang parameter to be sure that the picked language
    // is the next language taken in account
    app.execute('querystring:set', 'lang', null)

    const lang = e.currentTarget.attributes['data-lang'].value
    if (app.user.loggedIn) {
      return app.request('user:update', {
        attribute: 'language',
        value: lang,
        selector: '#languagePicker'
      }
      )
    } else {
      return app.user.set('language', lang)
    }
  },

  // Do not use default parameter `(params = {})`
  // as the router might pass `null` as first argument
  showLiveSearch (params) {
    params = params || {}
    // If a section is specified, reinitialize the search view
    // to take that section request into account
    if ((this.liveSearch.currentView != null) && (params.section == null)) {
      this.liveSearch.$el.show()
    } else { this.liveSearch.show(new LiveSearch(params)) }
    this.liveSearch.$el.addClass('shown')
    this.liveSearch.currentView.resetHighlightIndex()
    this.liveSearch.currentView.showSearchSettings()
    this.ui.overlay.removeClass('hidden')
    this.ui.closeSearch.removeClass('hidden')
    this._liveSearchIsShown = true
  },

  hideLiveSearch (triggerFallbackLayout) {
    // Discard non-boolean flags
    triggerFallbackLayout = (triggerFallbackLayout === true) && (currentRoute() === 'search')

    if (this.liveSearch.$el == null) return

    this.liveSearch.$el.hide()
    this.liveSearch.$el.removeClass('shown')
    this.ui.overlay.addClass('hidden')
    this.ui.closeSearch.addClass('hidden')
    this._liveSearchIsShown = false
    // Trigger the fallback layout only in cases when no other layout
    // is set to be displayed
    if (triggerFallbackLayout && (this.showFallbackLayout != null)) {
      this.showFallbackLayout()
      this.showFallbackLayout = null
    }
  },

  updateLiveSearch (e) {
    // Make clicks on anything but the search group hide the live search
    const { target } = e
    if ((target.id === 'overlay') || ($(target).parents('#searchGroup').length === 0)) {
      return this.hideLiveSearch(true)
    }
  },

  onKeyDown (e) {
    // Prevent the cursor to move when using special keys
    // to navigate the live_search list
    const key = getActionKey(e)
    if (neutralizedKeys.includes(key)) e.preventDefault()
  },

  onKeyUp (e) {
    if (!this._liveSearchIsShown) this.showLiveSearch()

    const key = getActionKey(e)
    if (key != null) {
      if (key === 'esc') {
        return this.hideLiveSearch(true)
      } else {
        return this.liveSearch.currentView.onSpecialKey(key)
      }
    } else {
      const { value } = e.currentTarget
      return this.searchLive(value)
    }
  },

  searchLive (text) {
    this.liveSearch.currentView.lazySearch(text)
    return app.vent.trigger('search:global:change', text)
  },

  setQuery (params) {
    let search, section;
    ({ search, showFallbackLayout: this.showFallbackLayout, section } = params)
    this.showLiveSearch({ section })
    this.searchLive(search)
    this.ui.searchField.focus()
    // Set value after focusing so that the cursor appears at the end
    // cf https://stackoverflow.com/a/8631903/3324977inv
    this.ui.searchField.val(search)
  },

  // When clicking on a live_search searchField button, the search loose the focus
  // thus the need to recover it
  recoverSearchFocus () {
    this.ui.searchField.focus()
    this.liveSearch.currentView.hideSearchSettings()
  },

  closeSearch () {
    this.ui.searchField.val('')
    return this.hideLiveSearch()
  },

  // If the click event is directly on the live search element
  // that means that it was outside the search results or sections
  // and should be interpreted as a close request
  // This can be the case on small screens as #live-search takes all the height
  // and thus clicks on #overlay won't be detected
  closeSearchOnOverlayClick (e) {
    if (e.target.id === 'live-search') return this.closeSearch()
  }
})

const neutralizedKeys = [ 'up', 'down', 'pageup', 'pagedown' ]
