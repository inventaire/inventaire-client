module.exports = ->
  { groups } = app.user

  getGroupModel = (id)->
    group = groups.byId id
    if group then _.preq.resolve group
    else getGroupPublicData id

  app.reqres.setHandlers
    'get:group:model': getGroupModel
    'get:group:model:sync': groups.byId.bind(groups)

  initGroupFilteredCollection groups, 'mainUserMember'
  initGroupFilteredCollection groups, 'mainUserInvited'


initGroupFilteredCollection = (groups, name)->
  filtered = groups[name] = new FilteredCollection groups
  filtered.filterBy name, filters[name]
  filtered.listenTo app.vent, 'group:main:user:move', filtered.refilter.bind(filtered)

filters =
  mainUserMember: (group)-> group.mainUserIsMember()
  mainUserInvited: (group)-> group.mainUserIsInvited()


getGroupPublicData = (id)->
  _.preq.get _.buildPath(app.API.groups, {id: id})
  .then _.Log('getGroupPublicData')
  .then (res)->
    {group, users, items} = res
    app.users.public.add users
    Items.public.add items
    return app.user.groups.add group
