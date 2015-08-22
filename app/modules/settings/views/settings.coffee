ProfileSettings = require './profile_settings'
NotificationsSettings = require './notifications_settings'
LabsSettings = require './labs_settings'

module.exports = Marionette.LayoutView.extend
  id: 'settings'
  template: require './templates/settings'
  regions:
    tabsContent: '.custom-tabs-content'

  ui:
    tabsTitles: '.custom-tabs-titles'
    profileTitle: '#profile'
    notificationsTitle: '#notifications'
    labsTitle: '#labs'

  onShow: ->
    {tab} = @options
    switch tab
      when 'profile' then fn = @showProfileSettings
      when 'notifications' then fn = @showNotificationsSettings
      when 'labs' then fn = @showLabsSettings
      else _.error 'unknown tab requested'

    app.request('waitForUserData').then fn.bind(@)

  events:
    'click #profile': 'showProfileSettings'
    'click #notifications': 'showNotificationsSettings'
    'click #labs': 'showLabsSettings'

  showProfileSettings: ->
    @tabsContent.show new ProfileSettings {model: @model}
    @tabUpdate 'profile'

  showNotificationsSettings: ->
    @tabsContent.show new NotificationsSettings {model: @model}
    @tabUpdate 'notifications'

  showLabsSettings: ->
    @tabsContent.show new LabsSettings {model: @model}
    @tabUpdate 'labs'

  tabUpdate: (tab)->
    @setActiveTab tab
    updateDocTitle tab
    app.navigate "settings/#{tab}"

  setActiveTab: (name)->
    tab = "#{name}Title"
    @ui.tabsTitles.find('a').removeClass 'active'
    @ui[tab].addClass 'active'

updateDocTitle = (tab)->
  tab = _.I18n tab
  settings = _.I18n 'settings'
  app.vent.trigger 'document:title:change', "#{tab} - #{settings}"
