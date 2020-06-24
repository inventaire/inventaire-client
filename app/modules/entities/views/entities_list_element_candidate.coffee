module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'entities-list-element-candidate'
  template: require './templates/entities_list_element_candidate'

  initialize: ->
    { parentModel, @listCollection } = @options
    { @childrenClaimProperty } = parentModel
    @parentUri = parentModel.get('uri')
    currentPropertyClaims = @model.get("claims.#{@childrenClaimProperty}")
    @alreadyAdded = currentPropertyClaims? and @parentUri in currentPropertyClaims

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
    @updateStatus()
    @model.setPropertyValue @childrenClaimProperty, null, @parentUri
    .then => app.execute 'invalidate:entities:graph', @parentUri

  updateStatus: ->
    # Use classes instead of a re-render to prevent blinking {{claim}} labels
    @$el.find('.add').addClass 'hidden'
    @$el.find('.added').removeClass 'hidden'
