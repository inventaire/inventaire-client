module.exports =  class WikidataEntity extends Backbone.Marionette.LayoutView
  template: require 'views/entities/templates/wikidata_entity'
  regions:
    article: '#article'
  # onShow: -> @showWikipediaExtract(@model.get('wikipedia'))

  events:
    'click #selectEntity': 'addPersonalData'
    'click #toggleWikiediaPreview': 'toggleWikiediaPreview'

  addPersonalData: ->
    app.execute 'show:item:personal:settings:fromEntityModel', @model

  showWikipediaExtract: (wikipediaData)->
    if wikipediaData.extract?
      wd.getExtract(wikipediaData.extract)
      .then (text)=> @brushAndDisplayExtract(text, wikipediaData)
      .fail (err)-> _.log err, 'err getWikipediaExtractFromEntity'
      .done()

  brushAndDisplayExtract: (text, wikipediaData)=>
    header = "<h3 class='subheader'>" +
      "<a href='#{wikipediaData.url}'></a>" +
      _.i18n('Wikipedia article extract') + "</h3>"

    if root = wikipediaData?.root?
      text = text.replace("/wiki", "#{root}/wiki" , 'g')
    else _.log 'no wikipedia root found'

    $("#wikipedia-article").html(header + text)

  toggleWikiediaPreview: ->
    $article = $('#wikipedia-article')
    mobileUrl = @model.get 'wikipedia.mobileUrl'
    if $article.find('iframe').length is 0
      iframe = "<iframe class='wikipedia' src='#{mobileUrl}' frameborder='0'></iframe>"
      $article.html iframe
      $article.slideDown()
    else
      $article.slideToggle()


    $('#toggleWikiediaPreview').find('i').toggleClass('hidden')
