UserProfile = require 'modules/inventory/views/user_profile'
GroupProfile = require 'modules/network/views/group_profile'
List = require 'modules/inventory/views/inventory_network_nav_list'
screen_ = require 'lib/screen'

module.exports = Marionette.LayoutView.extend
  regions:
    usersList: '#usersList'
    groupsList: '#groupsList'

  showList: (region, collection)-> region.show new List { collection }
