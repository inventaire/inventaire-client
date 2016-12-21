module.exports = Backbone.NestedModel.extend
  initialize: (attrs)->
    @reqGrab 'get:user:model', attrs.user, 'user'

    dbVersionNumber = parseInt @id.split(':')[1]
    # The first version is an empty document with only the basic attributes:
    # doesn't really count as a version
    @set 'versionNumber', dbVersionNumber-1

    @setOperationsData()

  setOperationsData: ->
    patch = @get 'patch'
    for op in patch
      if op.path.startsWith '/claims/'
        op.property = op.path
          .replace /^\/claims\//, ''
          .replace /\/\d+$/, ''

  serializeData: ->
    attrs = @toJSON()
    # The user might not have been grabed when serializeData is called
    attrs.user = @user?.serializeData()
    return attrs
