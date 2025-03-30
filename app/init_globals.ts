import Backbone from 'backbone'
import Marionette from 'backbone.marionette'
import AppRouter from 'marionette.approuter'
import _ from 'underscore'

globalThis._ = _
globalThis.Backbone = Backbone
globalThis.Marionette = Marionette
Marionette.AppRouter = AppRouter
