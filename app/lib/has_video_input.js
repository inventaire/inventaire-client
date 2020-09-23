import enumerateDevices from 'enumerate-devices';

// using https://www.npmjs.com/package/enumerate-devices
export default () => window.waitForDeviceDetection = enumerateDevices()
  .then(hasVideoInput)
  .then(bool => window.hasVideoInput = bool)
  .catch(function(err){
    console.warn('has_video_input error', err);
    window.hasVideoInput = false;
    return window.doesntSupportEnumerateDevices = true;
});

var hasVideoInput = devices => _.any(devices, isVideoInput);
var isVideoInput = device => device.kind === 'videoinput';
