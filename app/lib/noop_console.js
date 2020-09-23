# mimicking window.console API to mute logs
noop = ->
module.exports =
  log: noop
  warn: noop
  error: noop
  info: noop
  trace: noop
  time: noop
  timeEnd: noop
