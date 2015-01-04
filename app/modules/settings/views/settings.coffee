ProfileSettings = require './profile_settings'
LabsSettings = require './labs_settings'

module.exports = class SettingsLayout extends Backbone.Marionette.LayoutView
  id: 'settings'
  template: require './templates/settings'
  regions:
    profile: '#profile'
    labs: '#labs'

  onShow: ->
    @profile.show new ProfileSettings {model: @model}
    @labs.show new LabsSettings {model: @model}
    setTimeout @pickTab.bind(@), 100

  pickTab: ->
    {tab} = @options
    _.log tab, 'tab'
    if tab is 'labs'
      $('a.labs').trigger('click')