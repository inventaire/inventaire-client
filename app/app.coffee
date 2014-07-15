structure = require 'structure'

class Application extends Backbone.Marionette.Application
  initialize: =>
    _.extend @, structure

    @commands = new Backbone.Wreqr.Commands()
    @vent = new Backbone.Wreqr.EventAggregator()

    @user = new @Model.User

    # event logger should start after the user model and items collections to allow to track them too
    @Lib.EventLogger.call @


      # @filterInventoryBy 'personalInventory'

      # @items.on 'reset', @refresh, @


    @layout = new @Layout.App
    @layout.render()
    # after layout
    @auth = @module 'auth', @Module.Auth(@auth, @, Backbone, Marionette, $, _)


    @on "start", (options) =>
      $(document).foundation()
      Backbone.history.start({pushState: true})
      # Freeze the object
      # Object.freeze? this

    # @addInitializer (options) =>
    #   # Instantiate the router
    #   Router = require 'router'
    #   @router = new Router()


    @start()



module.exports = new Application()