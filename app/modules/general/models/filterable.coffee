module.exports = Backbone.NestedModel.extend
  matches: (expr)->
    unless expr? then return true
    matches = (field)-> field?.match(expr)?

    return _.some @matchable(), matches

  # matchable should be defined on sub classes. ex:
  # matchable: -> [ @get('title') ]
