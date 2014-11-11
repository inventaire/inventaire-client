module.exports = ->

  sharedLib('global_libs_extender')()

  # WINDOW
  window.location.root = window.location.protocol + '//' + window.location.host

  # BACKBONE.MODEL
  #changing the default attribute to fit CouchDB
  Backbone.Model::idAttribute = '_id'

  # BACKBONE.COLLECTION
  Backbone.Collection::findOne = -> @models[0]
  Backbone.Collection::byId = (id)-> @_byId[id]
  Backbone.Collection::byIds = (ids)-> ids.map (id)=> @byId(id)

  # FILTERED COLLECTION
  FilteredCollection::filterByText = (text, reset=true)->
    @resetFilters()  if reset?
    filterExpr = new RegExp text, 'i'
    @filterBy 'text', (model)->
      if model.matches? then model.matches filterExpr
      else _.error model, 'model has no matches method'

  # MARIONETTE
  Marionette.Region::Show = (view, options)->
    if _.isString options then title = options
    else if options?.docTitle? then title = options.docTitle

    if title?
      app.docTitle _.softDecodeURI(title)

    return @show(view, options)

  # JQUERY
  $.postJSON = (url, body, callback)->
    if callback?
      return $.post(url, body, callback, 'json')
    else
      return $.post(url, body, 'json')

  $.getXML = (url)->
    return $.ajax
      type: 'GET',
      url: url,
      dataType: 'xml',