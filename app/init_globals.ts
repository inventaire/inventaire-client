import Backbone from 'backbone'
import Marionette from 'backbone.marionette'
import $ from 'jquery'
import AppRouter from 'marionette.approuter'
import _ from 'underscore'
// Sets Backbone.NestedModel
import 'backbone-nested'

window._ = _
window.jQuery = window.$ = $
window.Backbone = Backbone
window.Marionette = Marionette
Marionette.AppRouter = AppRouter
