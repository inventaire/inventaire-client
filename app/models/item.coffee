idGenerator = require 'lib/id_generator'

module.exports = Item = Backbone.Model.extend
  defaults:
    title: ""
    comment: ""
    tags: ""
    owner: ""

  initialize: ->

  validate: ->

  matches: (expr) ->
    return true  if expr is null
    hasMatch = _.some(@asMatchable(), (field) ->
      field.match(expr) isnt null
    )
    return true  if hasMatch
    false

  asMatchable: ->
    [
      @get("title")
      @get("comment")
      @get("tags")
      @get("owner")
    ]