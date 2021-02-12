import embedded_ from 'modules/inventory/lib/scanner/embedded'
import scanTemplate from './templates/scan_layout.hbs'
import 'modules/inventory/scss/scan_layout.scss'

export default Marionette.ItemView.extend({
  id: 'scanLayout',
  template: scanTemplate,
  initialize () {
    if (window.hasVideoInput) embedded_.prepare()
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

  startEmbeddedScanner () {
    app.execute('show:scanner:embedded')
  }
})
