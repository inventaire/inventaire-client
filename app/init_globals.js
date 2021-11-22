import $ from 'jquery'
import _ from 'underscore'
import Backbone from 'backbone'
import Marionette from 'backbone.marionette/lib/backbone.marionette.esm'
import AppRouter from 'marionette.approuter/lib/marionette.approuter.esm'
// Sets Backbone.NestedModel
import 'backbone-nested'

window._ = _
window.jQuery = window.$ = $
window.Backbone = Backbone
window.Marionette = Marionette
Marionette.AppRouter = AppRouter
