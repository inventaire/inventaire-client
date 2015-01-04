ProfileSettings = require './profile_settings'
LabsSettings = require './labs_settings'

module.exports = class EditUser extends Backbone.Marionette.LayoutView
  id: "editUser"
  template: require './templates/edit_user'
  regions:
    editProfile: '#editProfile'
    labs: '#labs'

  onShow: ->
    @editProfile.show new ProfileSettings {model: @model}
    @labs.show new LabsSettings {model: @model}
    setTimeout @pickTab.bind(@), 100

  pickTab: ->
    {tab} = @options
    _.log tab, 'tab'
    if tab is 'labs'
      $('a.labs').trigger('click')