behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/labs_settings'
  className: 'labsSettings'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  events:
    'click a#jsonInventoryExport': 'jsonInventoryExport'
    'click a#pouchdbButton': 'pouchdbInventoryExport'

  ui:
    url: '#pouchdbField'

  initialize: -> _.extend @, behaviorsPlugin

  serializeData: ->
    pouchdb: @pouchDbData()

  pouchDbData: ->
    nameBase: 'pouchdb'
    field:
      placeholder: _.i18n 'enter the url of your CouchDB database'
      type: 'url'
    button:
      text: _.i18n 'replicate'
      classes: 'dark-grey postfix'

  jsonInventoryExport: ->
    userInventory = app.items.personal.toJSON()
    username = app.user.get 'username'
    date = new Date().toLocaleDateString()
    name = "inventaire.io-#{username}-#{date}.json"
    _.openJsonWindow(userInventory, name)

  pouchdbInventoryExport: ->
    url = @validUrl()
    if url?
      @validCouchDB(url)
      .then @triggerReplication.bind(@)

  triggerReplication: ->
    _.log 'couchdb ok'
    @startLoading('#pouchdbButton')

    @importPouchDbScript()
    .then @replicateInventory.bind(@)

  importPouchDbScript: ->
    _.log 'Importing PouchDB'
    _.preq.getScript app.API.scripts.pouchdb
    .catch _.Error('failed to import PouchDB')

  replicateInventory: ->
    _.log 'Start replication process'
    if window.PouchDB?
      _.log 'Found PouchDB'
      url = @validUrl()
      if url?
        invDb = new PouchDB 'inv'
        putItems(invDb)
        .then @replicateDb.bind(@, invDb, url)
        .then -> cleaningDb(invDb)

  validUrl: ->
    url = @ui.url.val()
    unless _.isUrl url then @alert 'invalid url'
    else return url

  validCouchDB: (url)->
    root = getRoot(url)
    if root?
      $.getJSON(root)
      .then (res)=>
        if res.couchdb? then return 'ok'
        else @alert "the server doesn't answer as a CouchDB. You might need to enable CORS on your CouchDB"
      .fail (err)=>
        _.error err, err.statusText
        @alert "the server doesn't answer as expected."
    else
      @alert "it doesn't seem to be valid CouchDB url"

  replicateDb: (db, url)->
    _.log 'Replicate to PouchDB!'
    db.replicate.to url
    .then @Check('replicateDb success')
    .catch @Fail('replicateDb success')
    .finally @stopLoading.bind(@)

putItems = (db)->
  docs = app.items.personal.toJSON()
  _.log docs, 'transfer items to PouchDB'
  db.bulkDocs docs


cleaningDb = (db)->
  db.destroy()
  .then _.Log('cleaning DB')
  .catch _.Error('cleaning DB err')

getRoot = (url)->
  # getting http://127.0.0.1:5984
  # from http://127.0.0.1:5984/inventory-backup
  root = url?.split('/')[0...-1].join '/'
  if _.isUrl(root) then return root
  # will triggers an alert at validCouchDB
  else return