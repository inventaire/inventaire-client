import { getUserBasePathname } from '#users/lib/users'
import Notification from './notification.js'

export default Notification.extend({
  initSpecific () {
    return this.grabAttributeModel('user')
  },

  serializeData () {
    const attrs = this.toJSON()
    attrs.username = this.user?.get('username')
    attrs.picture = this.user?.get('picture')
    attrs.pathname = getUserBasePathname(attrs.username)
    return attrs
  }
})
