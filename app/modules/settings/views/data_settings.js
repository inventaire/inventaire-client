import behaviorsPlugin from 'modules/general/plugins/behaviors'
import { apiDoc } from 'lib/urls'
const { host, protocol } = window.location

export default Marionette.ItemView.extend({
  template: require('./templates/data_settings'),
  className: 'dataSettings',
  behaviors: {
    AlertBox: {},
    SuccessCheck: {},
    Loading: {}
  },

  initialize () { return _.extend(this, behaviorsPlugin) },

  serializeData () {
    const username = app.user.get('username')
    return {
      apiDoc,
      inventoryJsonEndpoint: `/api/items?action=by-users&users=${app.user.id}&limit=100000`,
      userJsonEndpoint: '/api/user',
      curlBase: `$ curl ${protocol}//${username.toLowerCase()}:yourpassword@${host}`
    }
  }
})
