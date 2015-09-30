module.exports = (_)->
  auth: require './auth'
  users: require './users'
  items: require './items'
  entities: require './entities'
  services: require './services'
  data: require './data'
  img: sharedLib('api/img')(_)
  comments:
    public: '/api/comments/public'
    private: '/api/comments'
  transactions: '/api/transactions'
  relations: '/api/relations'
  invitations: '/api/invitations'
  groups:
    private: '/api/groups'
    public: '/api/groups/public'
  user: '/api/user'
  notifs: '/api/notifs'
  feedback: '/api/feedback/public'
  i18n: (lang)-> "/public/i18n/dist/#{lang}.json?DIGESTh"
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
