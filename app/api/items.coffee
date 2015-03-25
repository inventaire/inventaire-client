module.exports =
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