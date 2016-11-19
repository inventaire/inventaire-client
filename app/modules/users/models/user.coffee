UserCommons = require './user_commons'
map_ = require 'modules/map/lib/map'

module.exports = UserCommons.extend
  isMainUser: false
  initialize: ->
    @setPathname()

    if @hasPosition()
      @listenTo app.user, 'change:position', @calculateDistance.bind(@)
      @calculateDistance()

    # let the time for items to be accessible from their collection
    app.request 'wait:for', 'friends:items'
    .then @calculateHighlightScore.bind(@)

  serializeData: ->
    attrs = @toJSON()
    attrs.cid = @cid
    relationStatus = attrs.status
    # converting the status into a boolean for templates
    attrs[relationStatus] = true
    # nonRelationGroupUser status have the same behavior as public users for views
    if relationStatus is 'nonRelationGroupUser'
      attrs.public = true
    attrs.inventoryLength = @inventoryLength()
    return attrs

  inventoryLength: ->
    if @itemsFetched then app.request 'inventory:user:length', @id

  # caching the calculated distance to avoid recalculating it
  # at every item serializeData
  calculateDistance: ->
    unless app.user.has('position') and @has('position') then return

    a = app.user.get 'position'
    b = @get 'position'
    distance = @kmDistanceFormMainUser = map_.distanceBetween a, b
    # Under 20km, return a ~100m precision to signal the fact that location
    # aren't precise to the meter or anything close to it
    # Above, return a ~1km precision
    precision = if distance > 20 then 0 else 1
    @distanceFromMainUser = Number(distance.toFixed(precision)).toLocaleString()
    return

  calculateHighlightScore: ->
    userItems = app.request 'inventory:user:items', @id
    unless userItems.length > 0 then return 0
    # Highlight users with items lately updated
    itemsAgeFactor = _.sum userItems.map(highlightRescentlyUpdated)
    # Highlight users nearby
    distanceFactor = if @kmDistanceFormMainUser? then 10 / @kmDistanceFormMainUser else 0
    # Well, just highlight anyone actually but don't let that dum per-_id default order.
    # Adapt the multiplicator to let itemsAge and distance factor keep the upper ground
    randomFactor = Math.random() * 0.1
    points = itemsAgeFactor + distanceFactor + randomFactor
    # negating to get the higher scores appear first in collections
    @set 'highlightScore', (- points)

highlightRescentlyUpdated = (item)->
  updateTime = item.get('updated') or item.get('created')
  daysAgo = _.daysAgo updateTime
  # add 1 to avoid dividing by 0
  return 1 / (daysAgo**2 + 1)
