import enumerateDevices from 'enumerate-devices'
import { any } from 'underscore'

let hasVideoInput
let doesntSupportEnumerateDevices

async function _checkVideoInput () {
  return enumerateDevices()
    .then(someDeviceIsVideoInput)
    .then(bool => { hasVideoInput = bool })
    .catch(err => {
      if (err.kind === 'METHOD_NOT_AVAILABLE' && window.location.protocol === 'http:') {
        // enumerateDevices relies on window.navigator.mediaDevices.enumerateDevices
        // which will be unaccessible in insecure context
        // Assume we have a video input available to allow video feature dev/debug
        console.error(`Can't access navigator.mediaDevices on insecure origin.
This can be fixed in Firefox about:config by setting the following parameters:
  media.devices.insecure.enabled=true
  media.getusermedia.insecure.enabled=true
`, err)
      } else {
        console.error('has_video_input error', err)
      }
      hasVideoInput = false
      doesntSupportEnumerateDevices = true
    })
}

let waitForDeviceDetection
export async function checkVideoInput () {
  waitForDeviceDetection = waitForDeviceDetection || _checkVideoInput()
  return waitForDeviceDetection
}

const someDeviceIsVideoInput = devices => any(devices, isVideoInput)

const isVideoInput = device => device.kind === 'videoinput'

export function getDevicesInfo () {
  return { hasVideoInput, doesntSupportEnumerateDevices }
}
