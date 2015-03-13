module.exports =
  auth:
    login: '/api/auth/public/login'
    logout: '/api/auth/public/logout'
    username: '/api/auth/public/username'
  user: '/api/user'
  users:
    data: (ids)->
      ids = _.forceArray(ids)
      if _.all ids, _.isUserId
        ids = ids.join '|'
        return "/api/users?action=getusers&ids=#{ids}"
      else throw new Error "users data API needs an array of valid user ids"
    items: (ids)->
      ids = _.forceArray(ids)
      if ids?
        ids = ids.join '|'
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
      data = _.forceArray(data).join '|'
      _.buildPath "/api/entities/public",
        action: 'getimages'
        data: data
    isbns: (isbns)->
      isbns = _.forceArray(isbns).join '|'
      _.buildPath '/api/entities/public',
        action: 'getisbnentities'
        isbns: isbns
    inv:
      create: '/api/entities'
      get: (ids)->
        ids = _.forceArray(ids).join '|'
        _.buildPath '/api/entities', { ids: ids }
    followed: '/api/entities/followed'
  notifs: '/api/notifs'
  i18n: (lang)-> "/public/i18n/dist/#{lang}.json?DIGEST"
  data: (api, q, pid, qid)-> _.log "/api/data/public?api=#{api}&q=#{q}&pid=#{pid}&qid=#{qid}", 'data url'
  proxy: (url)-> "/api/proxy/public/#{url}"
  test: '/api/test/public'
  testJson: '/api/test/public/json'
