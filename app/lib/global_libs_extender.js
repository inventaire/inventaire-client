/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-unused-vars,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import error_ from 'lib/error'

export default function (_) {
  // changing the default attribute to fit CouchDB
  Backbone.Model.prototype.idAttribute = '_id'

  const ArrayHandler = function (handler) {
    let fn
    return fn = function (attr, value) {
      let array = this.get(attr) || []
      _.typeArray(array)
      array = handler(array, value)
      this.set(attr, array)
      return triggerChange(this, attr, value)
    }
  }

  Backbone.Model.prototype.push = ArrayHandler((array, value) => {
    array.push(value)
    return array
  })

  Backbone.Model.prototype.unshift = ArrayHandler((array, value) => {
    array.unshift(value)
    return array
  })

  Backbone.Model.prototype.without = ArrayHandler((array, value) => _.without(array, value))

  // attaching related models to a model in a standard way
  // - requesting it to whatever modules handles it
  // - adding a reference to the model
  // - triggering events

  // Get several attributes at once.
  // Especially useful conbined with destructuring assignment:
  // [ a, b, c ] = model.gets 'a', 'b', 'c'
  Backbone.Model.prototype.gets = function (...attributes) {
    if (_.isArray(attributes[0])) {
      throw new Error('gets expects attributes as different arguments')
    }
    return attributes.map(this.get.bind(this))
  }

  Backbone.Model.prototype.reqGrab = function (request, id, name, refresh) {
    if (!refresh && (this[name] != null)) { return Promise.resolve(this[name]) }

    return app.request(request, id)
    .then(this.grab.bind(this, name))
    .catch(_.ErrorRethrow(`reqGrab ${request} ${id} ${name}`))
  }

  Backbone.Model.prototype.grab = function (name, model) {
    if (model == null) { throw error_.new('grab failed: missing model', arguments) }

    this[name] = model
    this.triggerGrab(name, model)
    return model
  }

  Backbone.Model.prototype.triggerGrab = function (name, model) {
    this.trigger('grab', name, model)
    return this.trigger(`grab:${name}`, model)
  }

  // Wrapping Backbone internal functions to get custom error handling
  // and A-promises instead of jQuery errors and promises
  const WrapModelRequests = function (ClassObj, fnName) {
    const originalFn = ClassObj.prototype[fnName]

    const wrappedFn = function () {
      const result = originalFn.apply(this, arguments)
      // Backbone classes have some inconsistent APIs
      // like Model::delete that can return 'false' instead of a jQuery promise
      if (result.then != null) {
        return _.preq.wrap(result, arguments)
      } else { return Promise.resolve(result) }
    }

    return ClassObj.prototype[fnName] = wrappedFn
  }

  WrapModelRequests(Backbone.Model, 'save')
  WrapModelRequests(Backbone.Model, 'destroy')
  WrapModelRequests(Backbone.Model, 'fetch')
  WrapModelRequests(Backbone.Collection, 'fetch')
  WrapModelRequests(Backbone.Collection, 'destroy')

  Backbone.Collection.prototype.findOne = function () { return this.models[0] }
  // Legacy alias
  Backbone.Collection.prototype.byId = Backbone.Collection.prototype.get
  Backbone.Collection.prototype.byIds = function (ids) { return ids.map(id => this._byId[id]) }
  Backbone.Collection.prototype.attributes = function () { return this.toJSON() }

  FilteredCollection.prototype.filterByText = function (text, reset = true) {
    if (reset) { this.resetFilters() }

    // Not completly raw, we are not barbarians
    const rawText = text.trim()
      // Replace any double space by a simple space
      .replace(/\s{2,}/g, ' ')

    const regexText = rawText
      // Escape regex special characters
      // especially to prevent errors of type "Unterminated group"
      .replace(specialRegexCharactersRegex, '\\$1')

    const filterRegex = new RegExp(regexText, 'i')

    return this.filterBy('text', model => model.matches(filterRegex, rawText))
  }

  // The 'update' event will be added when updating to Backbone >= 1.2.0
  // but meanwhile we got to do without it
  // See https://backbonejs.org/#Changelog
  Backbone.Collection.prototype.triggerUpdateEvents = function () {
    const lazyTriggerUpdate = _.debounce(triggerUpdate.bind(this), 200)
    return this.on('change', lazyTriggerUpdate)
  }

  var triggerUpdate = function (...args) { return this.trigger('update', ...Array.from(args)) }

  // Use in promise chains when the view might be about to be re-rendered
  // and calling would thus trigger error as the method depends on regions
  // being populated (which happens at render), typically in an onRender call.
  Marionette.View.prototype.ifViewIsIntact = function (fn, ...args) {
    return result => {
    // Pass if the view was destroyed or let the onRender hook re-call the function
      if (!this.isRendered) { return }

      args.push(result)
      // Accept a method name in place of a function
      if (_.isString(fn)) { fn = this[fn] }
      return fn.apply(this, args)
    }
  }

  Marionette.View.prototype.setTimeout = function (fn, timeout) {
    const runUnlessViewIsDestroyed = () => { if (!this.isDestroyed) { return fn() } }
    return setTimeout(runUnlessViewIsDestroyed, timeout)
  }

  Marionette.View.prototype.updateClassName = function () {
    // Use in 'onRender' hooks to update the view el classes on re-render
    return this.$el[0].className = this.className()
  }

  // JQUERY
  // aliasing once to one to match Backbone vocabulary
  $.fn.once = $.fn.one

  Marionette.View.prototype.displayError = err => app.execute('show:error:other', err)

  return Marionette.View.prototype.lazyRender = function (focusSelector) {
    if (this.render == null) { throw new Error('lazyRender called without view as context') }

    if (this._lazyRender == null) {
      const delay = this.lazyRenderDelay || 100
      this._lazyRender = LazyRender(this, delay)
    }
    return this._lazyRender(focusSelector)
  }
};

var triggerChange = function (model, attr, value) {
  model.trigger('change', model, attr, value)
  return model.trigger(`change:${attr}`, model, value)
}

const specialRegexCharacters = '()[]$^\\'
  .split('')
  .map(char => '\\' + char)
  .join('')

var specialRegexCharactersRegex = new RegExp(`([${specialRegexCharacters}])`, 'g')

var LazyRender = function (view, timespan = 200) {
  const cautiousRender = function (focusSelector) {
    if (view.isRendered && !(view.isDestroyed || view._preventRerender)) {
      view.render()
      if (_.isString(focusSelector)) { return view.$el.find(focusSelector).focus() }
    }
  }

  return _.debounce(cautiousRender, timespan)
}
