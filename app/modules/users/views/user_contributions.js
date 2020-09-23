# A layout to display a list of the user data contributions

Patches = require 'modules/entities/collections/patches'

module.exports = Marionette.CompositeView.extend
  className: 'userContributions'
  template: require './templates/user_contributions'
  childViewContainer: '.contributions'
  childView: require './user_contribution'
  initialize: ->
    { @user } = @options
    @userId = @user.get '_id'

    @collection = new Patches
    @limit = 50
    @offset = 0

    @fetchMore()

  ui:
    fetchMore: '.fetchMore'
    totalContributions: '.totalContributions'
    remaining: '.remaining'

  serializeData: ->
    user: @user.serializeData()

  fetchMore: ->
    _.preq.get app.API.entities.contributions(@userId, @limit, @offset)
    .then @parseResponse.bind(@)

  parseResponse: (res)->
    { patches, continue:@offset, total } = res

    if total isnt @total
      @total = total
      # Update manually instead of re-rendering as it would require to re-render
      # all the sub viewstotal
      @ui.totalContributions.text total

    if @offset? then @ui.remaining.text(total - @offset)
    else @ui.fetchMore.hide()

    @collection.add patches

  events:
    'click .fetchMore': 'fetchMore'
