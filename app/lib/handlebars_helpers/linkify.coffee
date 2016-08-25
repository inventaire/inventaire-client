# customized for client-side needs
module.exports = (text, url, classes='link')->
  # prevent [object Object] classes
  # avoiding using _.isString as the module is used in scripts with differents environments
  unless typeof classes is 'string' then classes = ''

  # on rel='noopener' see: https://mathiasbynens.github.io/rel-noopener
  "<a href=\"#{url}\" class='#{classes}' target='_blank' rel='noopener'>#{text}</a>"
