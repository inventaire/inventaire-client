module.exports = Marionette.ItemView.extend
  className: 'wikidata-edit-intro'
  template: require './templates/wikidata_edit_intro'
  onShow: -> app.execute 'modal:open'

  serializeData: ->
    attrs = @model.toJSON()
    attrs.introData =
      label: attrs.label
      remoteEdit: attrs.wikidata.wiki
    attrs.wikidataOauth = app.API.auth.oauth.wikidata + "&redirect=#{attrs.edit}"
    attrs.wikidataIntro = 'https://www.wikidata.org/wiki/Wikidata:Introduction'
    return attrs
