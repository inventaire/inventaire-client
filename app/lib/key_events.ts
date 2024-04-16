export function getActionKey (e) {
  const key = e.which || e.keyCode
  return actionKeysMap[key]
}

const actionKeysMap = {
  9: 'tab',
  13: 'enter',
  16: 'shift',
  17: 'ctrl',
  18: 'alt',
  27: 'esc',
  33: 'pageup',
  34: 'pagedown',
  35: 'end',
  36: 'home',
  37: 'left',
  38: 'up',
  39: 'right',
  40: 'down'
}

export function stopEscPropagation (e) {
  if (getActionKey(e) === 'esc') e.stopPropagation()
}
