import url from 'lib/urls'
const { banner } = url.images

export default Marionette.ItemView.extend({
  template: require('./templates/call_to_connection.hbs'),
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
