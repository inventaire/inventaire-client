# Request configuration to the server and make it accessible at app.config
module.exports = ->
  _.preq.get app.API.config
  .then (config)-> app.config = config
