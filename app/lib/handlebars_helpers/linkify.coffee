# customized for client-side needs
module.exports = (text, url, classes='link')->
  # prevent [object Object] classes
  # avoiding using _.isString as the module is used in scripts with differents environments
  unless typeof classes is 'string' then classes = ''

  isExternalLink = url[0] isnt '/'
  # on rel='noopener' see: https://mathiasbynens.github.io/rel-noopener
  openOutsideAttributes = if isExternalLink then "target='_blank' rel='noopener'" else ''

  "<a href=\"#{url}\" class='#{classes}' #{openOutsideAttributes}>#{text}</a>"
