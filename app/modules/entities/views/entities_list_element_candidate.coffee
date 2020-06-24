forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'entities-list-element-candidate'
  template: require './templates/entities_list_element_candidate'

  initialize: ->
    { parentModel, @listCollection } = @options
    { @childrenClaimProperty } = parentModel
    @parentUri = parentModel.get('uri')
    currentPropertyClaims = @model.get("claims.#{@childrenClaimProperty}")
    @alreadyAdded = @isAlreadyAdded()

  behaviors:
    AlertBox: {}

  serializeData: ->
    attrs = @model.toJSON()
    { type } = attrs
    if type? then attrs[type] = true
    attrs.description ?= _.i18n type
    _.extend attrs,
      alreadyAdded: @alreadyAdded

  events:
    'click .add': 'add'

  add: ->
    @listCollection.add @model
    @model.setPropertyValue @childrenClaimProperty, null, @parentUri
    .then =>
      @updateStatus()
      app.execute 'invalidate:entities:graph', @parentUri
    .catch forms_.catchAlert.bind(null, @)

  updateStatus: ->
    if @isAlreadyAdded()
      # Use classes instead of a re-render to prevent blinking {{claim}} labels
      @$el.find('.add').addClass 'hidden'
      @$el.find('.added').removeClass 'hidden'
    else
      # Use classes instead of a re-render to prevent blinking {{claim}} labels
      @$el.find('.add').removeClass 'hidden'
      @$el.find('.added').addClass 'hidden'

  isAlreadyAdded: ->
    currentPropertyClaims = @model.get "claims.#{@childrenClaimProperty}"
    @alreadyAdded = currentPropertyClaims? and @parentUri in currentPropertyClaims
    return @alreadyAdded
