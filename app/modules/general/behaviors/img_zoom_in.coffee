module.exports = Marionette.Behavior.extend
  events:
    'click img': 'zoomIn'

  zoomIn: (e)->
    { src } = e.currentTarget
    enlargedSrc = src.replace /\/\d{1,4}x\d{1,4}\//, '/1600x1600/'
    alt = _.i18n 'loading'
    img = "<img src='#{enlargedSrc}' alt='#{alt}...'>"
    app.execute 'modal:html', "<div class='flex-row-center-center'>#{img}</div>"
