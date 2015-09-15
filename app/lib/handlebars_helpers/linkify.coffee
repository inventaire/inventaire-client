# customized for client-side needs
module.exports = (text, url, classes='link')->
  # prevent [object Object] classes
  unless _.isString(classes) then classes = ''
  "<a href=\"#{url}\" class='#{classes}' target='_blank'>#{text}</a>"
