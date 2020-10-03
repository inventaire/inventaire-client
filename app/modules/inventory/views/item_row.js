import { isOpenedOutside } from 'lib/utils'
export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'item-row',
  template: require('./templates/item_row.hbs'),

  initialize () {
    ({ getSelectedIds: this.getSelectedIds, isMainUser: this.isMainUser, groupContext: this.groupContext } = this.options)
    this.listenTo(this.model, 'change', this.lazyRender.bind(this))

    if (!this.model.userReady) {
      return this.model.waitForUser.then(this.lazyRender.bind(this))
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
    if (isOpenedOutside(e)) {

    } else { app.execute('show:item', this.model) }
  },

  getCheckedStatus () {
    if (this.getSelectedIds != null) {
      return this.getSelectedIds().includes(this.model.id)
    } else {
      return false
    }
  }
})
