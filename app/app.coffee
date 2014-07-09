structure = require 'structure'

class Application extends Backbone.Marionette.Application
  initialize: =>
    _.extend @, structure
    @user = new @Model.User

    # WAIT FOR A USER
    # @items = new @Collection.Items

    # event logger should start after the user model and items collections to allow to track them too
    @Lib.EventLogger @

    # @items.fetch {reset: true}

      # @filterInventoryBy 'personalInventory'

      # @items.on 'reset', @refresh, @


    @layout = new @Layout.App()
    @layout.accountMenu.on 'show', (data)->
      console.log 'accountMenu:show'
      console.log data
    @layout.render()


    inventory = new @View.Inventory
    @layout.main.show inventory

    @auth = @module 'auth', @Module.Auth(@auth, @, Backbone, Marionette, $, _)


    $(document).foundation()

    # @addInitializer (options) =>
    #   # Instantiate the router
    #   Router = require 'router'
    #   @router = new Router()

    # @addInitializer (options) =>
    #   Persona = require 'lib/persona'
    #   Persona.initialize()

    @on "start", (options) =>
      Backbone.history.start({pushState: true})
      @vent.trigger 'history:start'
      # Freeze the object
      # Object.freeze? this
    @start()



module.exports = new Application()