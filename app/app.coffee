class Application extends Backbone.Marionette.Application
  initialize: =>


    @commands = new Backbone.Wreqr.Commands()
    @vent = new Backbone.Wreqr.EventAggregator()

    @Behaviors = require('behaviors/base')
    @Behaviors.initialize()




    @on "start", (options) ->
      Backbone.history.start({pushState: true})

    @start()

module.exports = new Application()