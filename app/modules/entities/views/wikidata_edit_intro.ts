import { API } from '#app/api/api'
import app from '#app/app'
import wikidataEditIntroTemplate from './templates/wikidata_edit_intro.hbs'
import '../scss/wikidata_edit_intro.scss'

export default Marionette.View.extend({
  className: 'wikidata-edit-intro',
  template: wikidataEditIntroTemplate,

  onRender () { app.execute('modal:open', 'medium') },

  serializeData () {
    const attrs = this.model.toJSON()
    attrs.isLoggedIn = app.user.loggedIn
    attrs.wikidataOauth = API.auth.oauth.wikidata + `&redirect=${attrs.edit}`
    attrs.wikidataIntro = 'https://www.wikidata.org/wiki/Wikidata:Introduction'
    return attrs
  },

  events: {
    'click .loginRequest': 'showLogin',
  },

  showLogin () {
    // No need to call show:login:redirect as it is called by the General behavior
    // on app_layout(?)
    app.execute('modal:close')
  },

  onModalExit () { app.execute('show:entity', this.model.get('uri')) },
})
