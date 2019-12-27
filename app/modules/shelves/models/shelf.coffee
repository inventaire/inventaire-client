error_ = require 'lib/error'

module.exports = Backbone.Model.extend
  initialize: (attrs)->
    @set 'pathname', "/shelves/#{attrs._id}"

  serializeData: -> @.attributes

