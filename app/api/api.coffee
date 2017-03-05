endpoint = require './endpoint'

module.exports = (_)->
  auth: require './auth'
  users: require './users'
  groups: require './groups'
  items: require './items'
  entities: require './entities'
  services: require './services'
  data: require './data'
  invitations: require './invitations'
  comments: endpoint('comments', true)
  transactions: endpoint('transactions', true)
  relations: endpoint('relations', true)
  user: endpoint('user', true)
  notifs: endpoint('notifs', true)
  feedback: endpoint('feedback', true)
  tests: endpoint('tests', true)
  cookie: endpoint('cookie', true)
  i18n: endpoint('i18n', true)
  config: endpoint('config', true)
  upload: endpoint('upload', true)
  img: sharedLib('api/img')(_)
  assets: require './assets'
  feeds: require './feeds'
  i18nStrings: (lang)-> "/public/i18n/dist/#{lang}.json?DIGEST"
  json: (filename)-> "/public/json/#{filename}.json?DIGEST"
  proxy: (url)-> "/api/proxy/#{url}"
