module.exports = Backbone.Model.extend
  url: -> _.buildPath app.API.comments, { @id }

  commentOwner: -> app.user.id is @get('user')
  itemOwner: -> app.user.id is @collection.item.get('owner')
  deleteRight: -> @commentOwner() or @itemOwner()

  initialize: ->
    @set
      editRight: @commentOwner()
      deleteRight: @deleteRight()