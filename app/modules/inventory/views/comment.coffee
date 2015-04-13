module.exports = Marionette.ItemView.extend
  template: require './templates/comment'
  className: 'comment'
  serializeData: ->
    attrs = @model.toJSON()
    attrs.user = app.request('get:userModel:from:userId', attrs.user)?.toJSON()
    return attrs