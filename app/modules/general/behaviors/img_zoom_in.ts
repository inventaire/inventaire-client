import app from '#app/app'
import { i18n } from '#user/lib/i18n'

// @ts-expect-error
export default Marionette.Behavior.extend({
  events: {
    'click img': 'zoomIn',
  },

  zoomIn (e) {
    const { src } = e.currentTarget
    const enlargedSrc = src.replace(/\/\d{1,4}x\d{1,4}\//, '/1600x1600/')
    const alt = i18n('loading')
    const img = `<img src='${enlargedSrc}' alt='${alt}...'>`
    app.execute('modal:html', `<div class='flex-row-center-center'>${img}</div>`)
  },
})
