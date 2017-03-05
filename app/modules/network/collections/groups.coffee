module.exports = Backbone.Collection.extend
  url: -> app.API.groups.base
  model: require '../models/group'
  otherUsersRequestsCount: -> _.sum _.invoke(@models, 'requestsCount')
  comparator: 'highlightScore'
