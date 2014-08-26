module.exports =  class WikidataEntity extends Backbone.Marionette.LayoutView
  template: require 'views/entities/templates/wikidata_entity'
  regions:
    article: '#article'
  serializeData: ->
    _.log @model, 'model'
    return wd.serializeWikiData(@model)
  onShow: ->
    _.log attrs = @model.toJSON(), "ON SHOW"
    wpInfo = wd.getWikipediaInfo(attrs)
    wd.getWikipediaExtractFromEntity(attrs)
    .then (text)=>

      header = "<h3 class='subheader'>" +
        "<a href='#{wpInfo.url}'></a>" +
        _.i18n('Wikipedia article extract') + "</h3>"

      $("#article").html(header + text)
      # @article.$el.html(text)
      _.log [@article.$el, text], 'article loaded'
    .fail (err)-> _.log err, 'err onShow'
    .done()

