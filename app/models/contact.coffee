module.exports = class Contact extends Backbone.Model
  matches: (expr) ->
    return true  if expr is null
    hasMatch = _.some @asMatchable(), (field) ->
      field.match(expr) isnt null
    return true  if hasMatch
    false

  asMatchable: ->
    [
      @get("username")
    ]