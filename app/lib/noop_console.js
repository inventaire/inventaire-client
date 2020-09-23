// mimicking window.console API to mute logs
const noop = function () {}
export { noop as log, noop as warn, noop as error, noop as info, noop as trace, noop as time, noop as timeEnd }
