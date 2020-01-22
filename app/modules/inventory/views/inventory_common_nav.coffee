UserProfile = require './user_profile'
GroupProfile = require './group_profile'
SectionList = require './inventory_section_list'
screen_ = require 'lib/screen'

module.exports = Marionette.LayoutView.extend
  regions:
    usersList: '#usersList'
    groupsList: '#groupsList'

  showList: (region, collection)-> region.show new SectionList { collection }
