import { isOpenedOutside } from '#lib/utils'
import usersHomeNavTemplate from './templates/users_home_nav.hbs'

export default Marionette.View.extend({
  template: usersHomeNavTemplate,
  initialize () {
    this.section = this.options.section
  },

  serializeData () {
    return {
      user: app.user.toJSON(),
      section: this.section
    }
  },

  events: {
    'click #tabs a': 'selectTab'
  },

  selectTab (e) {
    if (isOpenedOutside(e)) return
    const section = e.currentTarget.id.replace('Tab', '')
    app.execute('show:inventory:section', section)
    e.preventDefault()
  }
})
