module.exports = Marionette.ItemView.extend
  template: require './templates/tabs'
  className: 'tabs'

  ui:
    tabs: '.tab'
    friendsTab: '#friendsTab'
    groupsTab: '#groupsTab'

  onShow: ->
    { tab } = @options
    @ui.tabs.removeClass 'active'
    @ui["#{tab}Tab"].addClass 'active'
