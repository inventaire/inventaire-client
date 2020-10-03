import { isOpenedOutside } from 'lib/utils'
export default Marionette.ItemView.extend({
  template: require('./templates/inventory_nav.hbs'),
  initialize () {
    return ({ section: this.section } = this.options)
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
    return e.preventDefault()
  }
})
