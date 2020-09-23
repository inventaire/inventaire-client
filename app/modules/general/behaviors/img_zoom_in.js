export default Marionette.Behavior.extend({
  events: {
    'click img': 'zoomIn'
  },

  zoomIn (e) {
    const { src } = e.currentTarget
    const enlargedSrc = src.replace(/\/\d{1,4}x\d{1,4}\//, '/1600x1600/')
    const alt = _.i18n('loading')
    const img = `<img src='${enlargedSrc}' alt='${alt}...'>`
    return app.execute('modal:html', `<div class='flex-row-center-center'>${img}</div>`)
  }
})
