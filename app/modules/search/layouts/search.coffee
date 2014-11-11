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

  regions: _.duplicator 'results', 6
  ui: _.duplicator 'header', 6

  initialize: (params)->
    @query = params.query
    @listenTo Items.personal.filtered, 'add', @refreshItems
    @listenTo Items.friends.filtered, 'add', @refreshItems

  onShow: ->
    @updateSearchBar()
    app.request 'waitForData', @searchFriends, @
    @searchOthers()
    app.request 'waitForData', @showItems, @
    @searchEntities()

  # USERS
  searchFriends: ->
    friends = app.users.friends.filtered
    @showCollection friends, app.View.Users.List, 'friends', 1

  searchOthers: ->
    app.request('users:search', @query)
    .then (users)=>
      _.log users, 'searchOthers users'
      @showCollection users, app.View.Users.List, 'users', 2
    .fail _.error

  # ITEMS
  showItems: ->
    View = app.View.ItemsList
    personalItems = [Items.personal.filtered, View, 'in your items', 3 ]
    friendsItems = [Items.friends.filtered, View, "in your friends' items", 4]

    @showCollection.apply @, personalItems
    @showCollection.apply @, friendsItems

  refreshItems: (e, collection)->
    @showItems @query


  # ENTITIES
  searchEntities: ->
    app.request 'search:entities', @query, @results5, @results6, @


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
  # resetResults: (numbers = [1..4])->
  #   numbers.forEach (num)=>
  #     @["results#{num}"]?.empty?()
  #     @["header#{num}"]?.empty?()

  updateSearchBar: ->
    $('#searchField').val @query
    app.execute 'search:field:maximize'