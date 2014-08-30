module.exports =  class WikidataEntity extends Backbone.Marionette.LayoutView
  template: require 'views/entities/templates/wikidata_entity'
  regions:
    article: '#article'
  serializeData: ->
    _.log @model, 'model'
    return wd.serializeWikiData(@model)
  onShow: -> @showWikipediaExtract()

  events:
    'click #selectEntity': 'addPersonalData'

  addPersonalData: ->
    app.execute 'show:item:personal:settings:fromEntityModel', @model

  showWikipediaExtract: ->
    attrs = @model.toJSON()
    wpInfo = wd.getWikipediaInfo(attrs)
    wd.getWikipediaExtractFromEntity(attrs)
    .then (text)=> @brushAndDisplayExtract(text,wpInfo)
    .fail (err)-> _.log err, 'err getWikipediaExtractFromEntity'
    .done()

  brushAndDisplayExtract: (text, wpInfo)=>
    header = "<h3 class='subheader'>" +
      "<a href='#{wpInfo.url}'></a>" +
      _.i18n('Wikipedia article extract') + "</h3>"

    if wpInfo?.baseUrl?
      text = text.replace("/wiki", "#{wpInfo.baseUrl}/wiki" , 'g')
    else _.log 'no wpInfo.baseUrl'
    $("#article").html(header + text)