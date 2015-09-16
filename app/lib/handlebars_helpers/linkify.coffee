# customized for client-side needs
module.exports = (text, url, classes='link')->
  # prevent [object Object] classes
  # avoiding using _.isString as the module is used in scripts with differents environments
  unless typeof classes is 'string' then classes = ''
  "<a href=\"#{url}\" class='#{classes}' target='_blank'>#{text}</a>"
