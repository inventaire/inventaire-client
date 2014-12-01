module.exports = class UserProfile extends Backbone.Marionette.ItemView
  template: require './templates/user_profile'
  events:
    'click a.close': 'unselectUser'

  unselectUser: ->
    @$el.hide()
    app.execute 'show:inventory:general'