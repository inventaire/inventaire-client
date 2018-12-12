Tabs = require './tabs'
screen_ = require 'lib/screen'
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

  initialize: ->
    @waitForRelations = app.request 'wait:for', 'relations'

  onShow: ->
    { tab } = @options
    # wait for relations so that 'get:network:counters' doesn't crash
    # if app.relations isn't defined yet
    @waitForRelations
    .then @ifViewIsIntact('showTabs', tab)

    @showLayout tab

  updateLayout: (view, tab, originalTab)->
    @showLayout tab
    if screen_.isSmall verticalTabCeil
      # avoid to scroll to the content top when a level-1 tab is clicked
      # so that the level-2 tabs stay visible
      if originalTab in level1Tabs then screen_.scrollTop @tabs.$el
      else screen_.scrollTop @content.$el

  showTabs: (tab)-> @tabs.show new Tabs { tab }

  showLayout: (tab)->
    tab = resolveCurrentTab tab
    { layout } = tabsData.all[tab]
    # Requiring views only when needed.
    # All network layout are assume to be in network/views folder.
    Layout = require "./#{layout}"
    @content.show new Layout @options
