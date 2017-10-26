BrowserSelector = require './browser_selector'
BrowserSelectorOptions = require './browser_selector_options'
SelectorsCollection = require '../collections/selectors'

module.exports = BrowserSelector.extend
  className: 'browser-selector browser-owner-selector'
  template: require './templates/browser_owners_selector'
  initialize: ->
    BrowserSelector::initialize.call @
    { @collections, @ownersWorksItemsMap } = @options
    # Required by inventory_browser filterSelect
    @selectorName = 'owner'

  regions:
    highlighted: '.highlighted'
    friends: '.friends'
    groups: '.groups'
    nearby: '.nearby'

  ui: _.extend {}, BrowserSelector::ui,
    friendsToggler: '#friends-toggler'
    groupsToggler: '#groups-toggler'
    nearbyToggler: '#nearby-toggler'

  # Take the collections on @options as the 'attributes' function that depends on it
  # will need it before 'initialize' runs
  count: -> _.sum(_.pluck(_.values(@options.collections), 'length'))

  onShow: ->
    @showHighlighted()
    @showFriends()
    @showGroups()
    # @showNearby()

  showHighlighted: -> @showSection 'highlighted', @collections.highlighted
  showFriends: -> @showSection 'friends', @collections.friends
  showGroups: -> @showSection 'groups', @collections.groups
  # showNearby: -> @showSection 'nearby', @collections.nearby

  showSection: (regionName, collection)->
    @[regionName].show new BrowserSelectorOptions { collection }

  events: _.extend {}, BrowserSelector::events,
    'click .toggler': 'toggleSection'

  toggleSection: (e)->
    name = e.currentTarget.id.split('-')[0]
    @ui["#{name}Toggler"].toggleClass 'toggled'
    @[name].$el.slideToggle 200
    e.stopPropagation()

  collectionsAction: (fnName, args...)->
    for name, collection of @collections
      collection[fnName](args...)

  # Include togglers to make them selectable
  arrowNavigationSelector: '.browser-selector-li, .toggler'

  treeKeyAttribute: '_id'

  getIntersectionCount: (key, worksUris, intersectionWorkUris)->
    modelIntersection = _.intersection worksUris, intersectionWorkUris
    if modelIntersection.length is 0 then return 0
    ownerWorksItemsMap = @ownersWorksItemsMap[key]
    intersectionWorksItems = _.pick ownerWorksItemsMap, modelIntersection
    # Uniq is needed as a single item might appear in several works,
    # if it is linked to a composite edition, as this one is linked to several works
    return _.uniq(_.flatten(_.values(intersectionWorksItems))).length
