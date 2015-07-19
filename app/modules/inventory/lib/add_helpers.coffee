# just wrapping localStorage persisting of last add mode

module.exports = ->
  app.commands.setHandlers
    'last:add:mode:set': lastAddModeSet

  app.reqres.setHandlers
    'last:add:mode:get': lastAddModeGet

lastAddModeSet = (mode)->
  localStorage.setItem 'lastAddMode', mode

lastAddModeGet = ->
  localStorage.getItem 'lastAddMode'
