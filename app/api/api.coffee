endpoint = require './endpoint'

module.exports = (_)->
  auth: require './auth'
  users: require './users'
  groups: require './groups'
  items: require './items'
  entities: require './entities'
  search: require './search'
  data: require './data'
  invitations: require './invitations'
  tasks: require './tasks'
  transactions: endpoint('transactions', true)
  relations: endpoint('relations', true)
  user: endpoint('user', true)
  notifications: endpoint('notifications', true)
  feedback: endpoint('feedback', true)
  tests: endpoint('tests', true)
  i18n: endpoint('i18n', true)
  config: endpoint('config', true)
  # /api/images: API controllers handling images uploading, resizing, etc
  images: require './images'
  # /img: endpoint serving images, handled by Nginx in production
  # thus not behing the /api root
  img: require './img'
  assets: require './assets'
  feeds: require './feeds'
  i18nStrings: (lang)-> "/public/i18n/#{lang}.json?DIGEST1550160841171"
  json: (filename)-> "/public/json/#{filename}.json?DIGEST1550160841171"
