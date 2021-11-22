import { isOpenedOutside } from 'lib/utils'
import { i18n } from 'modules/user/lib/i18n'
import itemPreviewTemplate from './templates/item_preview.hbs'

export default Marionette.View.extend({
  template: itemPreviewTemplate,
  className () {
    let className = 'item-preview'
    if (this.options.compact) className += ' compact'
    return className
  },

  behaviors: {
    PreventDefault: {}
  },

  onShow () {
    if (this.model.user == null) this.model.waitForUser.then(this.lazyRender.bind(this))
  },

  serializeData () {
    const transaction = this.model.get('transaction')
    const attrs = this.model.serializeData()
    return _.extend(attrs, {
      title: buildTitle(this.model.user, transaction),
      distanceFromMainUser: this.model.user.distanceFromMainUser,
      compact: this.options.compact,
      displayCover: this.options.displayItemsCovers && (attrs.picture != null)
    })
  },

  events: {
    'click .showItem': 'showItem'
  },

  showItem (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:item', this.model)
  }
})

const buildTitle = function (user, transaction) {
  if (user == null) return
  const username = user.get('username')
  let title = i18n(`${transaction}_personalized`, { username })
  if (user.distanceFromMainUser != null) {
    title += ` (${i18n('km_away', { distance: user.distanceFromMainUser })})`
  }
  return title
}
