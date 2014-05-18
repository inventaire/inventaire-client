module.exports = Backbone.Model.extend(
  defaults:
    firstName: ""
    lastName: ""
    email: ""
    phone: ""

  validate: (attributes) ->
    "first name must be provided."  if attributes.firstName.length is 0

  fullName: ->
    [
      @get("firstName")
      @get("lastName")
    ].join " "

  matches: (expr) ->
    return true  if expr is null
    hasMatch = _.some(@asMatchable(), (field) ->
      field.match(expr) isnt null
    )
    return true  if hasMatch
    false

  asMatchable: ->
    matchable = [
      @get("firstName")
      @get("lastName")
      @get("email")
      @get("phone")
    ]
    matchable
)
