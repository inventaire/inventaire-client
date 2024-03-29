import app from '#app/app'
import { getDevicesInfo } from '#lib/has_video_input.ts'
import scanTemplate from './templates/scan_layout.hbs'
import '#inventory/scss/scan_layout.scss'

export default Marionette.View.extend({
  id: 'scanLayout',
  template: scanTemplate,

  serializeData () {
    return getDevicesInfo()
  },

  events: {
    'click #embeddedScanner': 'startEmbeddedScanner',
  },

  startEmbeddedScanner () {
    app.execute('show:scanner:embedded')
  },
})
