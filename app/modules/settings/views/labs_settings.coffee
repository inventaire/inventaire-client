module.exports = class LabsSettings extends Backbone.Marionette.ItemView
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

  jsonInventoryExport: ->
    userInventory = Items.personal.toJSON()
    username = app.user.get 'username'
    date = new Date().toLocaleDateString()
    name = "inventaire.io-#{username}-#{date}.json"
    _.openJsonWindow(userInventory, name)

  pouchdbInventoryExport: ->
    url = @validUrl()
    if url?
      @validCouchDB(url)
      .then ()=>
        _.log 'couchdb ok'
        @$el.trigger 'loading',
          selector: '#pouchdbButton'
        @importPouchDbScript()
        .then @replicateInventory.bind(@)

  serializeData: ->
    attrs =
      pouchdb:
        nameBase: 'pouchdb'
        field:
          placeholder: _.i18n 'enter the url of your CouchDB database'
          type: 'url'
        button:
          text: _.i18n 'replicate'

  importPouchDbScript: ->
    _.log 'Importing PouchDB'
    $.getScript 'https://github.com/daleharvey/pouchdb/releases/download/3.2.0/pouchdb-3.2.0.min.js'
    .fail (err)-> _.error err, 'failed to import PouchDB'

  replicateInventory: ->
    _.log 'Start replication process'
    if window.PouchDB?
      _.log 'Found PouchDB'
      url = @validUrl()
      if url?
        inv = new PouchDB 'inv'
        putItems(inv)
        .then @replicateDb.bind @, inv, url
        .then -> cleaningDb(db)

  validUrl: ->
    url = @ui.url.val()
    unless _.isUrl url then @invalidUrl 'invalid url'
    else return url

  validCouchDB: (url)->
    root = getRoot(url)
    if root?
      $.getJSON(root)
      .then (res)=>
        if res.couchdb? then return 'ok'
        else @invalidUrl "the server doesn't answer as a CouchDB. You might need to enable CORS on your CouchDB"
      .fail (err)=>
        console.warn err
        @invalidUrl "the server doesn't answer as expected."
    else
      @invalidUrl "it doesn't seem to be valid CouchDB url"
      return

  invalidUrl: (errMessage)->
    console.warn errMessage, 'invalidUrl'
    @$el.trigger 'alert', {message: _.i18n(errMessage)}
    return

  replicateDb: (db, url)->
    _.log 'Replicate to PouchDB!'
    db.replicate.to url
    .then (data)=>
      console.log 'replicateDb sucess', data
      @$el.trigger 'stopLoading'
      @$el.trigger 'check'
    .catch (data)=>
      console.warn 'replicateDb failure', data
      @$el.trigger 'stopLoading'
      @$el.trigger 'fail'

putItems = (db)->
  docs = Items.personal.toJSON()
  _.log docs, 'transfer items to PouchDB'
  db.bulkDocs docs


cleaningDb = (db)->
  db.destroy()
  .then (res)-> _.log res, 'cleaning DB'
  .catch (err)-> _.log err, 'cleaning DB err'

getRoot = (url)->
  # getting http://127.0.0.1:5984
  # from http://127.0.0.1:5984/inventory-backup
  root = url.split('/')[0...-1].join '/'
  if _.isUrl(root) then return root
  else return