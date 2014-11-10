module.exports =  class WikidataEntity extends Backbone.Marionette.LayoutView
  template: require 'views/entities/templates/wikidata_entity'
  regions:
    article: '#article'
    personal: '#personal'
    friends: '#friends'
    public: '#public'

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
    @uri = @model.get('uri')
    _.inspect(@)
    @listenTo @model, 'add:pictures', @render
    @fetchPublicItems()

  onShow: ->

  onRender: ->
    @showPersonalItems()
    @showFriendsItems()
    if @public.items? then @showPublicItems()
    else @fetchPublicItems()

  events:
    'click #addToInventory': 'showItemCreationForm'
    'click #toggleWikiediaPreview': 'toggleWikiediaPreview'
    'click #toggleDescLength': 'toggleDescLength'

  showPersonalItems: ->
    # using the filtered collection to refresh on Collection 'add' events
    # uri can be found with filterByText as 'entity' is in item 'matches'
    items = Items.personal.filtered.filterByText @uri
    @showCollectionItems items, 'personal'

  showFriendsItems: ->
    items = Items.friends.filtered.filterByText @uri
    @showCollectionItems items, 'friends'


  showCollectionItems: (items, nameBase)->
    _.log items, "inv: #{nameBase} items"
    if items?
      itemList = new app.View.ItemsList {collection: items}
      # region should be named as nameBase
      @[nameBase].show itemList

  fetchPublicItems: ->
    app.request 'get:entity:public:items', @uri
    .done (itemsData)=>
      items = new app.Collection.Items(itemsData)
      _.inspect(@, '@')
      @public.items = items
      @showPublicItems()
    .fail (err)->

  showPublicItems: ->
    items = @public.items
    @showCollectionItems items, 'public'




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
