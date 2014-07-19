module.exports = ()->
  # @vent.on 'all', (eventName, data)->
  #   console.log "[vent] #{eventName}"
  #   console.log data if data?

  @debug = false

  if @debug
    @vent.on 'debug', (args, memo)->
      console.log '--'
      console.log "[debug:#{arguments.callee.name}]: #{memo}"
      console.log args.callee
      console.log '--'

    @on 'all', (eventName, data)->
      console.log "[app] #{eventName}"
      console.log data if data?