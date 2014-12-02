module.exports = class UserProfile extends Backbone.Marionette.ItemView
  template: require './templates/user_profile'
  events:
    'click a.close': 'unselectUser'

  unselectUser: ->
    @destroy()
    app.execute 'show:inventory:general'

  onShow: ->
    app.execute 'current:username:set', @model.get('username')

  onDestroy: ->
    app.execute 'current:username:hide'
