proxy = (route)-> '/proxy/' + route

module.exports =
  auth:
    login: '/api/auth/login'
    logout: '/api/auth/logout'
    user: '/api/auth/user'
    username: '/api/auth/username'
  contacts:
    contacts: 'api/contacts'
    items: (id)->
      if id?
        return "/api/#{id}/items"
      else throw new Error "contacts' items API needs an id"
    search: (text)->
      if text?
        return "/api/users?#{text}"
      else throw new Error "contacts' search API needs a text argument"
  items:
    items: '/api/items'
    item: (owner, id, rev)->
      if owner? and id?
        if rev?
          return "/api/#{owner}/items/#{id}/#{rev}"
        else
          return "/api/#{owner}/items/#{id}"
      else throw new Error "item API needs an owner, an id, and possibly a rev"
  entities:
    get: proxy('https://www.wikidata.org/w/api.php')
    search: '/api/entities/search'
    claim: proxy('http://wdq.wmflabs.org/api')
