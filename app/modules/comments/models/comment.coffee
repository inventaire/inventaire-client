module.exports = Backbone.Model.extend
  # not used to get comments so using app.API.comments.authentified
  # (get being on a public endpoint)
  url: -> _.buildPath app.API.comments.authentified, { @id }

  commentOwner: -> app.user.id is @get('user')
  itemOwner: -> app.user.id is @collection.item.get('owner')
  deleteRight: -> @commentOwner() or @itemOwner()

  initialize: ->
    @set
      editRight: @commentOwner()
      deleteRight: @deleteRight()