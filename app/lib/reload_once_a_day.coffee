# Reload the page every 24 hours to make sure we have the latest version
# unless the current page is being edited

module.exports = -> setInterval tryReload, 24*60*60*1000

tryReload = ->
  if textareaContentLength() > 0 then return
  window.location.reload()

textareaContentLength = ->
  _.toArray $('textarea')
  .map _.property('value')
  .join ''
  .length
