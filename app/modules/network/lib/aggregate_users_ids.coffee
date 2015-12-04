module.exports = ->

  cache = {}

  all = (name, categories)->
    categories or= name
    return cache[name] or recalculateAll(name, categories)

  # locking the context for use here-after
  getUserIds = @getUserIds.bind(@)

  recalculateAll = (name, categories)->
    categories = _.forceArray categories
    ids = _.chain(categories).map(getUserIds).flatten().value()
    return cache[name] = ids

  for name, categories of aggregates
    Name = _.capitaliseFirstLetter name
    # ex: @allMembersIds
    @["all#{Name}Ids"] = all.bind @, name, categories

  recalculateAllLists = ->
    for name, categories of aggregates
      recalculateAll name, categories

  @recalculateAllLists = _.debounce recalculateAllLists, 10

aggregates =
  admins: 'admins'
  membersStrict: 'members'
  members: ['admins', 'members']
  invited: 'invited'
  requested: 'requested'
