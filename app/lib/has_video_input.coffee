# using https://www.npmjs.com/package/enumerate-devices
module.exports = ->
  window.enumerateDevices()
  .then hasVideoInput
  .then (bool)-> window.hasVideoInput = bool

hasVideoInput = (devices)-> _.any devices, isVideoInput
isVideoInput = (device)-> device.kind is 'videoinput'
