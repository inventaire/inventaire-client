module.exports = Backbone.Model.extend
  url: app.API.groups
  initialize: ->
    { _id, name } = @toJSON()
    @set 'pathname', "/groups/#{_id}/#{name}"

    @fetchMembers()

  fetchMembers: ->
    @users = new Backbone.Collection
    @allMembers().forEach @fetchUser.bind(@)

  fetchUser: (userId)->
    app.request 'get:user:model', userId
    .then @users.add.bind(@users)
    .catch _.Error('fetchMembers')

  allMembers: ->
    @get('members').concat @get('admin')

  membersCount: ->
    @allMembers().length

  serializeData: ->
    _.extend @toJSON(),
      membersCount: @membersCount()
