UserProfile = require 'modules/inventory/views/user_profile'
GroupProfile = require 'modules/network/views/group_profile'
List = require 'modules/inventory/views/inventory_network_nav_list'

module.exports = Marionette.LayoutView.extend
  regions:
    usersList: '#usersList'
    groupsList: '#groupsList'
    profile: '#profile'

  childEvents:
    select: (e, type, model)->
      @showProfile type, model
      @triggerMethod 'select', type, model

  showList: (region, collection)-> region.show new List { collection }

  showProfile: (type, model)->
    if type is 'user' then @profile.show new UserProfile { model }
    if type is 'group' then @profile.show new GroupProfile { model, highlighted: true }

  initProfile: ->
    { user, group } = @options
    if user? then @showProfile 'user', user
    else if group? then @showProfile 'group', group
