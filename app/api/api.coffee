module.exports =
  auth: require './auth'
  users: require './users'
  items: require './items'
  entities: require './entities'
  services: require './services'
  data: require './data'
  comments:
    public: '/api/comments/public'
    private: '/api/comments'
  transactions: '/api/transactions'
  relations: '/api/relations'
  invitations: '/api/invitations'
  groups: '/api/groups'
  user: '/api/user'
  notifs: '/api/notifs'
  feedback: '/api/feedback/public'
  i18n: (lang)-> "/public/i18n/dist/#{lang}.json?DIGEST"
  moment: (lang)-> "/public/javascripts/moment/#{lang}.js?DIGEST"
  proxy: (url)-> "/api/proxy/public/#{url}"
  newsletter: '/api/newsletter/public'
  test: '/api/tests/public'
  scripts:
    persona: '/public/javascripts/persona-include.js?DIGEST'
    pouchdb: '/public/javascripts/pouchdb-3.3.1.min.js'
  upload:
    post: '/api/upload'
    del: '/api/upload/delete'
  img: (path, width, height)->
    if /^http/.test path
      key = _.hashCode path
      href = encodeURIComponent path
      "/img/#{width}x#{height}/#{key}?href=#{href}"
    else
      "/img/#{width}x#{height}/#{path}"
