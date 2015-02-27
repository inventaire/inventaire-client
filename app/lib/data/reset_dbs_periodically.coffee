# quite a small period, but it should allow to keep up
# with the app changes while in beta
period = 24 * 3600 * 1000


module.exports = ->
  lastResetTime = getLastResetTime()
  unless lastResetTime? then return initPeriodicalReset()

  if periodIsOver(lastResetTime)
    # don't reset if offline, as the user wouldnt
    # be able to refresh the data
    app.request 'ifOnline', resetIfOnline
  else
    _.log lastResetTime, 'not reseting dbs: last reset is fresh enough'


resetIfOnline = ->
  resetDbsNow 'starting periodic dbs.reset'

getLastResetTime = ->
  lastReset = localStorage.getItem 'last_db_reset'
  lastReset = Number(lastReset)
  if _.typeOf(lastReset) is 'number' then return lastReset
  else return

initPeriodicalReset = ->
  # start by a reset to make sure dbs anterior to
  # pre-periodical-reset functionalities are cleaned
  resetDbsNow 'intializing dbs.reset'

periodIsOver = (lastResetTime)->
  _.now() - lastResetTime > period

resetDbsNow = (label)->
  if label? then _.log label
  dbs.reset()
  localStorage.setItem 'last_db_reset', _.now()