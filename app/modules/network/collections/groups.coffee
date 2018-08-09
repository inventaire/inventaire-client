module.exports = Backbone.Collection.extend
  url: -> app.API.groups.base
  parse: (res)-> res.groups
  model: require '../models/group'
  otherUsersRequestsCount: -> _.sum _.invoke(@models, 'requestsCount')
  comparator: 'highlightScore'
