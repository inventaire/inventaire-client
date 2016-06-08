endpoint = require './endpoint'

module.exports = (_)->
  auth: require './auth'
  users: require './users'
  groups: require './groups'
  items: require './items'
  entities: require './entities'
  services: require './services'
  data: require './data'
  img: sharedLib('api/img')(_)
  comments: endpoint 'comments'
  transactions: endpoint('transactions').authentified
  relations: endpoint('relations').authentified
  invitations: endpoint('invitations').authentified
  user: endpoint('user').authentified
  notifs: endpoint('notifs').authentified
  feedback: endpoint('feedback').public
  tests: endpoint('tests').public
  i18n: (lang)-> "/public/i18n/dist/#{lang}.json?DIGEST"
  json: (filename)-> "/public/json/#{filename}.json?DIGEST"
  proxy: (url)-> "/api/proxy/public/#{url}"
  scripts: require './scripts'
  upload:
    post: '/api/upload'
    del: '/api/upload/delete'
