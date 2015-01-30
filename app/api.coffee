module.exports =
  auth:
    login: '/api/auth/public/login'
    logout: '/api/auth/logout'
    username: '/api/auth/public/username'
  user: '/api/user'
  users:
    data: (ids)->
      if ids?
        ids = ids.join?('|') or ids
        return "/api/users?action=getusers&ids=#{ids}"
      else throw new Error "users data API needs an array of ids"
    items: (ids)->
      if ids?
        ids = ids.join?('|') or ids
        return "/api/users?action=getitems&ids=#{ids}"
      else throw new Error "users' items API needs an id"
    search: (text)->
      if text? then "/api/users?action=search&search=#{text}"
      else throw new Error "users' search API needs a text argument"
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
      _.buildPath "/api/entities/public",
        action: 'search'
        search: search
        language: app.user.lang
    getImages: (data)->
      _.buildPath "/api/entities/public",
        action: 'getimages'
        data: data.join?('|') or data
    isbns: (isbns)->
      _.buildPath '/api/entities/public',
        action: 'getisbnentities'
        isbns: isbns.join?('|') or isbns
    inv:
      create: '/api/entities'
      get: (ids)-> _.buildPath '/api/entities',
        ids: ids.join?('|') or ids
  notifs: '/api/notifs'
  i18n: (lang)-> "/public/i18n/dist/#{lang}.json?DIGEST"
  proxy: (url)-> "/api/proxy/#{url}"
  test: '/api/test'
  testJson: '/api/test/json'
