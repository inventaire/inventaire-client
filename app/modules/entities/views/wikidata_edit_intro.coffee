module.exports = Marionette.ItemView.extend
  className: 'wikidata-edit-intro'
  template: require './templates/wikidata_edit_intro'

  onShow: -> app.execute 'modal:open', 'medium'

  serializeData: ->
    attrs = @model.toJSON()
    attrs.isLoggedIn = app.user.loggedIn
    attrs.introData =
      label: attrs.label
      remoteEdit: attrs.wikidata.wiki
    attrs.wikidataOauth = app.API.auth.oauth.wikidata + "&redirect=#{attrs.edit}"
    attrs.wikidataIntro = 'https://www.wikidata.org/wiki/Wikidata:Introduction'
    return attrs

  events:
    'click .loginRequest': 'showLogin'

  showLogin: ->
    # No need to call show:login:redirect as it is called by the General behavior
    # on app_layout(?)
    app.execute 'modal:close'
