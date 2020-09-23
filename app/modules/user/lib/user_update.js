{ Updater } = require 'lib/model_update'

module.exports = (app)->
  userUpdater = Updater
    endpoint: app.API.user
    uniqueModel: app.user

  app.reqres.setHandlers
    'user:update': userUpdater
