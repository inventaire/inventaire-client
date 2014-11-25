module.exports = class Notification extends Backbone.NestedModel
  initialize: ->  @on 'change:status', @update
  update: ->
    @collection.updateStatus @get('time')