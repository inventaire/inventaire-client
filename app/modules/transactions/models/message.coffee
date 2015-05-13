module.exports = Backbone.Model.extend
  initialize: ->
    app.request 'get:user:model', @get('user')
    .then @grab.bind(@, 'user')

  serializeData: ->
    _.extend @toJSON(),
      user: @user?.serializeData()
