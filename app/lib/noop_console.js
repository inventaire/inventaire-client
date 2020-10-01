// Mimicking window.console API to mute logs
const noop = () => {}

export default {
  log: noop,
  warn: noop,
  error: noop,
  info: noop,
  trace: noop,
  time: noop,
  timeEnd: noop,
}
