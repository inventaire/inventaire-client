module.exports =
  auth: require './auth'
  users: require './users'
  items: require './items'
  entities: require './entities'
  services: require './services'
  data: require './data'
  user: '/api/user'
  notifs: '/api/notifs'
  feedbacks: '/api/feedbacks/public'
  i18n: (lang)-> "/public/i18n/dist/#{lang}.json?DIGEST"
  proxy: (url)-> "/api/proxy/public/#{url}"
  test: '/api/test/public'
  testJson: '/api/test/public/json'
  scripts:
    persona: '/public/javascripts/persona-include.js?DIGEST'
    pouchdb: '/public/javascripts/pouchdb-3.3.1.min.js'
