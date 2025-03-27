import Backbone from 'backbone'
import Marionette from 'backbone.marionette'
import $ from 'jquery'
import AppRouter from 'marionette.approuter'
import _ from 'underscore'

globalThis._ = _
// @ts-expect-error TS2339
globalThis.jQuery = globalThis.$ = $
globalThis.Backbone = Backbone
globalThis.Marionette = Marionette
Marionette.AppRouter = AppRouter
