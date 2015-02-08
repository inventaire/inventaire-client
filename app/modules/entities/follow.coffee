Follow = require('./models/follow')
followedList = new Follow
FollowedEntities = require './collections/followed_entities'

module.exports = (app)->

  followedEntities = new FollowedEntities [], {list: followedList}

  app.commands.setHandlers
    'entity:follow': (uri)-> followedList.set uri, true
    'entity:unfollow': (uri)-> followedList.set uri, false

  app.reqres.setHandlers
    'entity:followed:state': (uri)-> followedList.get uri
    'entities:followed:list': -> followedList
    'entities:followed:collection': -> followedEntities

  return followedEntities