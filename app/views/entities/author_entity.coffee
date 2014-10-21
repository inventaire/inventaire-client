module.exports =  class AuthorEntity extends Backbone.Marionette.LayoutView
  template: require 'views/entities/templates/wikidata_entity'
  regions:
    article: '#article'
    items: '#items'

  serializeData: ->
    attrs = @model.toJSON()
    if attrs.description?
      attrs.descMaxlength = 500
      attrs.descOverflow = attrs.description.length > attrs.descMaxlength

    if _.lastRouteMatch(/search\?/)
      attrs.back =
        message: _.i18n 'Back to search results'

    return attrs

  initialize: ->
    _.inspect(@)
    @listenTo @model, 'add:pictures', @render
    @fetchPublicItems()

  onRender: -> @showPublicItems()

  events:
    'click #addToInventory': 'showItemCreationForm'
    'click #toggleWikiediaPreview': 'toggleWikiediaPreview'
    'click #toggleDescLength': 'toggleDescLength'

  fetchPublicItems: ->
    app.request 'get:entity:public:items', @model.get('uri')
    .done (itemsData)=>
      items = new app.Collection.Items(itemsData)
      @items.viewCollection = items
      @showPublicItems()

  showPublicItems: ->
    items = @items.viewCollection
    _.log items, 'inv: public items'
    if items?.length > 0
      itemList = new app.View.ItemsList {collection: items}
    else
      itemList = new app.View.ItemsList
    @items.show itemList

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

  toggleDescLength: ->
    $('#shortDesc').toggle()
    $('#fullDesc').toggle()
    $('#toggleDescLength').find('i').toggleClass('hidden')
