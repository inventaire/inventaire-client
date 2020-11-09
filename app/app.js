import { isNonEmptyString } from 'lib/boolean_tests'
import BindedPartialBuilder from 'lib/binded_partial_builder'
import { updateRouteMetadata } from 'lib/metadata/update'
import error_ from 'lib/error'
import { routeSection, currentRoute } from 'lib/location'
import behaviors from 'modules/general/behaviors/base'

let initialUrlNavigateAlreadyCalled = false

const App = Marionette.Application.extend({
  initialize () {
    Backbone.history.last = []
    behaviors.initialize()
    this.Execute = BindedPartialBuilder(this, 'execute')
    this.Request = BindedPartialBuilder(this, 'request')
    this.vent.Trigger = BindedPartialBuilder(this.vent, 'trigger')
    this.once('start', onceStart)

    const navigateFromModel = function (model, pathAttribute = 'pathname', options = {}) {
      // Polymorphism
      if (_.isObject(pathAttribute)) {
        options = pathAttribute
        pathAttribute = 'pathname'
      }

      options.metadata = model.updateMetadata()
      const route = model.get(pathAttribute)
      if (isNonEmptyString(route)) {
        return this.navigate(route, options)
      } else {
        return error_.report(`navigation model has no ${pathAttribute} attribute`, model)
      }
    }

    // Make it a binded function so that it can be reused elsewhere without
    // having to bind it again
    this.navigateFromModel = navigateFromModel.bind(this)
  },

  navigate (route, options = {}) {
    // Close the modal if it was open
    // If the next view just opened the modal, this will be ignored
    app.execute('modal:close')
    // Update metadata before testing if the route changed
    // so that a call from a router action would trigger a metadata update
    // but not affect the history (due to the early return hereafter)
    updateRouteMetadata(route, options.metadata)
    // Easing code mutualization by firing app.navigate, even when the module
    // simply reacted to the requested URL
    if (route === currentRoute()) {
      // Trigger a route event for the first URL, so that views listening
      // on the route:change event can update accordingly
      if (!initialUrlNavigateAlreadyCalled) {
        this.vent.trigger('route:change', routeSection(route), route)
        initialUrlNavigateAlreadyCalled = true
      }
      return
    }

    // a starting slash would be corrected by the Backbone.Router
    // but routeSection relies on the route not starting by a slash.
    // it can't just thrown an error as pathnames commonly require to start
    // by a slash to avoid being interpreted as relative pathnames
    route = route.replace(/^\//, '')

    this.vent.trigger('route:change', routeSection(route), route)
    route = this.request('querystring:keep', route)
    Backbone.history.last.unshift(route)
    Backbone.history.navigate(route, options)
    if (!options.preventScrollTop) { return scrollToPageTop() }
  },

  navigateReplace (route, options) {
    if (!options) { options = {} }
    options.replace = true
    return this.navigate(route, options)
  }
})

const onceStart = function () {
  // For some reason, the handlers aren't set until app.start is called
  if (Backbone.history.handlers.length > 0) {
    console.log('handlers found', Backbone.history.handlers.length)
    Backbone.history.start({ pushState: true })

    // Backbone.history 'route' event seem to be only triggerd
    // when 'previous' is hit. it isn't very clear why,
    // but it allows to notify functionalities depending on the route
    Backbone.history.on('route', onPreviousRoute)
  } else {
    console.log('waiting for handlers to be set...')
    setTimeout(onceStart, 100)
  }
}

const onPreviousRoute = function () {
  // Close the modal if it was open
  // If a modal is actually displayed in the previous route, it should
  // be reopen by the view being reshown
  app.execute('modal:close')

  const route = currentRoute()
  return app.vent.trigger('route:change', routeSection(route), route)
}

const app = window.app = new App()

export default app

const scrollToPageTop = () => window.scrollTo(0, 0)
