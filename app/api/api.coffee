module.exports =
  auth: require './auth'
  users: require './users'
  items: require './items'
  entities: require './entities'
  services: require './services'
  data: require './data'
  requests: '/api/requests'
  user: '/api/user'
  notifs: '/api/notifs'
  feedbacks: '/api/feedbacks/public'
  i18n: (lang)-> "/public/i18n/dist/#{lang}.json?DIGEST"
  proxy: (url)-> "/api/proxy/public/#{url}"
  newsletter: '/api/newsletter/public'
  test: '/api/tests/public'
  scripts:
    persona: '/public/javascripts/persona-include.js?DIGEST'
    pouchdb: '/public/javascripts/pouchdb-3.3.1.min.js'
