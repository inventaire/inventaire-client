class Application extends Backbone.Marionette.Application
  initialize: =>
    _.extend @, require 'structure'

    @commands = new Backbone.Wreqr.Commands()
    @vent = new Backbone.Wreqr.EventAggregator()
    @Lib.EventLogger.call @

    @Behaviors = require('behaviors/base')
    @Behaviors.initialize()


    @layout = new @Layout.App

    @on "start", (options) ->
      Backbone.history.start({pushState: true})

    @start()

module.exports = new Application()