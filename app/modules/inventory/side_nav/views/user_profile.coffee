module.exports = class UserProfile extends Backbone.Marionette.ItemView
  template: require './templates/user_profile'
  events:
    'click a.close': 'unselectUser'

  onShow: ->
    @makeRoom()
    @updateBreadCrumb()

    # take care of destroying this view even on events out of this
    # view scope (ex: clicking the home button)
    @listenTo app.vent, 'inventory:change', @destroyOnInventoryChange

  unselectUser: ->
    app.execute 'show:inventory:general'

  destroyOnInventoryChange: (username)->
    unless username is @model.get('username')
      @$el.slideUp 500, @destroy.bind(@)

  onDestroy: ->
    @giveRoomBack()
    @notifyBreadCrumb()

  makeRoom: -> $('#one').addClass 'notEmpty'
  giveRoomBack: -> $('#one').removeClass 'notEmpty'

  updateBreadCrumb: ->
    app.execute 'current:username:set', @model.get('username')
  notifyBreadCrumb: ->
    app.execute 'current:username:hide'
