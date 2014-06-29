idGenerator = require 'lib/id_generator'

module.exports = Item = Backbone.Model.extend
  schema:
    title: 'Text'
    owner: 'Text'
    comment: 'Text'
    created: 'Date'

  defaults:
    entity:
      uri: null
      title: null
      P31: null
    version:
      uri: null
    instance:
      uri: null
      comment: null
      owner: null
      state: null
      history:
        created: null
        transactions:
          [
            # date:
              #from: uri
              #transaction
                # type: uri
                # price: number
              #to: uri
          ]

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