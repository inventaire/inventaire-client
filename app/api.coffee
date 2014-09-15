proxy = (route)-> '/proxy/' + route

module.exports =
  auth:
    login: '/api/auth/login'
    logout: '/api/auth/logout'
    user: '/api/auth/user'
    username: '/api/auth/username'
  contacts:
    contacts: '/api/contacts'
    items: (id)->
      if id? then "/api/#{id}/items"
      else throw new Error "contacts' items API needs an id"
    search: (text)->
      if text? then "/api/users?#{text}"
      else throw new Error "contacts' search API needs a text argument"
  items:
    items: '/api/items'
    public: (uri)-> "/api/items/public/#{uri}"
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

    claim: proxy 'http://wdq.wmflabs.org/api'
  wikidata:
    uri: (id)-> "http://www.wikidata.org/entity/#{id}"
    get: proxy 'https://www.wikidata.org/w/api.php'
  google:
    book: (data)->
      "https://www.googleapis.com/books/v1/volumes/?q=#{data}"
  images:
    lucky: (text)-> proxy "http://pixplorer.co.uk/getimage/#{text}"