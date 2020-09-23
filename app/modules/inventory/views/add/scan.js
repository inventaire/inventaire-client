import embedded_ from 'modules/inventory/lib/scanner/embedded'

export default Marionette.ItemView.extend({
  className: 'scan',
  template: require('./templates/scan'),
  initialize () {
    if (window.hasVideoInput) { return embedded_.prepare() }
  },

  serializeData () {
    return {
      hasVideoInput: window.hasVideoInput,
      doesntSupportEnumerateDevices: window.doesntSupportEnumerateDevices
    }
  },

  events: {
    'click #embeddedScanner': 'startEmbeddedScanner'
  },

  startEmbeddedScanner () { return app.execute('show:scanner:embedded') }
})
