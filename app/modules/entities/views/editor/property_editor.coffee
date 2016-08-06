isLoggedIn = require './lib/is_logged_in'

module.exports = Marionette.CompositeView.extend
  className: ->
    singleValue = if not @model.get('multivalue') then 'single-value' else ''
    return "property-editor #{singleValue}"
  template: require './templates/property_editor'
  getChildView: ->
    switch datatype
      when 'entity' then require './value_editor'
      when 'string' then require './string_value_editor'
      else throw new Error "unknown datatype: #{datatype}"

  childViewContainer: '.values'
  initialize: ->
    @collection = @model.values

  serializeData: ->
    attrs = @model.toJSON()
    attrs.canAddValues = @canAddValues()
    return attrs

  canAddValues: -> @model.get('multivalue') or @collection.length is 0

  events:
    'click .addValue': 'addValue'

  addValue: (e)->
    if isLoggedIn() then @collection.addEmptyValue()
    # Prevent parent views including the same 'click .addValue': 'addValue'
    # event listener to be triggered
    e.stopPropagation()
