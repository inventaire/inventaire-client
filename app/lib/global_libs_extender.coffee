module.exports = (_)->

  sharedLib('global_libs_extender')()

  window.location.root = window.location.protocol + '//' + window.location.host

  #changing the default attribute to fit CouchDB
  Backbone.Model::idAttribute = '_id'

  ArrayHandler = (handler)->
    return fn = (attr, value)->
      array = @get(attr) or []
      _.typeArray array
      array = handler array, value
      @set attr, array
      triggerChange @, attr, value

  Backbone.Model::push = ArrayHandler (array, value)->
    array.push value
    return array

  Backbone.Model::unshift = ArrayHandler (array, value)->
    array.unshift value
    return array

  Backbone.Model::without = ArrayHandler (array, value)->
    return _.without array, value

  # attaching related models to a model in a standard way
  # - requesting it to whatever modules handles it
  # - adding a reference to the model
  # - triggering events

  # get several attributes at once
  Backbone.Model::gets = (attributes...)->
    attributes.map (attribute)=> @get attribute

  Backbone.Model::reqGrab = (request, id, name)->
    app.request(request, id)
    .then @grab.bind(@, name)
    .catch _.Error("reqGrab #{request} #{id} #{name}")

  Backbone.Model::grab = (name, model)->
    @[name] = model
    @triggerGrab name, model

  Backbone.Model::triggerGrab = (name, model)->
    @trigger 'grab', name, model
    @trigger "grab:#{name}", model

  Backbone.Collection::findOne = -> @models[0]
  Backbone.Collection::byId = (id)-> @_byId[id]
  Backbone.Collection::byIds = (ids)-> ids.map (id)=> @byId(id)
  Backbone.Collection::attributes = -> @toJSON()

  FilteredCollection::filterByText = (text, reset=true)->
    @resetFilters()  if reset
    filterExpr = new RegExp text, 'i'
    @filterBy 'text', (model)->
      if model.matches? then model.matches filterExpr
      else _.error model, 'model has no matches method'

  Marionette.Region::Show = (view, options={})->
    if _.isString options then docTitle = options
    else { docTitle, noCompletion } = options

    if docTitle?
      app.docTitle _.softDecodeURI(docTitle), noCompletion

    return @show(view, options)

  # JQUERY
  # aliasing once to one to match Backbone vocabulary
  $.fn.once = $.fn.one
  # only implementing the promise interface
  # i.e. no success callbacks
  $.postJSON = (url, data)-> ajax 'POST', url, 'json', data
  $.put = (url, data)->
    $.ajax
      url: url
      data: data
      type: 'PUT'
  $.putJSON = (url, data)-> ajax 'PUT', url, 'json', data
  $.delete = (url)-> ajax 'DELETE', url
  $.getXML = (url)-> ajax 'GET', url, 'xml'

  ajax = (verb, url, dataType, data)->
    $.ajax
      url: url
      type: verb
      data: data
      dataType: dataType


triggerChange = (model, attr, value)->
  model.trigger 'change', model, attr, value
  model.trigger "change:#{attr}", model, value
