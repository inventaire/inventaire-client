module.exports = (_)->

  sharedLib('global_libs_extender')()

  # WINDOW
  window.location.root = window.location.protocol + '//' + window.location.host

  # BACKBONE.MODEL
  #changing the default attribute to fit CouchDB
  Backbone.Model::idAttribute = '_id'
  Backbone.Model::push = (attr, value)->
    array = @get(attr)
    _.typeArray(array)
    array.push value
    @set attr, array

  Backbone.Model::without = (attr, value)->
    array = @get(attr)
    _.typeArray(array)
    array = _.without array, value
    @set attr, array

  # BACKBONE.COLLECTION
  Backbone.Collection::findOne = -> @models[0]
  Backbone.Collection::byId = (id)-> @_byId[id]
  Backbone.Collection::byIds = (ids)-> ids.map (id)=> @byId(id)
  Backbone.Collection::attributes = -> @toJSON()

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
  # aliasing once to one to match Backbone vocabulary
  $.fn.once = $.fn.one
  # only implementing the promise interface
  # i.e. no success callbacks
  $.postJSON = (url, data)-> ajax 'POST', url, 'json', data
  $.putJSON = (url, data)-> ajax 'PUT', url, 'json', data
  $.delete = (url)-> ajax 'DELETE', url
  $.getXML = (url)-> ajax 'GET', url, 'xml'

  ajax = (verb, url, dataType, data)->
    $.ajax
      url: url
      type: verb
      data: data
      dataType: dataType
