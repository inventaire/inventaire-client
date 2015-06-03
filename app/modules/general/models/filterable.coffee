module.exports = Backbone.NestedModel.extend
  asMatchable: (expr) -> [] #to override
  matches: (expr) ->
    if expr?
      hasMatch = _.some @asMatchable(), (field) ->
        field?.match(expr)?
      if hasMatch then return true
      else return false
    else return true
