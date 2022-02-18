import { isOpenedOutside } from '#lib/utils'
import itemRowTemplate from './templates/item_row.hbs'
import '../scss/item_row.scss'

export default Marionette.View.extend({
  tagName: 'li',
  className: 'item-row',
  template: itemRowTemplate,

  initialize () {
    ({ getSelectedIds: this.getSelectedIds, isMainUser: this.isMainUser, groupContext: this.groupContext } = this.options)
    this.listenTo(this.model, 'change', this.lazyRender.bind(this))

    if (!this.model.userReady) {
      this.model.waitForUser
      .then(this.lazyRender.bind(this))
    }
  },

  serializeData () {
    return _.extend(this.model.serializeData(), {
      checked: this.getCheckedStatus(),
      isMainUser: this.isMainUser,
      groupContext: this.groupContext
    })
  },

  events: {
    'click .showItem': 'showItem'
  },

  showItem (e) {
    if (!isOpenedOutside(e)) app.execute('show:item', this.model)
  },

  getCheckedStatus () {
    if (this.getSelectedIds != null) {
      return this.getSelectedIds().includes(this.model.id)
    } else {
      return false
    }
  }
})
