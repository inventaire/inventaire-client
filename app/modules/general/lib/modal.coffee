module.exports = ->
  app.commands.setHandlers
    'modal:size:large': -> $('#modal').addClass 'large'
    'modal:size:normal': -> $('#modal').removeClass 'large'