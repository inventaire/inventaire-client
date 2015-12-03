privat = '/api/groups'
publik = '/api/groups/public'

module.exports =
  private: privat
  public: publik
  search: (text)->
    _.type text, 'string'
    _.buildPath publik,
      action: 'search'
      search: text
  last: "#{publik}?action=last"
