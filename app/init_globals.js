// This module is an insult to modern dependency management:
// we use local copies of our dependencies to be able to customize their import methods
// to control their sub dependencies. Objectives:
// - Make sure that all dependencies use the same Backbone object,
//   so that `model instanceof Backbone.Model` remains true

import $ from 'jquery'
import _ from 'underscore'
import Backbone from 'vendor/backbone'
import NestedModel from 'vendor/backbone-nested'
import Marionette from 'vendor/backbone.marionette'
import FilteredCollection from 'vendor/backbone-filtered-collection'

window.$ = $
window._ = _
window.jQuery = window.$ = $
window.Backbone = Backbone
window.Marionette = Marionette
window.Backbone.NestedModel = NestedModel
window.Backbone.Marionette = Marionette
window.FilteredCollection = FilteredCollection
