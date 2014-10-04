module.exports =
  auth:
    login: '/api/auth/login'
    logout: '/api/auth/logout'
    user: '/api/auth/user'
    username: '/api/auth/username'
  users:
    data: (ids)->
      if ids?
        ids = ids.join?('|') or ids
        return "/api/users?action=getusers&ids=#{ids}"
      else throw new Error "users data API needs an array of ids"
  contacts:
    contacts: '/api/contacts'
    items: (id)->
      if id? then "/api/#{id}/items"
      else throw new Error "contacts' items API needs an id"
    search: (text)->
      if text? then "/api/users?action=search&search=#{text}"
      else throw new Error "contacts' search API needs a text argument"
  items:
    items: '/api/items'
    public: (uri, username)->
      if uri? and username? then "/api/items/public/#{username}/#{uri}"
      else if uri? then "/api/items/public/#{uri}"
      else '/api/items/public'
    item: (owner, id, rev)->
      if owner? and id?
        if rev? then "/api/#{owner}/items/#{id}/#{rev}"
        else "/api/#{owner}/items/#{id}"
      else throw new Error "item API needs an owner, an id, and possibly a rev"
  entities:
    search: (search)->
      _.buildPath "/api/entities/search",
        search: search
        language: app.user.lang