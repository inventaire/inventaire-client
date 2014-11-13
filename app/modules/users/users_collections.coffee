module.exports = (app)->
  users =
    public: new app.Collection.Users
    friends: new app.Collection.Users
    userRequests: new app.Collection.Users
    othersRequests: new app.Collection.Users

  users.collections = [
    'public'
    'friends'
    'userRequests'
    'othersRequests'
  ]

  users._mutliCollections = (method, args)->
    Result = null
    @collections.forEach (name)=>
      collection = @[name]
      result = collection[method].apply(collection, args)
      if result? then Result = result
    return Result

  users.byId = (args...)-> users._mutliCollections 'byId', args
  users.findWhere = (args...)-> users._mutliCollections 'findWhere', args

  # include main user in public users to be able
  # to access it from get:username:from:userId
  users.public.add app.user
  users.public.filtered = new FilteredCollection users.public

  return users