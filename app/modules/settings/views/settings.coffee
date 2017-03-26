views =
  profile: require './profile_settings'
  notifications: require './notifications_settings'
  labs: require './labs_settings'

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
    app.request 'wait:for', 'user'
    .then @showTab.bind(@, @options.tab)

  events:
    'click #profile': 'showProfileSettings'
    'click #notifications': 'showNotificationsSettings'
    'click #labs': 'showLabsSettings'

  showTab: (tab)->
    View = views[tab]
    @tabsContent.show new View { @model }
    @tabUpdate tab

  tabUpdate: (tab)->
    @setActiveTab tab

    tabLabel = _.I18n tab
    settings = _.I18n 'settings'

    app.navigate "settings/#{tab}",
      metadata: { title: "#{tabLabel} - #{settings}" }

  setActiveTab: (name)->
    tab = "#{name}Title"
    @ui.tabsTitles.find('a').removeClass 'active'
    @ui[tab].addClass 'active'

  showProfileSettings: -> @showTab 'profile'
  showNotificationsSettings: -> @showTab 'notifications'
  showLabsSettings: -> @showTab 'labs'
