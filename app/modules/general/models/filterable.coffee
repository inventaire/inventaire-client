module.exports = Backbone.NestedModel.extend
  matches: (expr)->
    unless expr? then return true

    hasMatch = _.some @asMatchable(), (field)-> field?.match(expr)?
    if hasMatch then return true
    else return false

  # asMatchable should be defined on sub classes. ex:
  # asMatchable: (expr)-> [ @get('title') ]
