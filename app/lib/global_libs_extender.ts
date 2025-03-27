// @ts-nocheck
import assert_ from '#app/lib/assert_types'
import { serverReportError } from '#app/lib/error'

Marionette.View.prototype.showChildComponent = function (regionName, Component, options = {}) {
  if (!this.isIntact()) return
  const region = this.getRegion(regionName)
  this.emptyRegion(regionName)
  const el = (typeof region.el === 'string') ? document.querySelector(region.el) : region.el
  assert_.object(el)
  options.target = el
  if (options.props) assert_.object(options.props)
  const component = new Component(options)
  region.currentComponent = component
  return component
}

export function removeCurrentComponent (region) {
  if (region.currentComponent) {
    try {
      region.currentComponent.$destroy()
      delete region.currentComponent
    } catch (err) {
      serverReportError(err)
    }
  } else if (region.currentView?._regions) {
    const subregions = Object.values(region.currentView._regions)
    subregions.forEach(removeCurrentComponent)
  }
}

Marionette.View.prototype.emptyRegion = function (regionName) {
  const region = this.getRegion(regionName)
  // Run `removeCurrentComponent` before attempting to destroy region.currentView
  // as doing the opposite would prevent properly calling $destroy on components
  // shown in the currentView regions and subregions
  removeCurrentComponent(region)
  if (region.currentView) region.currentView.destroy()
}

Backbone.View.prototype.isIntact = function () {
  return this.isRendered() && !this.isDestroyed()
}

Backbone.View.prototype.setTimeout = function (fn, timeout) {
  const runUnlessViewIsDestroyed = () => {
    if (!this.isDestroyed()) return fn()
  }
  return setTimeout(runUnlessViewIsDestroyed, timeout)
}
