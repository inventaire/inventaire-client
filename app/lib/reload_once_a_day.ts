import { property } from 'underscore'
// Reload the page every 24 hours to make sure we have the latest version
// unless the current page is being edited

export default () => setInterval(tryReload, 24 * 60 * 60 * 1000)

function tryReload () {
  if (textareaContentLength() > 0) return
  return window.location.reload()
}

function textareaContentLength () {
  return Array.from(document.querySelectorAll('textarea'))
  .map(property('value'))
  .join('')
  .length
}
