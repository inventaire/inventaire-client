import { buildPath } from '#lib/location'
import { fixedEncodeURIComponent } from '#lib/utils'
import authorizeMenuTemplate from './templates/authorize_menu.hbs'
import { domain, host } from '#app/lib/urls'
import '../scss/authorize_menu.scss'

export default Marionette.View.extend({
  className: 'authMenu authorizeMenu',
  template: authorizeMenuTemplate,

  initialize () {
    this.query = this.options.query
    this.client = this.options.client
    this.query.redirect_uri = fixedEncodeURIComponent(this.query.redirect_uri)
    this.authorizeUrl = buildPath(app.API.oauth.authorize, this.query)
    this.requestedAccessRights = getRequestedAccessRights(this.query.scope)
  },

  serializeData () {
    return Object.assign({}, this.query, {
      authorizeUrl: this.authorizeUrl,
      name: this.client.name,
      username: app.user.get('username'),
      home: host,
      domain,
      description: this.client.description,
      requestedAccessRights: this.requestedAccessRights,
    })
  }
})

const getRequestedAccessRights = scope => {
  return scope
  .split(/[+\s]/)
  .map(accessRight => ({
    key: accessRight,
    label: accessRightCustomLabels[accessRight] || accessRight,
  }))
}

const accessRightCustomLabels = {
  email: 'access your email address',
  'stable-username': 'access your username',
}
