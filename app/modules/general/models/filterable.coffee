module.exports = class Filterable extends Backbone.NestedModel
  asMatchable: (expr) -> [] #to override
  matches: (expr) ->
    if expr?
      hasMatch = _.some @asMatchable(), (field) ->
        field?.match(expr)?
      if hasMatch then return true
      else return false
    else return true