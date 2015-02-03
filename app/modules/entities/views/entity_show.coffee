EntityActions = require './entity_actions'

module.exports = class EntityShow extends Backbone.Marionette.LayoutView
  className: 'entityShow custom-column'
  template: require './templates/entity_show'
  regions:
    actions: '#actions'
    article: '#article'
    personal: '#personal'
    friends: '#friends'
    public: '#public'

  behaviors:
    WikiBar: {}

  serializeData: ->
    attrs = @model.toJSON()
    if attrs.description?
      attrs.descMaxlength = 500
      attrs.descOverflow = attrs.description.length > attrs.descMaxlength

    if _.lastRouteMatch(/search\?/)
      attrs.back =
        message: _.i18n 'back to search results'

    return attrs

  initialize: ->
    @uri = @model.get('uri')
    @listenTo @model, 'add:pictures', @render
    @fetchPublicItems()

  onRender: ->
    app.request('qLabel:update')
    @showEntityActions()
    if app.user.loggedIn
      @showPersonalItems()
      @showFriendsItems()
    if @public.items? then @showPublicItems()
    else @fetchPublicItems()

  events:
    'click #toggleWikiediaPreview': 'toggleWikiediaPreview'
    'click #toggleDescLength': 'toggleDescLength'
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'

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
      itemList = new app.View.Items.List {collection: items}
      # region should be named as nameBase
      @[nameBase].show itemList

  fetchPublicItems: ->
    app.request 'get:entity:public:items', @uri
    .then (data)=>
      app.users.public.add data.users
      @public.items = new app.Collection.Items data.items
    .fail (err)=>
      if err.status is 404
        # always to show the NoItem view
        @public.items = new Backbone.Collection
      else _.logXhrErr(err)
    .always =>
      @showPublicItems()

  showPublicItems: ->
    items = @public.items
    @showCollectionItems items, 'public'
    _.log items, 'items'

  showEntityActions: ->
    @actions.show new EntityActions {model: @model}

  toggleDescLength: ->
    $('#shortDesc').toggle()
    $('#fullDesc').toggle()
    $('#toggleDescLength').find('i').toggleClass('hidden')

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @