AppTemplate = require "views/templates/app"


module.exports = AppView = Backbone.View.extend(
  el: 'body'
  template: AppTemplate
  initialize: ->
  render: ->
    $(@el).html(@template())
    return @
)