module.exports = Notification = Backbone.NestedModel.extend
  initialize: ->  @on 'change:status', @update
  update: ->
    @collection.updateStatus @get('time')