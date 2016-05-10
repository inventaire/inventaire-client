module.exports = (e)->
  key = e.which or e.keyCode
  return actionKeysMap[key]

actionKeysMap =
  9: 'tab'
  13: 'enter'
  16: 'shift'
  17: 'ctrl'
  18: 'alt'
  27: 'esc'
  35: 'end'
  36: 'home'
  37: 'left'
  38: 'up'
  39: 'right'
  40: 'down'
