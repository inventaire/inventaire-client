enumerateDevices = require 'enumerate-devices'

# using https://www.npmjs.com/package/enumerate-devices
module.exports = ->
  enumerateDevices()
  .then hasVideoInput
  .then (bool)-> window.hasVideoInput = bool
  .catch (err)->
    console.warn 'has_video_input error', err
    window.hasVideoInput = false

hasVideoInput = (devices)-> _.any devices, isVideoInput
isVideoInput = (device)-> device.kind is 'videoinput'
