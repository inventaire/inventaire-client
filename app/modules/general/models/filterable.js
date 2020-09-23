module.exports = Backbone.NestedModel.extend
  matches: (filterRegex, rawInput)->
    unless filterRegex? then return true
    return _.some @matchable(), @fieldMatch(filterRegex, rawInput)

  # Can be overriden to match fields in a custom way
  fieldMatch: (filterRegex, rawInput)-> (field)-> field?.match(filterRegex)?

  # matchable should be defined on sub classes. ex:
  # matchable: -> [ @get('title') ]
