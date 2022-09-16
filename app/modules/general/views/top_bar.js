import { clickCommand } from '#lib/utils'
import { translate } from '#lib/urls'
import GlobalSearchBar from '#search/components/global_search_bar.svelte'
import TopBarButtons from './top_bar_buttons.js'
import screen_ from '#lib/screen'
import { currentRoute, currentSection } from '#lib/location'
import languages from '#assets/js/languages_data'
import topBarTemplate from './templates/top_bar.hbs'
import { removeCurrentComponent } from '#lib/global_libs_extender'
import { debounce } from 'underscore'

const mostCompleteFirst = (a, b) => b.completion - a.completion
const languagesList = _.values(languages).sort(mostCompleteFirst)

export default Marionette.View.extend({
  id: 'top-bar',
  tagName: 'nav',
  className () {
    return app.user.loggedIn ? 'logged-in' : ''
  },
  template: topBarTemplate,

  regions: {
    globalSearchBar: '#globalSearchBar',
    topBarButtons: '#topBarButtons'
  },

  ui: {
    searchField: '#searchField',
  },

  initialize () {
    const lazySafeRender = debounce(this.safeRender.bind(this), 200)

    this.listenTo(app.vent, {
      'screen:mode:change': lazySafeRender,
      'route:change': this.onRouteChange.bind(this),
    })

    this.listenTo(app.user, 'change:picture', lazySafeRender)
  },

  serializeData () {
    return {
      smallScreen: screen_.isSmall(),
      isLoggedIn: app.user.loggedIn,
      currentLanguage: languages[app.user.lang].native,
      currentLanguageShortName: languages[app.user.lang].lang.toUpperCase(),
      languages: languagesList,
      translate
    }
  },

  onRender () {
    if (app.user.loggedIn) this.showTopBarButtons()
    // Needed as 'route:change' might have been triggered before
    // this view was initialized
    this.onRouteChange(currentSection(), currentRoute())
    this.setTimeout(this.showGlobalSearchBar.bind(this), 0)
  },

  safeRender () {
    // The component needs to be destroyed before the rerender
    // as it otherwise produces type errors
    removeCurrentComponent(this.getRegion('globalSearchBar'))
    this.render()
  },

  showTopBarButtons () {
    // Use a child view for those buttons to be able to re-render them independenly
    // without disrupting the GlobalSearchBar state
    this.showChildView('topBarButtons', new TopBarButtons())
  },

  onRouteChange (section, route) {
    this.updateConnectionButtons(section)
  },

  events: {
    'click #home': clickCommand('show:home'),
    'focus #goToMain': 'closeSearch',
    'focus #language-picker': 'closeSearch',
    'click #language-picker .option button': 'selectLang',
  },

  closeSearch () {
    document.getElementById('closeSearch')?.click()
  },

  updateConnectionButtons (section) {
    if (app.user.loggedIn) return

    if (screen_.isSmall() && ((section === 'signup') || (section === 'login'))) {
      return $('.connectionButton').hide()
    } else if (!app.user.loggedIn) {
      $('.connectionButton').show()
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

  showGlobalSearchBar () {
    this.showChildComponent('globalSearchBar', GlobalSearchBar, {
      props: {}
    })
  },
})
