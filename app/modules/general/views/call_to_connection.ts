import app from '#app/app'
import { images } from '#lib/urls'
import callToConnectionTemplate from './templates/call_to_connection.hbs'
import '../scss/call_to_connect.scss'

const { banner } = images

export default Marionette.View.extend({
  template: callToConnectionTemplate,
  onRender () { app.execute('modal:open') },
  serializeData () {
    return Object.assign(this.options, { banner })
  },

  events: {
    // login buttons events are handled from the login plugin
    // but we still need to close the modal from here
    'click a' () { app.execute('modal:close') },
  },
})
