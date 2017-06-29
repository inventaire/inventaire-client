Tabs = require './tabs'
{ tabsData, resolveCurrentTab, level1Tabs } = require '../lib/network_tabs'
# keep in sync with app/modules/network/scss/_network_layout.scss
verticalTabCeil = 700

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
    @tabs.show new Tabs { tab }
    @showLayout tab

  updateLayout: (view, tab, originalTab)->
    @showLayout tab
    if _.smallScreen verticalTabCeil
      # avoid to scroll to the content top when a level-1 tab is clicked
      # so that the level-2 tabs stay visible
      if originalTab in level1Tabs then _.scrollTop @tabs.$el
      else _.scrollTop @content.$el

  showLayout: (tab)->
    tab = resolveCurrentTab tab
    { layout } = tabsData.all[tab]
    # Requiring views only when needed.
    # All network layout are assume to be in network/views folder.
    Layout = require "./#{layout}"
    @content.show new Layout @options
