import { isOpenedOutside } from 'lib/utils'
import inventoryNavTemplate from './templates/inventory_nav.hbs'

export default Marionette.ItemView.extend({
  template: inventoryNavTemplate,
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
