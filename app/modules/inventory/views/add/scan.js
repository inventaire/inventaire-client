import embedded_ from 'modules/inventory/lib/scanner/embedded'
import scanTemplate from './templates/scan.hbs'

export default Marionette.ItemView.extend({
  className: 'scan',
  template: scanTemplate,
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

  startEmbeddedScanner () { app.execute('show:scanner:embedded') }
})
