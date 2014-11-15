module.exports = class Search extends Backbone.Marionette.LayoutView
  id: 'searchLayout'
  template: require 'modules/search/layouts/templates/search'
  behaviors:
    AlertBox: {}
  serializeData: ->
    search:
      nameBase: 'search'
      field: {}
      button:
        icon: 'search'
        classes: 'secondary postfix'

  regions: _.duplicator 'results', 5
  ui: _.duplicator 'header', 5

  initialize: (params)->
    @query = params.query
    @listenTo Items.personal.filtered, 'add', @refreshItems
    @listenTo Items.friends.filtered, 'add', @refreshItems

  onShow: ->
    @updateSearchBar()
    app.request 'waitForData', @searchLocalUsers, @
    @searchRemoteUsers()
    app.request 'waitForData', @showItems, @
    @searchEntities()

  # USERS
  searchLocalUsers: ->
    @showCollection app.users.filtered, app.View.Users.List, 'users', 1

  searchRemoteUsers: ->
    app.request('users:search', @query)
    .then ()=>
      _.log 'remote users added to public users'
      # need to fire this method again
      # as the collection might have been empty
      # and thus the view can't be just updated
      @searchLocalUsers()
    .fail _.error

  # ITEMS
  showItems: ->
    View = app.View.ItemsList
    personalItems = [Items.personal.filtered, View, 'in your items', 2 ]
    friendsItems = [Items.friends.filtered, View, "in your friends' items", 3]

    @showCollection.apply @, personalItems
    @showCollection.apply @, friendsItems

  refreshItems: (e, collection)->
    @showItems @query


  # ENTITIES
  searchEntities: ->
    app.request 'search:entities', @query, @results4, @results5, @


  # UTILS
  showCollection: (collection, View, label, rank)->
    collection.filterByText @query
    if collection.length > 0
      view = new View {collection: collection}
      @showResult view, rank
      @addHeader _.i18n(label), rank

  addHeader: (label, rank)->
    el = "header#{rank}"
    @ui[el].html "<h3 class='subheader'>#{label}</h3>"

  showResult: (view, rank)->
    region = "results#{rank}"
    @[region].show view

  on404: -> app.execute 'show:404'
  onDestroy: -> app.execute 'search:field:unmaximize'

  updateSearchBar: ->
    $('#searchField').val @query
    app.execute 'search:field:maximize'