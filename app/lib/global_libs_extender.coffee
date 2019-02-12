error_ = require 'lib/error'
require('jquery-visible')

module.exports = (_)->
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

  Backbone.Model::reqGrab = (request, id, name, refresh)->
    if not refresh and @[name]? then return Promise.resolve @[name]

    app.request request, id
    .then @grab.bind(@, name)
    .catch _.ErrorRethrow("reqGrab #{request} #{id} #{name}")

  Backbone.Model::grab = (name, model)->
    unless model? then throw error_.new 'grab failed: missing model', arguments

    @[name] = model
    @triggerGrab name, model
    return model

  Backbone.Model::triggerGrab = (name, model)->
    @trigger 'grab', name, model
    @trigger "grab:#{name}", model

  # Wrapping Backbone internal functions to get custom error handling
  # and A-promises instead of jQuery errors and promises
  WrapModelRequests = (ClassObj, fnName)->
    originalFn = ClassObj.prototype[fnName]

    wrappedFn = ->
      result = originalFn.apply @, arguments
      # Backbone classes have some inconsistent APIs
      # like Model::delete that can return 'false' instead of a jQuery promise
      if result.then? then _.preq.wrap result, arguments
      else _.preq.resolve result

    ClassObj.prototype[fnName] = wrappedFn

  WrapModelRequests Backbone.Model, 'save'
  WrapModelRequests Backbone.Model, 'destroy'
  WrapModelRequests Backbone.Model, 'fetch'
  WrapModelRequests Backbone.Collection, 'fetch'
  WrapModelRequests Backbone.Collection, 'destroy'

  Backbone.Collection::findOne = -> @models[0]
  # Legacy alias
  Backbone.Collection::byId = Backbone.Collection::get
  Backbone.Collection::byIds = (ids)-> ids.map (id)=> @_byId[id]
  Backbone.Collection::attributes = -> @toJSON()

  FilteredCollection::filterByText = (text, reset = true)->
    if reset then @resetFilters()

    # Not completly raw, we are not barbarians
    rawText = text.trim()
      # Replace any double space by a simple space
      .replace /\s{2,}/g, ' '

    regexText = rawText
      # Escape regex special characters
      # especially to prevent errors of type "Unterminated group"
      .replace specialRegexCharactersRegex, '\\$1'

    filterRegex = new RegExp regexText, 'i'

    @filterBy 'text', (model)-> model.matches filterRegex, rawText

  # Use in promise chains when the view might be about to be re-rendered
  # and calling would thus trigger error as the method depends on regions
  # being populated (which happens at render), typically in an onRender call.
  Marionette.View::ifViewIsIntact = (fn, args...)-> (result)=>
    # Pass if the view was destroyed or let the onRender hook re-call the function
    unless @isRendered then return

    args.push result
    # Accept a method name in place of a function
    if _.isString fn then fn = @[fn]
    return fn.apply @, args

  Marionette.View::setTimeout = (fn, timeout)->
    runUnlessViewIsDestroyed = => unless @isDestroyed then fn()
    setTimeout runUnlessViewIsDestroyed, timeout

  # Give focus to a view top element, so that hitting Tab focuses
  # the first focusable element in the view
  # To be called from a view onShow function
  Marionette.View::focusOnShow = ->
    # Make sure the view can be focused
    @$el[0].tabIndex = 0
    @$el.focus()

  Marionette.View::updateClassName = ->
    # Use in 'onRender' hooks to update the view el classes on re-render
    @$el[0].className = @className()

  # JQUERY
  # aliasing once to one to match Backbone vocabulary
  $.fn.once = $.fn.one

  Marionette.View::displayError = (err)-> app.execute 'show:error:other', err

triggerChange = (model, attr, value)->
  model.trigger 'change', model, attr, value
  model.trigger "change:#{attr}", model, value

specialRegexCharacters = '()[]$^\\'
  .split ''
  .map (char)-> '\\' + char
  .join ''

specialRegexCharactersRegex = new RegExp "([#{specialRegexCharacters}])", 'g'
