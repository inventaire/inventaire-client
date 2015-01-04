ProfileSettings = require './profile_settings'
LabsSettings = require './labs_settings'

module.exports = class SettingsLayout extends Backbone.Marionette.LayoutView
  id: 'settings'
  template: require './templates/settings'
  regions:
    tabsContent: '.custom-tabs-content'

  ui:
    tabsTitles: '.custom-tabs-titles'
    profileTitle: '#profile'
    labsTitle: '#labs'

  onShow: ->
    {tab} = @options
    switch tab
      when 'profile' then @showProfileSettings()
      when 'labs' then @showLabsSettings()
      else _.error 'unknown tab requested'

  events:
    'click #profile': 'showProfileSettings'
    'click #labs': 'showLabsSettings'

  showProfileSettings: ->
    @tabsContent.show new ProfileSettings {model: @model}
    @setActiveTab 'profile'
    app.navigate 'settings/profile'

  showLabsSettings: ->
    @tabsContent.show new LabsSettings {model: @model}
    @setActiveTab 'labs'
    app.navigate 'settings/labs'

  setActiveTab: (name)->
    tab = "#{name}Title"
    @ui.tabsTitles.find('a').removeClass 'active'
    @ui[tab].addClass 'active'