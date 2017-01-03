module.exports = Backbone.Collection.extend
  url: -> app.API.groups.authentified
  model: require '../models/group'
  otherUsersRequestsCount: -> _.sum _.invoke(@models, 'requestsCount')
