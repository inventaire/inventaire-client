module.exports = Backbone.Model.extend
  initialize: ->
    @reqGrab 'get:user:model', @get('user'), 'user'

  serializeData: ->
    _.extend @toJSON(),
      user: @user?.serializeData()
