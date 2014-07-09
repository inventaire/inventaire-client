module.exports = (app)->
  app.vent = new Backbone.Wreqr.EventAggregator()

  app.vent.on 'all', (eventName, data)->
    console.log "[app.vent] #{eventName}"
    console.log data if data?

  app.vent.trigger 'logger:start'

  app.on 'all', (eventName, data)->
    console.log "[app] #{eventName}"
    console.log data if data?

  app.user.on 'change', (user)->
    console.log "[app:user:change]"
    console.log user.changed