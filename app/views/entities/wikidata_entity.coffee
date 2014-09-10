module.exports =  class WikidataEntity extends Backbone.Marionette.LayoutView
  template: require 'views/entities/templates/wikidata_entity'
  regions:
    article: '#article'

  initialize: ->
    @listenTo @model, 'add:pictures', @render

  events:
    'click #addToInventory': 'showItemCreationForm'
    'click #toggleWikiediaPreview': 'toggleWikiediaPreview'

  showItemCreationForm: ->
    app.execute 'show:item:creation:form', {entity: @model}

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
