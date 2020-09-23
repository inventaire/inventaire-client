/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-var,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import enumerateDevices from 'enumerate-devices'

// using https://www.npmjs.com/package/enumerate-devices
export default () => window.waitForDeviceDetection = enumerateDevices()
  .then(hasVideoInput)
  .then(bool => window.hasVideoInput = bool)
  .catch(err => {
    console.warn('has_video_input error', err)
    window.hasVideoInput = false
    return window.doesntSupportEnumerateDevices = true
  })

var hasVideoInput = devices => _.any(devices, isVideoInput)
var isVideoInput = device => device.kind === 'videoinput'
