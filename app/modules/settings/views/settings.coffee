views =
  profile: require './profile_settings'
  account: require './account_settings'
  notifications: require './notifications_settings'
  data: require './data_settings'

module.exports = Marionette.LayoutView.extend
  id: 'settings'
  template: require './templates/settings'
  regions:
    tabsContent: '.custom-tabs-content'

  ui:
    tabsTitles: '.custom-tabs-titles'
    profileTitle: '#profile'
    accountTitle: '#account'
    notificationsTitle: '#notifications'
    dataTitle: '#data'

  onShow: ->
    app.request 'wait:for', 'user'
    .then @showTab.bind(@, @options.tab)

  events:
    'click #profile': 'showProfileSettings'
    'click #account': 'showAccountSettings'
    'click #notifications': 'showNotificationsSettings'
    'click #data': 'showDataSettings'

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
  showAccountSettings: -> @showTab 'account'
  showNotificationsSettings: -> @showTab 'notifications'
  showDataSettings: -> @showTab 'data'
