import enumerateDevices from 'enumerate-devices'
import { any } from 'underscore'

export default () => {
  window.waitForDeviceDetection = enumerateDevices()
    .then(hasVideoInput)
    .then(bool => { window.hasVideoInput = bool })
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
      window.hasVideoInput = false
      window.doesntSupportEnumerateDevices = true
    })
}

const hasVideoInput = devices => any(devices, isVideoInput)

const isVideoInput = device => device.kind === 'videoinput'
