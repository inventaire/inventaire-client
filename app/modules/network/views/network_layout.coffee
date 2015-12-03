Tabs = require './tabs'
{ tabsData, resolveCurrentTab } = require '../lib/network_tabs'

module.exports = Marionette.LayoutView.extend
  template: require './templates/network_layout'
  id: 'networkLayout'

  regions:
    tabs: '.custom-tabs-titles'
    content: '.custom-tabs-content'

  childEvents:
    'tabs:change': 'updateLayout'

  onShow: ->
    { tab } = @options
    @tabs.show new Tabs {tab: tab}
    @showLayout tab

  updateLayout: (view, tab)->
    @showLayout tab

  showLayout: (tab)->
    tab = resolveCurrentTab tab
    { layout } = tabsData.all[tab]
    # Requiring views only when needed.
    # All network layout are assume to be in network/views folder.
    Layout = require "./#{layout}"
    @content.show new Layout @options
