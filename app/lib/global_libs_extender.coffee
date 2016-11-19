error_ = require 'lib/error'

module.exports = (_)->
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

  # Get several attributes at once.
  # Especially useful conbined with destructuring assignment:
  # [ a, b, c ] = model.gets 'a', 'b', 'c'
  Backbone.Model::gets = (attributes...)->
    if _.isArray attributes[0]
      throw new Error 'gets expects attributes as different arguments'
    return attributes.map @get.bind(@)

  Backbone.Model::reqGrab = (request, id, name)->
    app.request(request, id)
    .then @grab.bind(@, name)
    .catch _.Error("reqGrab #{request} #{id} #{name}")

  Backbone.Model::grab = (name, model)->
    unless model?
      throw error_.new('grab failed: missing model', arguments)

    @[name] = model
    @triggerGrab name, model
    return model

  Backbone.Model::triggerGrab = (name, model)->
    @trigger 'grab', name, model
    @trigger "grab:#{name}", model

  Backbone.Collection::findOne = -> @models[0]
  Backbone.Collection::byId = (id)-> @_byId[id]
  Backbone.Collection::byIds = (ids)-> ids.map (id)=> @_byId[id]
  Backbone.Collection::attributes = -> @toJSON()

  FilteredCollection::filterByText = (text, reset=true)->
    if reset then @resetFilters()
    text = text.trim().replace /\s{2,}/g, ' '
    filterExpr = new RegExp text, 'i'
    @filterBy 'text', (model)-> model.matches filterExpr

  Marionette.Region::Show = (view, options={})->
    if _.isString options then docTitle = options
    else { docTitle, noCompletion } = options

    if docTitle?
      app.docTitle _.softDecodeURI(docTitle), noCompletion

    return @show(view, options)

  # JQUERY
  # aliasing once to one to match Backbone vocabulary
  $.fn.once = $.fn.one

triggerChange = (model, attr, value)->
  model.trigger 'change', model, attr, value
  model.trigger "change:#{attr}", model, value
