Follow = require('./models/follow')
followed = new Follow

follow = (uri)-> followed.set uri, true
unfollow = (uri)-> followed.set uri, false
followedState = (uri)-> followed.get uri


module.exports = (app)->
  app.commands.setHandlers
    'entity:follow': follow
    'entity:unfollow': unfollow

  app.reqres.setHandlers
    'entity:followed:state': followedState

  return followed