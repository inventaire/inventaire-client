import { images } from 'lib/urls'
import callToConnectionTemplate from './templates/call_to_connection.hbs'
import '../scss/call_to_connect.scss'

const { banner } = images

export default Marionette.ItemView.extend({
  template: callToConnectionTemplate,
  onShow () { app.execute('modal:open') },
  serializeData () {
    return _.extend(this.options, { banner })
  },

  events: {
    // login buttons events are handled from the login plugin
    // but we still need to close the modal from here
    'click a' () { app.execute('modal:close') }
  }
})
