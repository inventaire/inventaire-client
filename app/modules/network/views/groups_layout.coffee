GroupsList = require './groups_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/groups_layout'
  id: 'groupsLayout'
  tagName: 'section'

  regions:
    groupList: '#groupsList'

  behaviors:
    Loading: {}

  onShow: ->
    behaviorsPlugin.startLoading.call @, '#groupsList'
    @showGroupsLists()

  showGroupsLists: ->
    @groupList.show new GroupsList
      collection: app.groups
      mode: 'board'
